#
# Copyright (C)  2015  Zoltan Tombol <zoltan (dot) tombol (at) gmail (dot) com>
#
# This file is part of Varrick.
#
# Varrick is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Varrick is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Varrick.  If not, see <http://www.gnu.org/licenses/>.
#

#
# Lib "Zhu-Li" offers functions for working with template files containing shell
# format strings.
#

# Print list of variables referenced in the template. When escaping is enabled,
# escaped variables are not reported. The list is newline separated and can be
# directly captured into an array. For example:
#
#   vars=( "$(get_referenced "$input")" )
#
# Globals:
#   none
# Arguments:
#   $1 - template
#   $2 - [=0] escaping, disabled if 0, enabled otherwise
# Output:
#   STDOUT - list of variables
# Returns:
#   0 - list is not empty
#   1 - otherwise
get_referenced () {
  local input="$1"
  local do_escape="${2:-0}"

  local name='[a-zA-Z_][a-zA-Z_0-9]*'
  local ref='\$('"${name}"'|\{'"${name}"'\})'
  local ref_vars
  if [ "$do_escape" != 0 ]; then
    ref_vars=( $(
      # 1. Surround non-escaped references with newlines.
      #      \$var   -> \n\$var\n
      #      \${var} -> \n\${var}\n
      # 2. Extract name of referenced variables.
      #      \$var   -> var
      #      \${var} -> {var}
      # 3. Remove braces.
      #      {var}   -> var
      # 4. Remove duplicates.
      echo "$input" \
        | sed -r 's/((^|[^\])(\\\\)*)('"${ref}"')/\1\n\4\n/g' \
        | sed -rn 's/^'"${ref}"'$/\1/p' \
        | tr -d '{}' \
        | sort -u
    ) )
  else
    ref_vars=( $(
      # 1. Surround references with newlines.
      #      \$var   -> \n\$var\n
      #      \${var} -> \n\${var}\n
      # 2. Extract name of referenced variables.
      #      \$var   -> var
      #      \${var} -> {var}
      # 3. Remove braces.
      #      {var}   -> var
      # 4. Remove duplicates.
      echo "$input" \
        | sed -r 's/'"${ref}"'/\n&\n/g' \
        | sed -rn 's/^'"${ref}"'$/\1/p' \
        | tr -d '{}' \
        | sort -u
    ) )
  fi

  printf "%s\n" "${ref_vars[@]}"
  [ "${#ref_vars[@]}" -ne 0 ]
}

# Print list of escaped variable references in the template. The list is newline
# separated and can be directly captured into an array. For example:
#
#   vars=( "$(get_escaped "$input")" )
#
# Globals:
#   none
# Arguments:
#   $1 - template
# Output:
#   STDOUT - list of variables
# Returns:
#   0 - list is not empty
#   1 - otherwise
get_escaped () {
  local input="$1"

  local name='[a-zA-Z_][a-zA-Z_0-9]*'
  local ref='\$('"${name}"'|\{'"${name}"'\})'
  local esc_vars
  esc_vars=( $(
    # 1. Surround escaped references with newlines.
    #      \$var   -> \n\$var\n
    #      \${var} -> \n\${var}\n
    # 2. Extract name of referenced variables.
    #      \$var   -> var
    #      \${var} -> {var}
    # 3. Remove braces.
    #      {var}   -> var
    # 4. Remove duplicates.
    echo "$input" \
      | sed -r 's/((^|[^\])(\\\\)*)(\\)('"${ref}"')/\1\n\4\5\n/g' \
      | sed -rn 's/^\\'"${ref}"'$/\1/p' \
      | tr -d '{}' \
      | sort -u
    ) )

  printf "%s\n" "${esc_vars[@]}"
  [ "${#esc_vars[@]}" -ne 0 ]
}

# Print list of variables referenced in the template, but not defined in the
# environment. Complement of `get_defined'. When escaping is enabled, escaped
# variables are not reported. The list is newline separated and can be directly
# captured into an array. For example:
#
#   vars=( "$(get_missing "$input")" )
#
# Globals:
#   * - enumerate all environment variables
# Arguments:
#   $1 - template
#   $2 - [=0] escaping, disabled if 0, enabled otherwise
# Output:
#   STDOUT - list of variables
# Returns:
#   0 - list is not empty
#   1 - otherwise
get_missing () {
  local input="$1"
  local do_escape="${2:-0}"

  local ref_vars miss_vars
  ref_vars=( $(get_referenced "$input" "$do_escape") )
  miss_vars=( $(comm -23 <(printf "%s\n" "${ref_vars[@]}") \
                         <(printf "%s\n" "$(compgen -e | sort)")) )

  printf "%s\n" "${miss_vars[@]}"
  [ "${#miss_vars[@]}" -ne 0 ]
}

# Print list of variables referenced in the template and defined in the
# environment. Complement of `get_missing'. When escaping is enabled, escaped
# variables are not reported. The list is newline separated and can be directly
# captured into an array. For example:
#
#   vars=( "$(get_defined "$input")" )
#
# Globals:
#   * - enumerate all environment variables
# Arguments:
#   $1 - template
#   $2 - [=0] escaping, disabled if 0, enabled otherwise
# Output:
#   STDOUT - list of variables
# Returns:
#   0 - list is not empty
#   1 - otherwise
get_defined () {
  local input="$1"
  local do_escape="${2:-0}"

  local ref_vars defined_vars
  ref_vars=( $(get_referenced "$input" "$do_escape") )
  defined_vars=( $(comm -12 <(printf "%s\n" "${ref_vars[@]}") \
                            <(printf "%s\n" "$(compgen -e | sort)")) )

  printf "%s\n" "${defined_vars[@]}"
  [ "${#defined_vars[@]}" -ne 0 ]
}

# Transform template read from the standard input to prevent `envsubst'
# expanding escaped references. This involves reversing the leading `\$' of
# escaped references, i.e. turning `\$var' into `$\var'. This function is used
# together with `unescape'.
#
# Example:
#
#   cat "$template_file" | escape | envsubst | unescape
#
# Globals:
#   none
# Arguments:
#   none
# Inputs:
#   STDIN - template
# Outputs:
#   STDOUT - transformed template
# Returns:
#   none
escape () {
  local name='[a-zA-Z_][a-zA-Z_0-9]*'
  local ref='\$('"${name}"'|\{'"${name}"'\})'

  # Transform escaped references.
  #   \$var   -> $\var
  #   \${var} -> $\{var}
  sed -r 's/((^|[^\])(\\\\)*)(\\)'"$ref"'/\1$\4\5/g'
}

# Remove escaping backslashes from the template read from the standard input.
# This is a necessary step after expanding a template that uses escaping. This
# function is used together with `escape'.
#
# Example:
#
#   cat "$template_file" | escape | envsubst | unescape
#
# Global:
#   none
# Arguments:
#   none
# Inputs:
#   STDIN - template
# Outputs:
#   STDOUT - transformed template
# Returns:
#   none
unescape () {
  local name='[a-zA-Z_][a-zA-Z_0-9]*'
  local ref_no_ds='('"${name}"'|\{'"${name}"'\})'

  # 1. Remove backslash from escaped references.
  #      $\var   -> $var
  #      $\{var} -> ${var}
  # 2. Remove backslash from escaped backslashes.
  #      \\ -> \
  sed -r -e 's/\$\\'"${ref_no_ds}"'/\$\1/g' \
         -e 's/\\\\/\\/g'
}

# Escape backslashes in the given variables. This is a necessary step before
# expanding a template that uses escaping. It cancels out the effect of
# `unescape' on the substituted values. This function is used together with
# `escape' and `unescape'.
#
# Example:
#
#   escape_vars $(get_defined "$template")
#   cat "$template_file" | escape | envsubst | unescape
#
# Globals:
#   $@ - all variables passed as arguments
# Arguments:
#   $@ - list of variables
# Returns:
#   none
escape_vars () {
  for _d8e1_var in $@; do
    # Escape backslashes.
    #   \ -> \\
    eval "$_d8e1_var"'="${'"$_d8e1_var"'//\\/\\\\}"'
  done
}

# Check whether all escape sequences are valid in the template. If invalid
# escape sequences are encountered, an error message and the offending lines
# along with their line number are displayed. Otherwise, a message stating
# success is displayed.
#
# Globals:
#   none
# Arguments:
#   $1 - template
# Outputs:
#   STDOUT - error message with offending lines, or message of success
# Returns:
#   0 - correct escaping
#   1 - otherwise
check_esc () {
  local input="$1"

  local error=0
  local line_no=0
  while read -r line; do
    : $((++line_no))
    # Mutually exclusive patterns matching:
    # 1. (odd * `\') + (not a `$')
    # 2. (odd * `\') + $ + (not a `{' or variable name character)
    # 3. (odd * `\') + ${ + (not a variable name character)
    # 4. (odd * `\') + ${ + (variable name characters)
    #                + (not a `}' or a variable name character)
    local match="$(echo "$line" | sed -nr \
      -e '/(^|[^\])(\\\\)*\\([^\$]|$)/p' \
      -e '/(^|[^\])(\\\\)*\\\$([^{a-zA-Z_]|$)/p' \
      -e '/(^|[^\])(\\\\)*\\\$\{([^a-zA-Z_]|$)/p' \
      -e '/(^|[^\])(\\\\)*\\\$\{[a-zA-Z_][a-zA-Z_0-9]*([^}a-zA-Z_0-9]|$)/p'
    )"
    if [ -n "$match" ]; then
      if [ "$error" -eq 0 ]; then
        echo 'Error: Invalid escaping in the following lines:'
        error=1
      fi
      echo "$line_no: $match"
    fi
  done <<< "$input"

  [ "$error" -eq 0 ] && echo 'Everything looks good!'
  return $error
}

# Escape variable reference-like strings and backslashes in the template. This
# is a useful first step when turning a plain file into a template.
#
# Globals:
#   none
# Arguments:
#   $1 - template
# Outputs:
#   STDOUT - escaped template
# Returns:
#   none
preprocess () {
  local input="$1"

  local name='[a-zA-Z_][a-zA-Z_0-9]*'
  local ref='\$('"${name}"'|\{'"${name}"'\})'

  # 1. Escape backslashes.
  #      \ -> \\
  # 2. Escape references.
  #      $var   -> \$var
  #      ${var} -> \${var}
  echo "$input" | sed -r -e 's/\\/\\&/g' \
                         -e 's/'"$ref"'/\\&/g'
}

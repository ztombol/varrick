#!/usr/bin/bash

#
# Copyright (C)  2015  Zoltan Vass <zoltan (dot) tombol (at) gmail (dot) com>
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

# Print list of variables referenced in the given template. When escaping is
# enabled (default), escaped variables are not reported. The output contains one
# variable name per line and can be directly captured into an array.
# For example:
#
#   vars=( "$(get_referenced "$input")" )
#
# Globals:
#   none
# Arguments:
#   $1 - template string
#   $2 - (opt) enable escaping, 1 = enabled (default), disabled otherwise
# Output:
#   STDOUT - variable names separated by newlines
# Returns:
#   0 - list is not empty
#   1 - otherwise
get_referenced () {
  local input="$1"
  local do_escape="${2:-1}"
  local name='[a-zA-Z_][a-zA-Z_0-9]*'
  local ref='\$('"${name}"'|\{'"${name}"'\})'

  local ref_vars
  if [ "$do_escape" == 1 ]; then
    ref_vars=( $(
      # 1. surround non-escaped references with newlines: \$var   -> \n\$var\n
      #                                                   \${var} -> \n\${var}\n
      # 2. extract name of referenced variables: \$var   -> var
      #                                          \${var} -> {var}
      # 3. remove braces: {var} -> var
      # 4. remove duplicates
      echo "$input" \
        | sed -r 's/((^|[^\])(\\\\)*)('"${ref}"')/\1\n\4\n/g' \
        | sed -rn 's/^'"${ref}"'$/\1/p' \
        | tr -d '{}' \
        | sort -u
    ) )
  else
    ref_vars=( $(
      # 1. surround references with newlines: \$var   -> \n\$var\n
      #                                       \${var} -> \n\${var}\n
      # 2. extract name of referenced variables: \$var   -> var
      #                                          \${var} -> {var}
      # 3. remove braces: {var} -> var
      # 4. remove duplicates
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

# Print list of escaped variable references in the given template. The output
# contains one variable name per line and can be directly captured into an
# array. For example:
#
#   vars=( "$(get_escaped "$input")" )
#
# Globals:
#   none
# Arguments:
#   $1 - template string
# Output:
#   STDOUT - variable names separated by newlines
# Returns:
#   0 - list is not empty
#   1 - otherwise
get_escaped () {
  local input="$1"
  local name='[a-zA-Z_][a-zA-Z_0-9]*'
  local ref='\$('"${name}"'|\{'"${name}"'\})'

  local esc_vars
  esc_vars=( $(
    # 1. surround escaped references with newlines: \$var   -> \n\$var\n
    #                                               \${var} -> \n\${var}\n
    # 2. extract name of referenced variables: \$var   -> var
    #                                          \${var} -> {var}
    # 3. remove braces: {var} -> var
    # 4. remove duplicates
    echo "$input" \
      | sed -r 's/((^|[^\])(\\\\)*)(\\)('"${ref}"')/\1\n\4\5\n/g' \
      | sed -rn 's/^\\'"${ref}"'$/\1/p' \
      | tr -d '{}' \
      | sort -u
    ) )

  printf "%s\n" "${esc_vars[@]}"
  [ "${#esc_vars[@]}" -ne 0 ]
}

# Print list of variables referenced in the given template but not defined in
# the environment. When escaping is enabled (default), escaped variables are not
# reported. The output contains one variable name per line and can be directly
# captured into an array. For example:
#
#   vars=( "$(get_missing "$input")" )
#
# Globals:
#   none
# Arguments:
#   $1 - template string
#   $2 - (opt) enable escaping, 1 = enabled (default), disabled otherwise
# Output:
#   STDOUT - variable names separated by newlines
# Returns:
#   0 - list is not empty
#   1 - otherwise
get_missing () {
  local input="$1"
  local do_escape="${2:-1}"

  local temp_vars miss_vars
  ref_vars=( $(get_referenced "$input" "$do_escape") )
  miss_vars=( $(comm -23 <(printf "%s\n" "${ref_vars[@]}") \
                         <(printf "%s\n" "$(compgen -e | sort)")) )

  printf "%s\n" "${miss_vars[@]}"
  [ "${#miss_vars[@]}" -ne 0 ]
}

# Print list of variables referenced in the given template and defined in the
# environment. When escaping is enabled (default), escaped variables are not
# reported. Essentially, it prints the complement of `get_missing()'. The output
# contains one variable name per line and can be directly captured into an
# array. For example:
#
#   vars=( "$(get_defined "$input")" )
#
# Globals:
#   none
# Arguments:
#   $1 - template string
#   $2 - (opt) enable escaping, 1 = enabled (default), disabled otherwise
# Output:
#   STDOUT - variable names separated by newlines
# Returns:
#   0 - list is not empty
#   1 - otherwise
get_defined () {
  local input="$1"
  local do_escape="${2:-1}"

  local temp_vars defined_vars
  ref_vars=( $(get_referenced "$input" "$do_escape") )
  defined_vars=( $(comm -12 <(printf "%s\n" "${ref_vars[@]}") \
                            <(printf "%s\n" "$(compgen -e | sort)")) )

  printf "%s\n" "${defined_vars[@]}"
  [ "${#defined_vars[@]}" -ne 0 ]
}

# Transform the template read from STDIN to prevent `envsubst' to expand escaped
# references. This involves the simple transformation of swapping the first two
# characters of escaped references, i.e turning `\$' into `$\'. This is
# necessary before expanding a template that contains escape sequences.
#
# Globals:
#   none
# Arguments:
#   none
# Input:
#   STDIN - template string
# Outputs:
#   STDOUT - escaped template string
# Returns:
#   none
escape () {
  local name='[a-zA-Z_][a-zA-Z_0-9]*'
  local ref='\$('"${name}"'|\{'"${name}"'\})'

  # Transform escaped references: \$var   -> $\var
  #                               \${var} -> $\{var}
  sed -r 's/((^|[^\])(\\\\)*)(\\)'"$ref"'/\1$\4\5/g'
}

# Remove slashes escaping references and slashes from the template read from
# STDIN. This is necessary after expanding a template that contains escape
# sequences.
#
# Globals:
#   none
# Arguments:
#   none
# Input:
#   STDIN - template string
# Outputs:
#   STDOUT - un-escaped template string
# Returns:
#   none
unescape () {
  local name='[a-zA-Z_][a-zA-Z_0-9]*'
  local ref_no_ds='('"${name}"'|\{'"${name}"'\})'

  # 1. Remove slash from escaped references: $\var   -> $var
  #                                          $\{var} -> ${var}
  # 2. Remove slash from escaped slashes: \\ -> \
  sed -r -e 's/\$\\'"${ref_no_ds}"'/\$\1/g' \
         -e 's/\\\\/\\/g'
}

# Escape slashes in the given environment variables. This is necessary before
# expanding a template containing escape sequences to cancel out the effect of
# `unescape()' on substituted variables.
#
# Globals:
#   none
# Arguments:
#   $@ - list of variables to escape
# Returns:
#   none
escape_vars () {
  for _d8e1_var in $@; do
    # `\' -> `\\'
    eval "$_d8e1_var"'="${'"$_d8e1_var"'//\\/\\\\}"'
  done
}

# Check whether all escape sequences are valid in the given template. Lines
# containing invalid escape sequences are printed along with their line numbers.
#
# Globals:
#   none
# Arguments:
#   $1 - template string
# Outputs:
#   STDOUT - lines containing invalid escaping along with their numbers
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

# Escape variable references and slashes in the given string. Useful for
# preprocessing a file before turning it into a template. Preprocessing a string
# that does not require escaping leaves the string unchanged.
#
# Globals:
#   none
# Arguments:
#   $1 - string to preprocess
# Output:
#   STDOUT - pre-processed template string
# Returns:
#   0 - escaping was necessary
#   1 - otherwise
preprocess () {
  local input="$1"
  local name='[a-zA-Z_][a-zA-Z_0-9]*'
  local ref='\$('"${name}"'|\{'"${name}"'\})'

  get_referenced "$input" 0 > /dev/null
  if [ "$?" -eq 0 ]; then
    # 1. escape slashes: \ -> \\
    # 2. escape references: $var   -> \$var
    #                       ${var} -> \${var}
    echo "$input" | sed -r -e 's/\\/\\&/g' \
                           -e 's/'"$ref"'/\\&/g'
    return 0
  else
    # Escaping not necessary.
    echo "$input"
    return 1
  fi
}

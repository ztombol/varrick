# Varrick

Varrick is a convenient template engine written in shell script and using
`envsubst`. It substitutes references of the form `$var` and `${var}` with
environment variables using `envsubst`, while offering advanced features, e.g.
escaping support, over that of `envsubst`.

Varrick was primarily made to simplify configuration of Linux containers, but
can be used for other purposes as well.


# Motivation

Configuration files are often generated by replacing default values with
environment variables using `sed`. This is tedious and error prone in all but
the simplest cases.

A number of shell scripts attempt to remedy the situation and hide the gory
details of the process. They use `sed` or `eval` which are ill-suited to
implement substitution and end up cutting corners to avoid complexity. The
resulting esoteric, mostly undocumented behaviour is left to the user to figure
out. Often a purpose built `sed`-based solution is a more viable option. Not
very convenient.

Good template engines exist in higher level languages, e.g. Perl or Python, but
their dependencies are too heavy to be considered for containers.

Existing solutions are either not robust enough to provide consistent behaviour
outside the simplest use cases or require large dependencies. This is what
Varrick intends to change.


# Design

Varrick was designed to be...

* Convenient - Intuitive, well-documented and consistent behaviour across all
  user input.
* Lightweight - Avoid using heavy dependencies, but don't reinvent the wheel.

To achieve these goals Varrick uses the following strategies.

* Implement in shell script. The supported shells are already available on
  most systems and containers.
* Use `envsubst` instead of `sed` or `eval` for substitution. Most problems of
  existing shell based solutions come from the fact that they use the wrong tool
  for the job. `envsubst` was made solely for substituting environment variables
  in shell format strings. It is also part of `gettext` which is readily
  available on most systems and containers.
* Thorough testing. Tests are written using the excellent [Bats][bats-gh] framework.
  Accompanying libraries are unit tested.
* Good documentation. Concise user and developer documentation to eliminate
  learning curve and ease maintenance.


# Example

## Simple variable expansion

Paths can contain a wide range of characters which makes them especially
difficult to reliably substitute using `sed`. Thanks to `envsubst`, regardless
the substituted value, Varrick will just *do the right thing* for you.

Lets say you are working with Nginx and want to make the location of logs
customisable. You just need to replace the paths with a variable reference as
shown below.

```Nginx
error_log $NGINX_LOG_DIR/error.log;

http {
    access_log $NGINX_LOG_DIR/access.log;
}
```

Assuming the template above is saved as `nginx.conf.tmpl`, new configurations
can be generated by the following command after defining `NGINX_LOG_DIR`.

```Shell
$ export NGINX_LOG_DIR=/data/logs
$ varrick nginx.conf.tmpl /etc/nginx
```

This will create the file `nginx.conf` in `/etc/nginx` with the variable
references expanded.

```Nginx
error_log /data/logs/error.log;

http {
    access_log /data/logs/access.log;
}
```

For this example using `envsubst` would have sufficed. See the next example for
the advanced features of Varrick.


## Escaping

Sometimes the files you want to parametrise contain strings that would be
mistaken for variable references, or you want to avoid expanding certain
references, e.g. in comments. This is when Varrick's escaping feature comes in
handy.

Sticking with Nginx, its configuration file often contains variables of the form
`$var` which would be inadvertently expanded by Varrick.

```Nginx
http {
    # PHP pages.
    location ~ \.php$ {
        try_files      $uri = 404;
        fastcgi_pass   php-handler;
        fastcgi_index  index.php;
        include        fastcgi.conf;
    }
}
```

Prepending a variable reference with a backslash prevents its expansion. Of
course, when escaping is enabled backslashes has to be escaped too.

```Nginx
http {
    # PHP pages.
    location ~ \\.php$ {
        try_files      \$uri = 404;
        fastcgi_pass   php-handler;
        fastcgi_index  index.php;
        include        fastcgi.conf;
    }
}
```

See the next example on how Varrick can do this for you.

Assuming the template above is saved as `nginx.conf.tmpl`, the following command
outputs the original, un-escaped snippet.

```Shell
$ varrick --escape nginx.conf.tmpl
```

Note that only backslashes and proper variable references need to be escaped.
That is, the `$` in `\.php$` does not require escaping, nor would `${a-}`.


## Creating templates

### Preprocessing

First, if you are planning to use escaped references or the source file contains
strings that may be mistaken for references, you need to preprocess the source
and escape backslashes and reference-looking strings.

To determine whether the source contains references, list the variables
referenced.

```Shell
$ varrick --summary my.conf
```

If the output is empty, then there are no strings that look like variable
references. Unless you want to use escaping you can skip to the next step.

To escape variable references and backslashes.

```Shell
$ varrick --preprocess my.conf my.conf.tmpl
```


### Adding variable references

After making sure that the source is escaped where needed, you can edit it and
add the variable references you need.

Finally, double check that the template is correct by reviewing the list of
variables referenced. If you are using escaping add `--escape` to list the
escaped variable references as well.

```Shell
$ varrick --summary my.conf.tmpl
```

When using escaping, you can check whether the added backslashes or escaped
references are correctly escaped.

```Shell
$ varrick --check my.conf.tmpl
```


# Dependencies

Varrick has the following dependencies.

* A supported shell. Currently only `bash` is supported, but `bash` specific
  syntax was intentionally avoided in many cases to ease porting in the future.
* [`envsubst`][envsubst-hp] from [`gettext`][gettext-hp]
* [`sed`][sed-hp]
* `getopt` from [`util-linux`][util-linux-hp]
* basic utilities, e.g. `cat` or `ls`, from [`coreutils`][coreutils-hp]


# Contribution

Varrick is licensed under [GPLv3][gplv3]. Contribution of any kind is welcome.
If you find any bugs or have suggestions, open an issue or pull request on the
projects [GitHub page][varrick-gh].

*Liberation Sans* and *Liberation Mono*, the fonts used in images, are licenced
under [SIL Open Font Licence Version 1.1][sil-ofl]. These fonts were downloaded
from [Fedora Hosted][liberation-fedora] and are included in the source code
distribution of Varrick along with their [license][local-liberation-license].


## Conventions

To maintain consistent style and thus ease maintenance and contribution, please
follow the conventions below (modelled after the [contribution
guidelines][git-contrib] of the Git project).

***Note:*** *Don't worry about nailing all of these the first time. Commits and
pull requests can be amended and we can work it out together. \\^-^/*

General:
- Lines should be no longer than 80 characters, except where a longer line
  improves readability or where a line cannot be broken up, e.g. test
  descriptions.
- Use spaces instead of tabs where possible.

Source code:
- Messages appearing on the screen should not be wider than 80 characters,
  except when they contain part of the input that should be preserved verbatim,
  e.g. listing lines that contain escaping errors.
- Use 2 spaces instead of a tab.

Documentation and man pages:
- Write documentation in [Github flavoured markdown][gh-markdown].
- Write man pages in markdown using [ronn][ronn-hp]. Regenerate and commit
  *HTML* format man pages (`make docs`) after editing. *Roff* format man pages
  are generated build time, do not commit them.

Commits and pull requests:
- A commit message must start with a short summary written in the imperative and
  omitting the full stop. It must start with a capital letter, unless the first
  word is always written lower-case, e.g. file or function name. Be concise, the
  soft-limit is 50 characters.
- Optionally, the summary may be followed by a more detailed explanation
  separated by an empty line. Wrap this to 72 characters.
- Include documentation and test changes in the same commit to make reverting
  easy.
- Write tests for your modifications. The test suite must pass after each
  commit.
- Make separate commits for logically separate changes.
- Commits fixing or closing an issue should include a reference to the issue,
  e.g. "Close #x" or "Fix #x", to automatically close the issue when merged.


# Name

The name *"Varrick"* did not materialise until shortly before the first release.
It emerged from the test string *"Do the thing!"* that was used especially a lot
in the early revisions. Not surprisingly the library doing the heavy lifting
behind Varrick is called *"Zhu-Li"*.


<!-- References -->

[bats-gh]: https://github.com/sstephenson/bats
[envsubst-hp]: https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html
[gettext-hp]: https://www.gnu.org/software/gettext/
[coreutils-hp]: http://www.gnu.org/software/coreutils/
[util-linux-hp]: https://www.kernel.org/pub/linux/utils/util-linux/
[sed-hp]: https://www.gnu.org/software/sed/
[wikia-varrick]: http://avatar.wikia.com/wiki/Iknik_Blackstone_Varrick
[wikia-zhu-li]: http://avatar.wikia.com/wiki/Zhu_Li_Moon
[gplv3]: https://www.gnu.org/licenses/gpl.txt
[varrick-gh]: https://github.com/ztombol/varrick
[git-contrib]: https://github.com/git/git/blob/master/Documentation/SubmittingPatches
[gh-markdown]: https://help.github.com/articles/github-flavored-markdown/
[ronn-hp]: https://rtomayko.github.io/ronn/
[liberation-fedora]: https://fedorahosted.org/liberation-fonts/
[sil-ofl]: http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=OFL
[local-liberation-license]: docs/src/css/fonts/liberation/LICENSE

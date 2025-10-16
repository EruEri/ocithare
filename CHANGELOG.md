# CHANGELOG

## [0.18.0]
- [cithare-input: add option to read the master from stdin]\:
    - Add -0 option to read the master password from stdin 
        (allows piping the master password).
- [cithare-generate-password: Add option to exclude all character from a string]
    - Add -E option to exclude characters in string from generated password 
        (avoid repeating -e option).

## [0.17.0]:
- [password field: add comment field to a password entry]\:
    - Add a `comment` field to a password entry. (No Breaking change)
    - cithare-\*: add options to handle comment.
        - CEVEATS: comments can not be used to filter a match.
- [regex handling]\:
    - pkg: new dependancy: Re
        - use Re instead of builtin Str
    - string without -r flag matches substring instead of exact
    - string wit -r flag matches using posix regex.

## [0.16.0]:
- [new subcommands]\:
    - cithare-diff
    - cithare-merge
- renaming:
    - rename: cithare-delete -> cithare-remove

## [0.15.1]
- [cithare-add]:
    - Add -p option (like cithare-export) to copy the newly created password to the pasteboard.
    - Add **cithare-add** examples.
- [cithare-add]:
    - Rely on cmdliner to handle mutual exclusion of -r and -R (the logical is unchanged though)

## [0.15.0]
- [cithare-add]\:
    - Add yes/no flags to answer yes/no to cithare-add questions.
    - Change the replace behaviour.
        - -r -> -R (replace or add)
        - -r (Replace only if an entry is matched)
    - misc : change some prompts formating.
- [cithare-generate-password]\:
    - Exclude space by default.
    - Add --space option to re-enable it.

## [0.14.1]
- [cithare-export]\: 
    - change non-macos paste option : -x -> -p
    - invoke wl-copy if XDG_SESSION_TYPE is wayland, xclip otherwise

## [0.14.0]
- [new subcommand: cithare-info]
- [cithare-export]\: Fix write to xclip if the password contains an \'
- [cithare-show]\: 
    - Hide all fields by default
    - Remove option (display-time)
    - add options to display each field
    - add a first line
- [cithare-generate-password]\: Ensure if possible that at least one ocurrence of the selected charset exist.

## [0.13.0]
- [misc: cithare exit code]\: Change cithare exit code
- [cithare-generate-password]\: raise default password length: 8 -> 16
- [cithare-add]\: remove restriction: at least username or mail must be set.
- [cithare-export: field option](https://codeberg.org/EruEri/ocithare/pulls/15)
- [cithare-update: new subcommand](https://codeberg.org/EruEri/ocithare/pulls/14)
- [misc: install instructions](https://codeberg.org/EruEri/ocithare/pulls/13)
- [env variable: Add `CITHARE_HOME` env variable](https://codeberg.org/EruEri/ocithare/pulls/12)

## [0.12.0]
- [cithare-show: Can read from a .citharerc file from positional arg](https://codeberg.org/EruEri/ocithare/pull/10)
- [cithare-add: Fix replace option by merging information with the old password record](https://codeberg.org/EruEri/ocithare/pull/9)

## [0.11.0-1]
- [Fix opam build dependancies](https://codeberg.org/EruEri/ocithare/pull/8)

## [0.11.0]
- [cithare-{delete,export}: Add name and mail options to narrow down the matching](https://codeberg.org/EruEri/ocithare/pull/6)

## [0.10.1]
- [cithare-add: Add length as a trigger for automic password generation](https://codeberg.org/EruEri/ocithare/pull/4)

## [0.10.0]
- [cithare-add: Geneate password with the option of cithare-generate-password](https://codeberg.org/EruEri/ocithare/pull/2)

## [0.9.1]
- [Clipboard paste other than macOS](https://codeberg.org/EruEri/ocithare/pull/1) 

## [0.9.0]
- Initial Release
- Breaking change with [0.8.0]
    - Key encryption algorithm
- Split show subcommand:
    - Export:
        - option -w will now print to stdout if --paste is not present
            - Previously: Do nothing
    - Show
- Change option to the generate-password subcommand
- Password file is named ```.citharerc``` instead of ````.citharecf```

## [0.8.0]
- [cithare 0.8.0](https://git.nayuri.fr/EruEri/cithare)

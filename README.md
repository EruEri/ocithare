# ocithare

The source code is now hosted on [Codeberg](https://codeberg.org/EruEri/ocithare)

- ocithare is the rewrite of [cithare](https://git.nayuri.fr/EruEri/cithare), which is written in swift, in OCaml
- ocithare is a command line password manager


## How to build
First you will need to install those opam packages.

```
$ opam install dune digestif mirage-crypto ppx_deriving_yojson yojson cmdliner re
```


By default the prefix install is `/usr/local`. So cithare binary is installed in `/usr/local/bin` and the man pages in `/usr/local/share/man`. 
But the `make install` rule reacts to 3 variables:
- `PREFIX`: 
  - default: `/usr/local`
- `BINDIR`: 
    - default: `$(PREFIX)/bin`
- `MANDIR`: 
    - default: `$(PREFIX)/share/man`

```sh
$ git clone https://codeberg.org/EruEri/ocithare
$ cd ocithare
$ make
$ make install
```

## Initialization

To start with cithare, you first need to initialize it

```
$ cithare init --help
NAME
       cithare-init - Initialize cithare

SYNOPSIS
       cithare init [--force] [--import=<file>] [OPTION]…

DESCRIPTION
       Initialize cithare by creating $XDG_DATA_HOME/cithare/.citharerc file

       If cithare has already been initialized, cithare init will raise an
       exception unless the --force option is given which will delete the
       existing cithare installation

       To import existing passwords, use --import <FILE>
       Imported passwords must be formatted as a json according to the
       following structure :

       passwords: array of passwords
           password : object
             website: string (required)
             username : string (optional)
             mail : string (optional)
             password : (required)

       Passwords exported throught cithare-export(1) can be imported

OPTIONS
       -f, --force
           Force the initialisation

       -i <file>, --import=<file>
           Initialize with a formatted password file
```

## Add

To add to a password, use the ```add``` subcommand

```
$ cithare add --help
NAME
       cithare-add - Add passwords to cithare

SYNOPSIS
       cithare add [OPTION]…

DESCRIPTION
       Add passwords to cithare

       If one of the following option is provided -c, -d, -e, -l, -s, -u,
       --space, cithare-add(1) will automatically generate a password and the
       options to generate the password are the same that
       cithare-generate-password(1).

       cithare-add(1) is also used to update the password field of entries
       with the options -r and -R. Both can not be used at the same time. The
       option -R will try to replace a password for an existing entry but if
       no entry is matched, a new entry will be added whereas with -r, cithare
       will exit with a non success code if no entry is matched.

       By default, when a password is automatically generated with the
       required options, cithare-add(1) prints the generated password and
       waits the answer for a yes/no question. If --yes is given,
       cithare-add(1) does not ask the question neither prints the generated
       password.

OPTIONS
       -c <length>, --count=<length> (absent=16)
           Set the length of the generated password

       -d  Include digit set [0-9]

       -e <char>, --exclude=<char>
           Exclude <char> from character set

       -l  Include lowercase letter set [a-z]

       -m <mail>, --mail=<mail>
           Chosen <mail>

       -n <name>, --username=<name>, --name=<name>
           Chosen <name>

       --no
           Answer no to cithare yes/no questions without prompting

       -p, --paste
           Try to write the newly created password into the pastebord. If
           XDG_SESSION_TYPE is set to wayland, invoke wl-copy(1) otherwise
           invoke xclip(1) by targetting the clipboard X selection.

       -R, --replace-or-add
           Replace the password of an existing entry or create it

       -r, --replace
           Replace the password of an existing entry

       -s  Include all printable character that aren't a number or a letter

       --space
           Include the whitespace character

       -u  Include uppercased letter set [A-Z]

       -w <website>, --website=<website> (required)
           Chosen <website>

       -y, --yes
           Answer yes to cithare yes/no questions without prompting
```

The clipboard handling is plateform dependant.
- On macOS:
    - cithare is compiled against `AppKit` framework and use directly the `NSPasteboard` api.
- On other \*nix (FreeBSD, Linux, ...):
    - on wayland:
        - Invoke `wl-copy`
    - otherwier:
        - Invoke `xclip`
- On windows:
    - No tested

## Export

To select a password or export all the passwords into a file, use the ```export``` subcommand
```
$ cithare export --help
NAME
       cithare-export - Export passwords

SYNOPSIS
       cithare export [OPTION]…

DESCRIPTION
       cithare export retrieves passwords from cithare, either a field from
       one entry or export all the passwords stored in a json formatted file

       By default, cithare-export(1) exports the password field from an entry
       but it's possible to specify an other field with the -f option.
       To be exportable, the field value must not be none.

       -m and -n options further narrows down the matching.
       Narrow down the matching is mandatory if you try to retrieve a password
       from an entry where the website appears more than once.

       Regex option (ie. -r) if provided, treats individually website, name
       and mail as a regex string.

OPTIONS
       -f [<field>], --field[=<field>] (default=password) (required)
           Field to export. one of 'website', 'password', 'mail' or 'username'

       -m <mail>, --mail=<mail>
           Match the mail

       -n <name>, --username=<name>, --name=<name>
           Match the username

       -o <outfile>
           Export passwords as json into <outfile>

       -p, --paste
           Try to write the password into the pastebord. If XDG_SESSION_TYPE
           is set to wayland, invoke wl-copy(1) otherwise invoke xclip(1) by
           targetting the clipboard X selection.

       -r, --regex
           Treat each field as a regex string

       -w <website>, --website=<website>
           Match the website
```

## Show

To see all your registered password, ```show``` subcommand

```
$ cithare show --help
NAME
       cithare-export - Export passwords

SYNOPSIS
       cithare export [OPTION]…

DESCRIPTION
       cithare export retrieves passwords from cithare, either a field from
       one entry or export all the passwords stored in a json formatted file

       By default, cithare-export(1) exports the password field from an entry
       but it's possible to specify an other field with the -f option.
       To be exportable, the field value must not be none.

       -m and -n options further narrows down the matching.
       Narrow down the matching is mandatory if you try to retrieve a password
       from an entry where the website appears more than once.

       Regex option (ie. -r) if provided, treats individually website, name
       and mail as a regex string.

OPTIONS
       -f [<field>], --field[=<field>] (default=password) (required)
           Field to export. one of 'website', 'password', 'mail', 'username'
           or 'comment'

       -m <mail>, --mail=<mail>
           Match the mail

       -n <name>, --username=<name>, --name=<name>
           Match the username

       -o <outfile>
           Export passwords as json into <outfile>

       -p, --paste
           Try to write the password into the pastebord. If $XDG_SESSION_TYPE
           is set to wayland, invoke wl-copy(1) otherwise invoke xclip(1) by
           targetting the clipboard X selection.

       -r, --regex
           Treat each field as a regex string

       -w <website>, --website=<website>
           Match the website
```

# Warning

Even if your master password is never stored and all your password are encrypted, 
I don't know if the encryption method is neither good nor safe so use it at your own risk.

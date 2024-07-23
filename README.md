# ocithare

The source code is now hosted on [Codeberg](https://codeberg.org/EruEri/ocithare)

- ocithare is the rewrite of [cithare](https://git.nayuri.fr/EruEri/cithare), which is written in swift, in OCaml
- ocithare is a command line password manager


## How to build
First you will need to install those opam packages.

```
$ opam install dune xdg cmdliner dune-configurator cryptokit yojson ppx_deriving_yojson
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
       cithare init [--force] [--import=<FILE>] [OPTION]…

OPTIONS
       -f, --force
           Force the initialisation

       -i <FILE>, --import=<FILE>
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

       At least --website or --username must be present

       If one of the following option is provided -c, -d, -e, -l, -s, -u,
       cithare-add(1) will automatically generate a password and the options
       to generate the password are the same than cithare-generate-password(1)

OPTIONS
       -c <LENGTH>, --count=<LENGTH> (absent=8)
           Set the length of the generated password

       -d  Include digit set [0-9]

       -e <Char>, --exclude=<Char>
           Exclude <Char> from character set

       -l  Include lowercase letter set [a-z]

       -m MAIL, --mail=MAIL
           Chosen MAIL

       -n NAME, --username=NAME, --name=NAME
           Chosen NAME

       -r, --replace
           Replace a password

       -s  Include all printable character that aren't a number or a letter

       -u  Include uppercased letter set [A-Z]

       -w WEBSITE, --website=WEBSITE (required)
           Chosen WEBSITE
```

## Export

To select a password or export all the passwords into a file, use the ```export``` subcommand
```
$ cithare export --help
NAME
       cithare-export - Export passwords

SYNOPSIS
       cithare export [OPTION]…

DESCRIPTION
       Export passwords

OPTIONS
       -o OUTFILE
           Export passwords as json into OUTFILE

       -p, --paste
           Write the password into the pasteboard

       -r, --regex
           Find the website by matching its name

       -w WEBSITE, --website=WEBSITE
           Specify the site
```

## Show

To see all your registered password, ```show``` subcommand

```
$ cithare show --help
NAME
       cithare-show - Display entries

SYNOPSIS
       cithare show [OPTION]… [<CITHARE-CIPHER>]

DESCRIPTION
       cithare-show(1) shows entry records in your terminal in a table format
       and by default hides all the fields. Use -w, -u, -m and --password to
       respectively display in plain text the website, username, mail and
       password

       cithare-show(1) can take a file as parameter. If provided,
       cithare-show(1) will read the content of this file instead of the
       usual .citharerc

ARGUMENTS
       <CITHARE-CIPHER>
           Use <CITHARE-CIPHER> instead

OPTIONS
       -m, --mail
           Show plain mail

       --password
           Show plain passwords

       -u, -n, --username
           Show plain username

       -w, --website
           Show plain website
```

# Warning

Even if your master password is never stored and all your password are encrypted, I don't know if the encryption method is neither good nor safe so use it at your own risk.
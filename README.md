# ocithare


- ocithare is the rewrite of [cithare](https://github.com/EruEri/cithare), which is written in swift, in OCaml
- ocithare is a command line password manager




## How to build
- First you will need to install those opam packages.

```
$ opam install dune xdg cmdliner dune-configurator cryptokit yojson ppx_deriving_yojson
```
- And
```
$ git clone https://github.com/EruEri/ocithare
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

OPTIONS
       -a LENGTH, --autogen=LENGTH
           Generate an automatic password with a given length

       -m MAIL, --mail=MAIL
           Chosen MAIL

       -r, --replace
           Replace a password

       -u USERNAME, --username=USERNAME
           Chosen USERNAME

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

- Currently the **paste** is only available on macOS

## Show

To see all your registered password, ```show``` subcommand

```
$ cithare show --help
NAME
       cithare-show - Display passwords

SYNOPSIS
       cithare show [--display-time=DURATION] [--show-password] [OPTION]…

OPTIONS
       -d DURATION, --display-time=DURATION
           Show password to stdout for DURATION

       --show-password
           Show plain passwords
```

# Warning

Even if your master password is never stored and all your password are encrypted, I don't know if the encryption method is neither good nor safe so use it at your own risk.
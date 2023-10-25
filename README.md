# ocithare


ocithare is the rewrite of [cithare](https://github.com/EruEri/cithare), which is written in swift, in OCaml
ocithare is a command line password manager

## How to build

```
$ git clone https://github.com/EruEri/ocithare
$ cd ocithare
$ make (or ```dune build```)
$ make install (or ```dune install```)
```

## Initialization

To start with cithare, you first need to initialize it

```
$ cithare init --help
OVERVIEW: Initialize the password Manager

USAGE: cithare init [--force]

OPTIONS:
  -f, --force             Force the initialization
  -h, --help              Show help information.
```

## Add

To add to a password, use the ```add``` subcommand

```
$ cithare add --help
OVERVIEW: Add a new password into the password Manager

USAGE: cithare add [--replace] --web-site <web-site> [--username <username>] [--mail <mail>] [--auto-gen <auto-gen>]

OPTIONS:
  -r, --replace           Use in order to replace a password
  -w, --web-site <web-site>
  -u, --username <username>
  -m, --mail <mail>
  --auto-gen <auto-gen>   Generate an automatic password with a given lenght
  -h, --help              Show help information.

```

## Show

To show the password, paste it in your pasteboard or export all the passwords into a file use the ```show``` subcommand

```
$ cithare show --help
OVERVIEW: Show password

USAGE: cithare show [--display-time <display-time>] [--website <website>] [--regex] [--output <output>] [--paste]

OPTIONS:
  -d, --display-time, --dt <display-time>
                          Display duration in seconds (default: 5)
  -w, --website <website> Specify the site
  -r, --regex             Find the website by matching its name
  -o, --output <output>   Output file
  -p, --paste             Write the password into the pasteboard
  -h, --help              Show help information.
```

# Warning

Even if your master password is never stored and all your password are encrypted, I don't know if the encryption method is neither good nor safe so use it at your own risk.
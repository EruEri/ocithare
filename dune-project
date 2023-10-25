(lang dune 3.10)

(name ocithare)

(version "0.9.0")

(generate_opam_files true)

(source
 (github EruEri/ocithare))

(authors "EruEri")

(maintainers "EruEri")

(license GPL-3.0)

; (documentation https://url/to/documentation)

(package
 (name ocithare)
 (synopsis "A commandline password manager")
 (depends ocaml dune cryptokit yojson cmdliner xdg)
 (tags
  (password-manager)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project

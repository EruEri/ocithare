(lang dune 3.10)

(name ocithare)

(version "0.11.0-1")

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
 (depends dune xdg str-base dune-build-info (ocaml (>= "4.13.0"))  (cryptokit (>= "1.17")) (ppx_deriving_yojson (>= "3.5.3")) (yojson (>= "2.0.0")) (cmdliner (>= "1.1.0")) )
 (tags
  (password-manager cli)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project

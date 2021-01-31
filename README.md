Cmdliner cheatsheet
==

[Cmdliner](https://erratique.ch/software/cmdliner) is a
feature-complete library for parsing the command line of an OCaml
program. It supports long options, short options, subcommands, and custom
argument formats like you've always wanted. The output of `--help`
is similar to a man page, see for example `opam --help`.
Cmdliner is to be used instead of the `Arg` module from the standard library.

This cheatsheet is a compact reference for common patterns.

A complete option specification
--

```ocaml
let num_cores_term =
  let default = 1 in
  let info =
    Arg.info ["j"; "num-cores"]  (* '-j' and '--num-cores' will be synonyms *)
      ~docv:"NUM"
      ~doc:"Example of optional value with a default.
            The value of \\$\\(docv\\) is $(docv)."
  in
  Arg.value (Arg.opt Arg.int default info)
```

Optional value without a default
--

```ocaml
Arg.value (Arg.opt (Arg.some Arg.string) None info)
```

Optional value with a default
--

```ocaml
let default = 1 in
Arg.value (Arg.opt Arg.int default info)
```

List of values defaulting to empty list
--

```ocaml
Arg.value (Arg.pos_all Arg.file [] info)
```

List of values defaulting to non-empty list
--

```ocaml
let default = ["."] in
Arg.value (Arg.pos_all Arg.file default info)
```

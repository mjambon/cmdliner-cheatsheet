Cmdliner cheatsheet
==

[Cmdliner](https://erratique.ch/software/cmdliner) is a
feature-complete library for parsing the command line of an OCaml
program. It supports long options, short options, subcommands, and custom
argument formats like you've always wanted. The output of `--help`
is similar to a man page, see for example `opam --help`.
Cmdliner is to be used instead of the `Arg` module from the standard library.

This cheatsheet is a compact reference for common patterns.

Anonymous argument required at specific position
--

Anonymous argument optional at specific position
--

Any number of anonymous arguments
--

Simple flag
--

```
$ foo             -> false
$ foo --no-exe    -> true
```

```ocaml
let no_exe_term =
  let info =
    Arg.info ["no-exe"]
      ~doc:"Example of flag, which sets a boolean to true."
  in
  Arg.value (Arg.flag info)
```

Complete optional argument specification
--

```
$ foo                  -> 1
$ foo -j 8             -> 8
$ foo --num-cores 8    -> 8
```

```ocaml
let num_cores_term =
  let default = 1 in
  let info =
    Arg.info ["j"; "num-cores"]  (* '-j' and '--num-cores' will be synonyms *)
      ~docv:"NUM"
      ~doc:"Example of an optional value with a default.
            The value of \\$\\(docv\\) is $(docv)."
  in
  Arg.value (Arg.opt Arg.int default info)
```

Optional value without a default
--

```
$ foo                 -> None
$ foo --bar thing     -> Some "thing"
```

```ocaml
Arg.value (Arg.opt (Arg.some Arg.string) None info)
```

Optional value with a default
--

```
$ foo             -> 1
$ foo --bar 8     -> 8
```

```ocaml
let default = 1 in
Arg.value (Arg.opt Arg.int default info)
```

List of values defaulting to empty list
--

```
$ foo                           -> []
$ foo --bar elt1 --bar elt2     -> ["elt1"; "elt2"]
```

```ocaml
Arg.value (Arg.pos_all Arg.string [] info)
```

List of values defaulting to non-empty list
--

```
$ foo                           -> ["."]
$ foo --bar elt1 --bar elt2     -> ["elt1"; "elt2"]
```

```ocaml
let default = ["."] in
Arg.value (Arg.pos_all Arg.file default info)
```

Predefined argument converters
--

* no conversion: `Arg.string`
* literal `true` or `false`: `Arg.bool`. See `Arg.flag` for a simple
  flag that means "true".
* single byte: `Arg.char`
* numeric types:
  - `Arg.int`
  - `Arg.float`
  - `Arg.int32`
  - `Arg.int64`
  - `Arg.nativeint`
* enum-like custom mapping: `Arg.enum ["foo", Foo; "bar", Bar]`
* any "file" that must exist, including directories: `Arg.file`
* directory that must exist: `Arg.dir`
* any file that must exist, other than a directory: `Arg.non_dir_file`
* comma-separated values:
  - `Arg.list Arg.int`
  - `Arg.array Arg.string`
* custom value splitting:
  - `Arg.list ~sep:';' Arg.int`
  - `Arg.array ~sep:'.' Arg.string`

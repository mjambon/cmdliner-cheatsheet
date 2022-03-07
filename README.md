Cmdliner cheatsheet [![CircleCI badge](https://circleci.com/gh/mjambon/cmdliner-cheatsheet.svg?style=svg)](https://app.circleci.com/pipelines/github/mjambon/cmdliner-cheatsheet)
==

[Cmdliner](https://erratique.ch/software/cmdliner) is a
feature-complete library for parsing the command line from an OCaml
program. The output of `--help` is similar to a man page, see for
example `opam --help`.
Cmdliner is to be used instead of the `Arg` module from the standard library.

This cheatsheet is a compact reference for common patterns.

[Two sample programs](src) are provided for exploration
purposes or as templates for new projects. Clone this git repository
and test it as follows (requires `dune` and of course `cmdliner`):
```
$ make
$ make test

$ ./bin/cmdliner-demo-arg --help
$ ./bin/cmdliner-demo-arg             # try with some options
$ ./bin/cmdliner-demo-subcmd
$ ./bin/cmdliner-demo-subcmd subcmd1  # try with some options
```

Anonymous argument at specific position
--

```
$ foo 42 -j 8 data.csv        -> Some "data.csv"
      ^^      ^^^^^^^^
      0       1
```

Optional argument at a specific position:
```ocaml
let input_file_term =
  let info =
    Arg.info []  (* list must be empty for anonymous arguments *)
      ~doc:"Example of an anonymous argument at a fixed position"
  in
  Arg.value (Arg.pos 1 (Arg.some Arg.file) None info)
```

Required argument at a specific position:
```ocaml
let input_file_term =
  let info =
    Arg.info []  (* list must be empty for anonymous arguments *)
      ~doc:"Example of an anonymous argument at a fixed position"
  in
  Arg.required (Arg.pos 1 (Arg.some Arg.file) None info)
```

Any number of anonymous arguments
--

```
$ foo                         -> []
$ foo a.csv b.csv c.csv       -> ["a.csv"; "b.csv"; "c.csv"]
```

```ocaml
Arg.value (Arg.pos_all Arg.file [] info)
```

Any number of anonymous arguments, defaulting to non-empty list
--

```
$ foo                         -> ["."]
$ foo a.csv b.csv c.csv       -> ["a.csv"; "b.csv"; "c.csv"]
```

```ocaml
let default = ["."] in
Arg.value (Arg.pos_all Arg.file default info)
```

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
      ~doc:"Example of a flag, which sets a boolean to true."
  in
  Arg.value (Arg.flag info)
```

Optional argument specification
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
      ~doc:"Example of an optional argument with a default.
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

Predefined argument converters
--

```
Raw argument        OCaml value        Converter

abc                 "abc"              Arg.string
true                true               Arg.bool
false               false              Arg.bool
x                   'x'                Arg.char
%                   '%'                Arg.char
123                 123                Arg.int
123                 123.               Arg.float
123.4               123.4              Arg.float
-1.2e6              -1.2e6             Arg.float
123                 123l               Arg.int32
123                 123L               Arg.int64
foo                 Foo                Arg.enum ["foo", Foo; "bar", Bar]
data.csv            "data.csv"         Arg.file (* path must exist *)
data/               "data/"            Arg.file (* path must exist *)
data/               "data/"            Arg.dir (* must be a folder *)
data.csv            "data.csv"         Arg.non_dir_file (* file must exist *)
foo.sock            "foo.sock"         Arg.non_dir_file (* file must exist *)
ab,c,d              ["ab"; "c"; "d"]   Arg.list Arg.string
17,42               [|17; 42|]         Arg.array Arg.int
ab:c:d              ["ab"; "c"; "d"]   Arg.list ~sep:':' Arg.string
```

Subcommands
--

```
$ foo                 # displays root help page
$ foo --help          # also displays root help page
$ foo subcmd1         # returns 'Subcmd1 { ... }'
$ foo subcmd2 --bar   # returns 'Subcmd2 { ... }'
```

Each subcommand is defined as if it were its own command. They are
then combined into one. See demo in [src](src).

```ocaml
...

type cmd_conf =
  | Subcmd1 of subcmd1_conf
  | Subcmd2 of subcmd2_conf

...

let subcmd1_info =
  Term.info "subcmd1"
    ~doc:subcmd1_doc
    ~man:subcmd1_man

...

let subcmd1 = (subcmd1_term, subcmd1_info)
let subcmd2 = (subcmd2_term, subcmd2_info)

let root_term = Term.ret (Term.const (`Help (`Pager, None)))
let root_subcommand = (root_term, root_info)

let parse_command_line () : cmd_conf =
  match Term.eval_choice root_subcommand [subcmd1; subcmd2] with
  | `Error _ -> exit 1
  | `Version | `Help -> exit 0
  | `Ok conf -> conf
```

Upgrade to cmdliner 1.1.x
--

```
Error (alert deprecated): Cmdliner.Term.info
Use Cmd.info instead.
```

```
Error (alert deprecated): Cmdliner.Term.eval
Use Cmd.v and one of Cmd.eval* instead.
```

```
Error (alert deprecated): Cmdliner.Term.eval_choice
Use Cmd.group and one of Cmd.eval* instead.
```

If you're getting the errors/warnings above after having upgraded
cmdliner to version >= 1.1.x, check out
[this diff](https://github.com/mjambon/cmdliner-cheatsheet/commit/8bfd6a87c57cc1445e5d338ef40711a9782ba524)
showing a way to migrate. The main `run` function that contains the
business logic of your application is now passed around as an
argument, which isn't great.
[Let us know](https://github.com/mjambon/cmdliner-cheatsheet/issues)
if you know an easier way to separate command-line parsing
from the rest of the application.

Conclusion
--

Cmdliner offers various advanced and useful features that are not
covered here. Please consult the [official
documentation](https://erratique.ch/software/cmdliner/doc/Cmdliner.html).

(*
   A minimal program demonstrating how to implement subcommands with cmdliner.

   We're implementing two subcommands 'subcmd1' and 'subcmd2' to be used as:

     $ cmdliner-demo-subcmd subcmd1 --foo  # doesn't support '--bar'
     $ cmdliner-demo-subcmd subcmd2 --bar  # doesn't support '--foo'

   For a generic template and examples on specifying different types
   of arguments, consult 'Demo_arg_main.ml'.
*)

open Printf

(* Provide 'Term', 'Arg', and 'Manpage' modules. *)
open Cmdliner

type subcmd1_conf = {
  foo: bool;
}

type subcmd2_conf = {
  bar: bool;
}

(*
   The result of parsing the command line successfully.
*)
type cmd_conf =
  | Subcmd1 of subcmd1_conf
  | Subcmd2 of subcmd2_conf

(*
   Do something with the parsed command line.
*)
let run cmd_conf =
  match cmd_conf with
  | Subcmd1 conf ->
      printf "\
subcmd1 configuration:
  foo: %B
"
        conf.foo
  | Subcmd2 conf ->
      printf "\
subcmd2 configuration:
  bar: %B
"
        conf.bar

(*** Define different kinds of arguments and options (see other demo) ***)

let foo_term =
  let info =
    Arg.info ["foo"]
      ~doc:"Enable the foo!"
  in
  Arg.value (Arg.flag info)

let bar_term =
  let info =
    Arg.info ["bar"]
      ~doc:"Enable the bar!"
  in
  Arg.value (Arg.flag info)

(*** Putting together subcommand 'subcmd1' ***)

let subcmd1_term run =
  let combine foo =
    Subcmd1 { foo } |> run
  in
  Term.(const combine
        $ foo_term
       )

let subcmd1_doc = "[some headline for subcmd1]"

let subcmd1_man = [
  `S Manpage.s_description;
  `P "[multiline overview of subcmd1]";
]

let subcmd1 run =
  let info =
    Cmd.info "subcmd1"
      ~doc:subcmd1_doc
      ~man:subcmd1_man
  in
  Cmd.v info (subcmd1_term run)

(*** Putting together subcommand 'subcmd2' ***)

let subcmd2_term run =
  let combine bar =
    Subcmd2 { bar } |> run
  in
  Term.(const combine
        $ bar_term
       )

let subcmd2_doc = "[some headline for subcmd2]"

let subcmd2_man = [
  `S Manpage.s_description;
  `P "[multiline overview of subcmd2]";
]

let subcmd2 run =
  let info =
    Cmd.info "subcmd2"
      ~doc:subcmd2_doc
      ~man:subcmd2_man
  in
  Cmd.v info (subcmd2_term run)

(*** Putting together the main command ***)

let root_doc = "[some headline for the main command]"

let root_man = [
  `S Manpage.s_description;
  `P "[multiline overview of the main command]";
]

(*
   Use the built-in action consisting in displaying the help page.
*)
let root_term =
  Term.ret (Term.const (`Help (`Pager, None)))

let root_info =
  Cmd.info "cmdliner-demo-subcmd"
    ~doc:root_doc
    ~man:root_man

(*** Parse the command line and do something with it ***)

let subcommands run = [
  subcmd1 run;
  subcmd2 run;
]

(*
     $ cmdliner-demo-subcmd           -> parsed as root subcommand
     $ cmdliner-demo-subcmd --help    -> also parsed as root subcommand
     $ cmdliner-demo-subcmd subcmd1   -> parsed as 'subcmd1' subcommand

   If there is a request to display the help page, it displayed at this point,
   returning '`Help'.

   Otherwise, 'conf' is returned to the application.
*)
let parse_command_line_and_run (run : cmd_conf -> unit) =
  Cmd.group root_info (subcommands run) |> Cmd.eval |> exit

let main () =
  parse_command_line_and_run run

let () = main ()

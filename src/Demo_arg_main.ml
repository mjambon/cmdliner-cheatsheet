(*
   Source code for the cmdliner-cheatsheet executable.
   This can serve as a template for new programs.

   This sample program exercises various features of cmdliner. It
   can be compiled and run to check how the various options work.

   See also 'Demo_subcmd_main.ml' for how to implement subcommands.
*)

open Printf

(* Provide the 'Arg', 'Term', and 'Manpage' modules. *)
open Cmdliner

(*
   We store the result of parsing the command line into a single 'conf'
   record of the following type.
*)
type conf = {
  input_file: string option;
  num_cores: int; (* matches long option name "--num-cores" for consistency *)
  user_name: string option;
  tags: string list;
}

(*
   The core of the application.
*)
let run conf =
  printf "\
Configuration:
  input file: %s
  number of cores: %i
  user name: %s
  tags: %s
"
    (match conf.input_file with
     | None -> "none"
     | Some s -> sprintf "%S" s)
    conf.num_cores
    (match conf.user_name with
     | None -> "none"
     | Some s -> sprintf "%S" s)
    (sprintf "[%s]" (List.map (sprintf "%S") conf.tags
                     |> String.concat ", "))

(************************* Command-line management *************************)

(*
   For each kind of command-line argument, we define a "term" object.
*)

let input_file_term =
  let info =
    Arg.info []  (* list must be empty for anonymous arguments *)
      ~docv:"FILE"
      ~doc:"Example of an anonymous argument at a fixed position."
  in
  Arg.value (Arg.pos 0 (Arg.some Arg.file) None info)

let num_cores_term =
  let default = 1 in
  let info =
    Arg.info ["j"; "num-cores"]  (* '-j' and '--num-cores' will be synonyms *)
      ~docv:"NUM"
      ~doc:"Example of an optional argument with a default.
            The value of \\$\\(docv\\) is $(docv)."
  in
  Arg.value (Arg.opt Arg.int default info)

let user_name_term =
  let info =
    Arg.info ["u"; "user-name"]
      ~docv:"NAME"
      ~doc:"Example of an optional argument without a default."
  in
  Arg.value (Arg.opt (Arg.some Arg.string) None info)

let tag_term =
  let info =
    Arg.info []
      ~docv:"TAG"
      ~doc:"Example of a list of anonymous arguments."
  in
  Arg.value (Arg.pos_all Arg.string [] info)

(*
   Combine the values collected for each kind of argument into a single
   'conf' object.

   Some merging and tweaking can be useful here but most often
   we just map each argument to its own record field.
*)
let cmdline_term =
  let combine input_file num_cores user_name tags =
    let only_tags =
      match tags with
      | [] -> []
      | _input_file :: tags -> tags
    in
    {
      input_file;
      num_cores;
      user_name;
      tags = only_tags;
    }
  in
  Term.(const combine
        $ input_file_term
        $ num_cores_term
        $ user_name_term
        $ tag_term
       )

(*
   Inspirational headline for the help/man page.
*)
let doc =
  "showcase cmdliner features"

(*
   The structure of the help page.
*)
let man = [
  (* 'NAME' and 'SYNOPSIS' sections are inserted here by cmdliner. *)

  `S Manpage.s_description;  (* standard 'DESCRIPTION' section *)
  `P "Multi-line, general description goes here.";
  `P "This is another paragraph.";

  (* 'ARGUMENTS' and 'OPTIONS' sections are inserted here by cmdliner. *)

  `S Manpage.s_examples; (* standard 'EXAMPLES' section *)
  `P "Here is some code:";
  `Pre "let four = 2 + 2";

  `S Manpage.s_authors;
  `P "Your Name Here <yourname@example.com>";

  `S Manpage.s_bugs;
  `P "Contribute documentation improvements at
      https://github.com/mjambon/cmdliner-cheatsheet";

  `S Manpage.s_see_also;
  `P "Cmdliner project https://erratique.ch/software/cmdliner/doc/Cmdliner"
]

(*
   Parse the command line into a 'conf' record. Exit early with appropriate
   exit codes if there was an error or if '--help' was requested.
*)
let parse_command_line () =
  let info =
    Term.info
      ~doc
      ~man
      "cmdliner-cheatsheet"  (* program name as it will appear in --help *)
  in
  match Term.eval (cmdline_term, info) with
  | `Error _ -> exit 1
  | `Version | `Help -> exit 0
  | `Ok conf -> conf

let safe_run conf =
  try run conf
  with
  | Failure msg ->
      eprintf "Error: %s\n%!" msg;
      exit 1
  | e ->
      let trace = Printexc.get_backtrace () in
      eprintf "Error: exception %s\n%s%!"
        (Printexc.to_string e)
        trace

let main () =
  Printexc.record_backtrace true;
  let conf = parse_command_line () in
  safe_run conf

let () = main ()

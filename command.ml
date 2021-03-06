type menu_command =
|Draft
|Start
|Exit
|Help

type game_command =
|Attack of (int * int)
|End
|HPow of int option
|PCard of int * int option
|LookH
|Concede
|Help

(*parses the input for the menu options and if it is not a valid input
 *it tells the user and asks for input again
 *)
let rec parse_menu () =
  let cmd = read_line () in
  let str = String.lowercase (String.trim cmd) in
  match str with
  |"draft" -> Draft
  |"start" -> Start
  |"exit" -> Exit
  |"help" -> Help
  |x -> Printf.printf "Invalid command\n"; parse_menu ()

(*Returns a string that is the second word in the input string
 * - str = the string being split
 * - first = the first word in the string
 *)
let next_word str first : string =
  if(String.contains str ' ') then
    let sp = String.index str ' ' in
    String.sub str (sp+1) ((String.length str)-(String.length first) - 1)
  else ""

(*returns a bool telling if the command inputted is for an attack*)
let valid_attack str : bool =
  let len  = String.length str in
  if(len > 6) then
    let cmd = String.sub str 0 6 in
    let num = String.trim (next_word str cmd) in
    if((cmd = "attack") && (String.contains num ' ')) then
      let space = String.index num ' ' in
      let si1 = String.sub num 0 space in
      let si2 = String.trim (next_word num si1) in
      let bi1 =
        try
          let _ = int_of_string si1 in true
        with
        |x -> false in
      let bi2 =
        try
          let _ = int_of_string si2 in true
        with
        |x -> false in
      (bi1 && bi2)
    else false
  else false

(*returns a bool telling if the command inputted is for playing a card*)
let valid_pcard str : bool =
  let len  = String.length str in
  if(len > 5) then
    let cmd = String.sub str 0 5 in
    if(cmd = "pcard") then
      let num = String.trim (next_word str cmd) in
      if(String.contains num ' ') then
        let space = String.index num ' ' in
        let si1 = String.sub num 0 space in
        let si2 = String.trim (next_word num si1) in
        let bi1 =
          try
            let _ = int_of_string si1 in true
          with
          |x -> false in
        let bi2 =
          try
            let _ = int_of_string si2 in true
          with
          |x -> false in
        (bi1 && bi2)
      else
        try
          let _ = int_of_string num in true
        with
        |x -> false
    else false
  else false

(*returns a bool telling if the command inputted is for hero power*)
let valid_hpow str : bool =
  let len  = String.length str in
  if(len > 4) then
    let cmd = String.sub str 0 4 in
    if(cmd = "hpow") then
      let num = String.trim (next_word str cmd) in
      try
        let _ = int_of_string num in true
      with
      |x -> false
    else false
  else false

(*parses the input for the game commands and if it is not a valid command
 *it tells the user and asks for input again
 *)
let rec parse_game () =
  let cmd = read_line () in
  let str = String.lowercase (String.trim cmd) in
  match str with
  |"end" -> End
  |"lookh" -> LookH
  |"concede" -> Concede
  |"help" -> Help
  |"hpow" -> HPow None
  |s when (valid_attack str) -> do_attack str
  |s when (valid_pcard str) -> do_pcard str
  |s when (valid_hpow str) -> do_hpow str
  |_ -> Printf.printf "Invalid command\n"; parse_game ()

(*output the attack command if input is valid attack input but ask for input
 *again if command is not a valid command
 *)
and do_attack str =
  let len  = String.length str in
  if(len > 6) then
    let cmd = String.sub str 0 6 in
    let num = String.trim (next_word str cmd) in
    if((cmd = "attack") && (String.contains num ' ')) then
      let space = String.index num ' ' in
      let si1 = String.sub num 0 space in
      let si2 = String.trim (next_word num si1) in
      let bi1 =
        try
          let _ = int_of_string si1 in true
        with
        |x -> false in
      let bi2 =
        try
          let _ = int_of_string si2 in true
        with
        |x -> false in
      if (bi1 && bi2) then
        let i1 = int_of_string si1 in
        let i2 = int_of_string si2 in
        Attack (i1,i2)
      else parse_game ()
    else parse_game ()
  else parse_game ()

(*output the pcard command if input is valid pcard input but ask for input again
 *if command is not a valid command
 *)
and do_pcard str =
  let len  = String.length str in
  if(len > 5) then
    let cmd = String.sub str 0 5 in
    if(cmd = "pcard") then
      let num = String.trim (next_word str cmd) in
      if(String.contains num ' ') then
        let space = String.index num ' ' in
        let si1 = String.sub num 0 space in
        let si2 = String.trim (next_word num si1) in
        let bi1 =
          try
            let _ = int_of_string si1 in true
          with
          |x -> false in
        let bi2 =
          try
            let _ = int_of_string si2 in true
          with
          |x -> false in
        if (bi1 && bi2) then
          let i1 = int_of_string si1 in
          let i2 = int_of_string si2 in
          PCard (i1, Some i2)
        else parse_game ()
      else
        let bi =
        try
          let _ = int_of_string num in true
        with
        |x -> false in
        if(bi) then PCard ((int_of_string num), None)
        else parse_game ()
    else parse_game ()
  else parse_game ()

(*output the hpow command if input is valid hpow input but ask for input again
 *if command is not a valid command
 *)
and do_hpow str =
  let len  = String.length str in
  if(len > 4) then
    let cmd = String.sub str 0 4 in
    let num = String.trim (next_word str cmd) in
    if(cmd = "hpow") then
      let bi =
        try
          let _ = int_of_string num in true
        with
        |x -> false in
      if(bi) then HPow (Some (int_of_string num))
      else parse_game ()
    else parse_game ()
  else parse_game ()
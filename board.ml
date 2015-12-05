open deck
open hero
open ai
open draft
open command

(* keep track of current mana available to player at a given time
 * max is the mana you start with next turn
 *)
type mana  = {
    max     : int ref;
    current : int ref;
}

(* mode defines whether or not it is player vs player or player vs ai *)
type mode   = |VSai |PVP

(* board keeps track of all the different aspects of the game at the current
 * state.
 * mode keeps track of game mode
 * p___Hero keeps track of which hero each player is using
 * p___HP is the current hitpoints of player
 * p___Hand is the list of cards in a player's hand
 * p___Board is the cards currently on each side of the board
 * p___Deck is each respective player's current deck
 * hUsed is whether or not the player used their hero power that turn
 * p___Mana is the mana for each player
 * turn is 0 or 1 depending on who's player's turn it is
 *)
type board = {
    mode      : mode;
    pOneHero  : hero;
    pTwoHero  : hero;
    pOneHP    : int ref;
    pTwoHP    : int ref;
    pOneHand  : card list ref;
    pTwoHand  : card list ref;  
    pOneBoard : card option array;
    pTwoBoard : card option array;
    pOneDeck  : deck ref;
    pTwoDeck  : deck ref;
    hUsed     : bool ref;
    pOneMana  : mana ref;
    pTwoMana  : mana ref;
    turn      : int ref;
}


(* ******************************************************************** *)

(* takes in deck ref and updates deck
	returns hand, updates the deck ref 
	to reflect n draws
	TODO: ADD CARD BURN EDIT SPEC TO TAKE IN HAND

*)
let draw_player d n = 
	let rec d1 n dk h acc =
		match draw dk with
		| None                    -> ([],[])
		| Some(_,_) when acc >= n -> (dk,h)
		| Some(x,y) -> d1 n x (y::h) (acc + 1)
	in
	let x = (d1 n (!d) [] 0) in
	d := fst x;
	snd x

(* Need to figure out how to check who goes first *)
let makeBoard (h1,d1) (h2,d2) m =
	let rand = Random.bool () in
	let pOneD = if rand then d1 else d2 in
	let pTwoD = if rand then d2 else d1 in
	{
	mode      = m;
	pOneHero  = if rand then h1 else h2;
	pTwoHero  = if rand then h2 else h1;
	pOneHP    = ref 30;
	pTwoHP    = ref 30;
	pOneHand  = ref (draw_player pOneD 3);
	pTwoHand  = ref (draw_player pTwoD 4);
	pOneBoard = make 7 (None);
	pTwoBoard = make 7 (None);
	pOneDeck  = pOneD;
	pTwoDeck  = pTwoD;
	hUsed     = ref false;
	pOneMana  = {max = ref 0; current = ref 0;};
	pTwoMana  = {max = ref 0; current = ref 0;};
	turn      = ref 0;
	}
(*returns the first possible place to put a new minion. 8 if full*)
let indexOpening pBoard: int = 
	let count = ref 8 in let _ =
	for x = 0 to Array.length pBoard - 1 
	do 
		if pBoard.(x) = None then 
		if x<(!count) then count:=x
	done in 
	!count

let printBoard boardState : unit =
	let printBoard boardState : unit =
    let pTurn = !boardState.turn mod 2 in
    let chk = pTurn = 1 in
    let plyr = if chk then boardState.pOneHero else boardState.pTwoHero in
    let plyrHP = if chk then !boardState.pOneHP else !boardState.pTwoHP in
    let plyrHand = if chk then !boardState.pOneHand else !boardState.pTwoHand in
    let plyrB = if chk then boardState.pOneBoard else boardState.pTwoBoard in
    let opp = if chk then boardState.pTwoHero else boardState.pOneHero in
    let oppHP = if chk then !boardState.pTwoHP else !boardState.pOneHP in
    let oppHand = if chk then !boardState.pTwoHand else !boardState.pOneHand in
    let oppB = if chk then boardState.pTwoBoard else boardState.pOneBoard in
    let heroPower = if !boardState.hUsed then "Unavailable" else "Available" in
    let prntCard c i =
        match c with
        | None    -> ()
        | Some(k) -> Printf.printf "(%i) %s" i (card_string k);
    in
    let prntArray a i =
        prntCard a.(0) i;
        prntCard a.(1) (i + 1);
        prntCard a.(2) (i + 2);
        prntCard a.(3) (i + 3);
        prntCard a.(4) (i + 4);
        prntCard a.(5) (i + 5);
        prntCard a.(6) (i + 6);
    in
    let rec prntList l i =
        match l with
        | []   -> ()
        | h::t -> Printf.printf "(%i) %s" i (card_string h);
                  prntList t (i + 1);
    in
    Printf.printf "Enemy Hand: %i\n\n" (List.length oppHand);
    Printf.printf "Enemy Hero: (%i)" (100 * (1 + pturn));
    Printf.printf " %s\n" (hero_string opp);
    Printf.printf "Enemy HP: %i\n" oppHP;
    Printf.printf "Enemy Board:\n";
    prntArray oppB 10;
    Printf.printf "\nYour Board:\n";
    prntArray plyrB 0;
    Printf.printf "Your HP: %i\n" plyrHP;
    Printf.printf "Your Hero: (%i)" (100 * (2 - pturn));
    Printf.printf " %s\n" (hero_string plyr);
    Printf.printf "Hero Power: %s\n" heroPower;
    Printf.printf "\nYour Hand:\n";
    prntList plyrHand 0
(* resolve effect , return None if something went wrong*)
let resolve_BC bS e : board option = 


(* returns array with stealth minions removed*)
let rm_stealth brd = 
    let f x = 
        match x with
        | None    -> None
        | Some(c) -> if !c.stealth then None else Some(c)
    Array.map f brd

let get_atk_c co = 
    match co with
    |None    -> 0
    |Some(x) -> !x.atk

let get_hp_c co =
    match co with
    |None    -> 0
    |Some(x) -> !x.hp

let inputAttack boardState (c,e) : unit = 
    let t = ref false in
    let f x = 
        match x with begin
        | None       -> None
        | Some(card) -> if card.taunt && !card.stealth then Some(card)
                        else if card.taunt then t:= true; Some(card) 
                        else None 
        end
    in
    (* sets t to true if there is a taunt and returns array of only
        taunted stuff then *)
    let check_taunt brd = let x = Array.map f brd in
        if !t then x else rm_stealth brd

    let invalid_board () = Printf.printf "Invalid Attack...\n";in
    try 
        if (!boardState.turn) mod 2 = 1 then begin
            let m = boardState.pOneBoard).(c) in
            let t_only = check_taunt boardState.pTwoBoard in
            if boardState.pOneBoard.(c) = None then invalid_board ();
            else
                if e = 200 && (not t) then begin
                    if boardState.pOneBoard.(c) = None then invalid_board ();
                    else boardState.pTwoHP := !boardState.pTwoHP - get_atk_c m;
                         boardState.pOneBoard.(c).stealth := false; 
                end 
                else if t_only.(e) = None then invalid_board ();
                else let d1 = get_atk_c m in
                     let d2 = get_atk_c t_only.(e) in
                     let h1 = get_hp_c m in
                     let h2 = get_hp_c t_only.(e) in
                    match boardState.pOneBoard.(c),boardState.pTwoBoard.(e) with
                     | Some(x),Some(y) -> x.hp := h1 - d2; y.hp := h2 - d1;
                                          x.stealth := false;
                                          if x.hp <= 0 then 
                                          boardState.pOneBoard.(c) <- None;
                                          if y.hp <= 0 then
                                          boardState.pTwoBoard.(e) <- None;
                     | _               -> invalid_board ()
        end else
            let m = boardState.pTwoBoard).(c) in
            let t_only = check_taunt boardState.pOneBoard in
            if boardState.pTwoBoard.(c) = None then invalid_board ();
            else
                if e = 100 && (not t) then begin
                    if boardState.pTwoBoard.(c) = None then invalid_board ();
                    else boardState.pOneHP := !boardState.pOneHP - get_atk_c m;
                        boardState.pTwoBoard.(c).stealth := false;  
                end 
                else if t_only.(e) = None then invalid_board ();
                else let d1 = get_atk_c m in
                     let d2 = get_atk_c t_only.(e) in
                     let h1 = get_hp_c m in
                     let h2 = get_hp_c t_only.(e) in
                    match boardState.pTwoBoard.(c),boardState.pOneBoard.(e) with
                     | Some(x),Some(y) -> x.hp := h1 - d2; y.hp := h2 - d1;
                                          x.stealth := false;
                                          if x.hp <= 0 then 
                                          boardState.pTwoBoard.(c) <- None;
                                          if y.hp <= 0 then
                                          boardState.pOneBoard.(e) <- None;
                     | _               -> invalid_board ()

    with
    | _ -> invalid_board ()


let inputEnd boardState input : board =
	todo kevin

let inputHPow boardState input : board =
    if !boardstate.hUsed = true then
        Printf.printf "You have already used your hero power this turn!\n"
    else 
        let mana = if (!boardState.turn mod 2) = 0 then
        boardState.pTwoMana.current 
        else
        boardState.pOneMana.current in
        if !mana = 0 then Printf.printf "You don't have enough mana.\n"
        else
            let player = if (!boardState.turn mod 2) = 0 then 
            boardState.pTwoHero else boardState.pOneHero in match player with
            |Mage ->
            |Paladin -> let index = indexOpening in 
                            if index = 8 then 
                                Printf.printf "Your board is full!\n"
                            else let new_card =
                            {name = "Silver Hand Recruit";
                            cost = 1;
                            hp = ref 1;
                            atk = ref 1;
                            effect = {description = "");
                                      efftype = None};
                            stealth = ref false;
                            taunt   = false;
                            ctype   = Zerg;} in 
                            if (!boardState.turn mod 2) = 0 then 
                            boardState.pTwoBoard.(index) <- Some(new_card);
                            boardState.pTwoMana.current:=
                                (!boardState.pTwoMana.current-2)
                            else boardState.pOneBoard.(index) <- Some(new_card)
            |Priest ->
            |Warlock ->  

(* takes in [ind] index of card you want, [lst] hand you draw from
    acc is the start index 
    returns: (card,newhand)*)
let rec get_crd ind lst acc =
    match lst with
    | _        with acc > 10    -> (empty_card (),[])
    | Some(c)::t with ind = acc -> 
        let fil x = Some(c) <> x in
        (c,List.filter fil lst)
    | h::t                -> get_crd ind lst (acc + 1)

let buff brd h a =
    

let inputPCard bS (x,op) : board = 
    let invalid_i () = Printf.printf "Invalid play...\n"; in
    let who = bS.turn mod 2 = 1 in
    let brd = if who then bS.pOneBoard else bS.pTwoBoard
    let ind = indexOpening brd
    in
    (* check if card is in hand *)
    let hnd       = if who then bS.pOneHand else bS.pTwoHand in
    let temp_hand = !hnd in
    let pMana = if who then bS.pOneMana else bS.pTwoMana in
    if x >= List.length (!hnd) then invalid_i (); else
    let new_hand = get_crd x temp_hand 0 in
    let play = fst new_hand in
    if play.cost > !pMana.current then invalid_i (); else
    if who then begin
        match play.ctype,play.effect.efftype with
        | Spell,eff -> 
            match eff with begin
            | None      -> pMana.current := !pMana.current - play.cost;
            | Draw(b,x) -> pMana.current := !pMana.current - play.cost;
                        
            | AoeE(x,y) -> pMana.current := !pMana.current - play.cost;

            |
            |
        | _ ,eff    ->
            match eff with
            | None -> if ind <= 6 then begin
                pMana.current := !pMana.current - play.cost;
                brd.(ind) <- Some(play);
                end else invalid_i ();

    end else
    (* p2stuff *)



let inputLookH boardState : unit =
	let player = if (!boardState.turn mod 2) = 0 then 
		!boardState.pTwoHand 
	else
		!boardState.pOneHand in 
	Printf.printf "Your hand contains:\n";
	let helper = function
	|[]->()
	|h::t-> Printf.printf "%s" (card_string h);helper t in
	helper player

let inputConcede boardState : unit =
	let player = !boardState.turn mod 2 in
	let playernum = if player = 0 then "Player 1" else "Player 2" in
	Printf.printf "%s Wins!" playernum

let inputGameHelp () : unit =
	Printf.printf "Type attack # # where the first # is 
		your minion and the second # is the opponents minion.\n";
	Printf.printf "This uses your card to attack the opponents minion.\n";
	Printf.printf "Type end to complete your turn. \n";
	Printf.printf "Type Hpow # if your hero power can target someone\n";
	Printf.printf "If it doesn't target just type Hpow.\n";
	Printf.printf "Type pcard # to play the card # in your hand.\n";
	Printf.printf "Type lookh to see your hand.\n";
	Printf.printf "Type concede to give up! The 
		game ends and your opponent wins.\n";
	Printf.printf "Type help to... I think you know what typing help does."

let menu () = 
	todo all

let actualGame (h1,d1) (h2,d2) m =
	let init = makeBoard (h1,d1) (h2,d2) m in
	let rec repl boardState : board =
		match boardState.mode with
		| PVP -> 
	in


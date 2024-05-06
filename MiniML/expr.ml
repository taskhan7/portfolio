(* 
                         CS 51 Final Project
                        MiniML -- Expressions
*)

(*......................................................................
  Abstract syntax of MiniML expressions 
 *)

type unop =
  | Negate
;;
    
type binop =
  | Plus
  | Minus
  | Times
  | Divide
  | Equals
  | LessThan
  | GreaterThan
;;

type varid = string ;;
  
type expr =
  | Var of varid                         (* variables *)
  | Num of int                           (* integers *)
  | Bool of bool                         (* booleans *)
  | Unop of unop * expr                  (* unary operators *)
  | Binop of binop * expr * expr         (* binary operators *)
  | Conditional of expr * expr * expr    (* if then else *)
  | Fun of varid * expr                  (* function definitions *)
  | Let of varid * expr * expr           (* local naming *)
  | Letrec of varid * expr * expr        (* recursive local naming *)
  | Raise                                (* exceptions *)
  | Unassigned                           (* (temporarily) unassigned *)
  | App of expr * expr                   (* function applications *)
;;
  
(*......................................................................
  Manipulation of variable names (varids) and sets of them
 *)

(* varidset -- Sets of varids *)
module SS = Set.Make (struct
                       type t = varid
                       let compare = String.compare
                     end ) ;;

type varidset = SS.t ;;

(* same_vars varids1 varids2 -- Tests to see if two `varid` sets have
   the same elements (for testing purposes) *)
let same_vars : varidset -> varidset -> bool =
  SS.equal;;

(* vars_of_list varids -- Generates a set of variable names from a
   list of `varid`s (for testing purposes) *)
let vars_of_list : string list -> varidset =
  SS.of_list ;;


(* free_vars exp -- Returns the set of `varid`s corresponding to free
   variables in `exp` *)
let rec free_vars (exp : expr) : varidset =
  let open SS in 
  match exp with
  | Var(x) -> add x empty                         
  | Num(_x) -> empty                     
  | Bool(_x) -> empty                         
  | Unop(_x, y) -> free_vars y              
  | Binop(_x, y, z) -> union (free_vars y) (free_vars z)       
  | Conditional(x, y, z) -> union (free_vars x) (union (free_vars y)(free_vars z))
  | Fun(x,y)  -> remove (x) (free_vars y)             
  | Let(x, y, z) -> union (remove (x)(free_vars z)) (free_vars y)         
  | Letrec(x, y, z) -> union (remove (x)(free_vars z)) (remove (x)(free_vars y))     
  | Raise -> empty                                
  | Unassigned -> empty                        
  | App(x, y) -> union (free_vars x) (free_vars y)
  ;;                   
  
(* new_varname () -- Returns a freshly minted `varid` constructed with
   a running counter a la `gensym`. Assumes no other variable names
   use the prefix "var". (Otherwise, they might accidentally be the
   same as a generated variable name.) *)

let new_varname : unit -> varid =
  let suffix = ref 1 in
  fun () -> let symbol = "var" ^ string_of_int !suffix in
             suffix := !suffix + 1;
             symbol ;;

(*......................................................................
  Substitution 

  Substitution of expressions for free occurrences of variables is the
  cornerstone of the substitution model for functional programming
  semantics.
 *)

(* subst var_name repl exp -- Return the expression `exp` with `repl`
   substituted for free occurrences of `var_name`, avoiding variable
   capture *)
let rec subst (var_name : varid) (repl : expr) (exp : expr) : expr =
  if (free_vars exp) != SS.empty then 
    match exp with
    | Var(x) -> if x = var_name then repl   
                                else Var(x)                   
    | Num(x) -> Num(x)                     
    | Bool(x) -> Bool(x)                         
    | Unop(x, y) -> Unop(x, (subst var_name repl y))             
    | Binop(x, y, z) -> Binop(x, (subst var_name repl y), (subst var_name repl z))      
    | Conditional(x, y, z) -> Conditional((subst var_name repl x), (subst var_name repl y), 
                              (subst var_name repl z))
    | Fun(x,y)  ->  if x = var_name then Fun(x,y)
                    else if not(SS.mem x (free_vars repl)) then
                        Fun(x, (subst var_name repl y)) 
                    else  
                        let z = new_varname() in
                        let z1 = Var(z) in
                        Fun(z, (subst var_name repl (subst x z1 y)))     
    | Let(x, y, z) -> if x = var_name then Let(x,(subst var_name repl y), z)
                      else if not(SS.mem x (free_vars repl)) then
                          Let(x, (subst var_name repl y), (subst var_name repl z) )
                      else 
                          let k = new_varname() in
                          let k1 = Var(k) in
                          Let(k, (subst var_name repl y), (subst var_name repl (subst x k1 z)))              
    | Letrec(x, y, z) -> if x = var_name then Letrec(x, y, z)
                         else if not(SS.mem x (free_vars repl)) then
                             Letrec(x, (subst var_name repl y), (subst var_name repl z) )
                         else 
                             let k = new_varname() in
                             let k1 = Var(k) in
                             Letrec(k, (subst var_name repl (subst x k1 y)), (subst var_name repl (subst x k1 z)))    
    | Raise -> Raise                                
    | Unassigned -> Unassigned                        
    | App(x, y) -> App((subst var_name repl x), (subst var_name repl y)) 
  else exp 
;;
     
(*......................................................................
  String representations of expressions
 *)

let unop_to_string (unop : unop) : string = 
  match unop with 
  | Negate -> "Negate" ;;

let unopcon_to_string (unop : unop) : string = 
  match unop with 
  | Negate -> "~-" ;;

let binop_to_string (binop : binop) : string = 
  match binop with 
  | Plus -> "Plus"
  | Minus -> "Minus"
  | Times -> "Times"
  | Divide -> "Divide"
  | Equals -> "Equals"  
  | LessThan -> "LessThan" 
  | GreaterThan -> "GreaterThan" ;;

let binopcon_to_string (binop : binop) : string = 
  match binop with 
  | Plus -> "+"
  | Minus -> "-"
  | Times -> "*"
  | Divide -> "/"
  | Equals -> "="  
  | LessThan -> "<" 
  | GreaterThan -> ">" ;;
   
(* exp_to_concrete_string exp -- Returns a string representation of
   the concrete syntax of the expression `exp` *)
let rec exp_to_concrete_string (exp : expr) : string =
  match exp with 
  | Var(x) -> x
  | Num(x) -> string_of_int(x)                    
  | Bool(x) -> string_of_bool(x)                    
  | Unop(x, y) -> unopcon_to_string(x) ^ exp_to_concrete_string(y)         
  | Binop(x, y, z) -> exp_to_concrete_string(y) ^ binopcon_to_string(x) 
                      ^ exp_to_concrete_string(z)      
  | Conditional(x, y, z) -> "if" ^ exp_to_concrete_string(x) ^ 
                            "then" ^ exp_to_concrete_string(y) ^
                            "else" ^ exp_to_concrete_string(z)
  | Fun(x, y) -> "fun" ^ x ^ "->" ^ exp_to_concrete_string(y)
  | Let(x, y, z)  -> "let" ^ x ^ "=" ^ exp_to_concrete_string(y) ^ "in" 
                     ^ exp_to_concrete_string(z)                    
  | Letrec(x, y, z)  -> "let rec" ^ x ^ "=" ^ exp_to_concrete_string(y) 
                         ^ "in" ^ exp_to_concrete_string(z) 
  | Raise -> "Raise"
  | Unassigned -> "Unassigned"                                                       
  | App(x,y) -> "(" ^ exp_to_concrete_string(x) ^ ")" ^ "(" 
                ^ exp_to_concrete_string(y) ^ ")"           
;;
     
(* exp_to_abstract_string exp -- Return a string representation of the
   abstract syntax of the expression `exp` *)
let rec exp_to_abstract_string (exp : expr) : string =
  match exp with 
  | Var(x) -> "Var(" ^ x ^ ")"
  | Num(x) -> "Num(" ^ string_of_int(x) ^ ")"                       
  | Bool(x) ->  "Bool(" ^ string_of_bool(x)  ^ ")"                   
  | Unop(x, y) -> "Unop(" ^ unop_to_string(x) ^ exp_to_abstract_string(y) ^ ")"          
  | Binop(x, y, z) -> "Binop(" ^ binop_to_string(x) ^ exp_to_abstract_string(y) 
                      ^ exp_to_abstract_string(z) ^ ")"          
  | Conditional(x, y, z) -> "Conditional(" ^ exp_to_abstract_string(x) ^ 
                            exp_to_abstract_string(y) ^ exp_to_abstract_string(z) ^ ")"  
  | Fun(x, y) -> "Fun(" ^ x ^ exp_to_abstract_string(y) ^ ")"     
  | Let(x, y, z)  -> "Let(" ^ x ^ exp_to_abstract_string(y) 
                                    ^ exp_to_abstract_string(z) ^ ")"                     
  | Letrec(x, y, z)  -> "Letrec(" ^ x ^ exp_to_abstract_string(y) 
                                      ^ exp_to_abstract_string(z) ^ ")"     
  | Raise -> "Raise"
  | Unassigned -> "Unassigned"                                                       
  | App(x,y) -> "App(" ^ exp_to_abstract_string(x) 
                ^ exp_to_abstract_string(y) ^ ")"               
;;

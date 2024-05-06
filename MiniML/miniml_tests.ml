(* Unit tests for the project :) *)
open Expr ;;
open Evaluation ;;
open CS51Utils ;;
open Absbook ;;

 (* Testing free_vars *)
let free_vars_test () = 
  let x = vars_of_list (["z"]) in
  unit_test (same_vars (x) (free_vars(Var("z")))) 
            "free_vars Var(x)" ;
  let x = vars_of_list ([]) in 
  unit_test (same_vars (x) (free_vars(Num(5)))) 
            "free_vars Num(x)" ;
  let x = vars_of_list ([]) in 
  unit_test (same_vars (x) (free_vars(Bool(true)))) 
            "free_vars Bool(x)" ;
  let x = vars_of_list (["z"]) in
  unit_test (same_vars (x) (free_vars(Unop(Negate, Var("z")))))
            "free_vars Unop with free var in expr" ;
  let x = vars_of_list ([]) in 
  unit_test (same_vars (x) (free_vars(Unop(Negate, Num(3))))) 
            "free_vars Unop with no free var" ;
  let x = vars_of_list (["z"; "m"]) in
  unit_test (same_vars (x) (free_vars(Binop(Plus, Var("z"), Var("m")))))
            "free_vars Binop with free var in expr" ;
  let x = vars_of_list ([]) in 
  unit_test (same_vars (x) (free_vars(Binop(Plus, Num(3), Num(3))))) 
            "free_vars Binop with no free var" ;
  let x = vars_of_list ([]) in 
  unit_test (same_vars (x) (free_vars(Unop(Negate, Binop(Plus, Num(3), Num(3)))))) 
            "free_vars unop and binop complex w/o" ;
  let x = vars_of_list (["z"]) in 
  unit_test (same_vars (x) (free_vars(Unop(Negate, Binop(Plus, Var("z"), Num(3)))))) 
            "free_vars unop and binop complex w" ;
  let x = vars_of_list (["z"]) in 
  unit_test (same_vars (x) (free_vars(Conditional(Var("z"), Num(2), Num(3))))) 
            "free_vars conditional w/ no free" ;
  let x = vars_of_list (["z"; "m"; "t"]) in 
  unit_test (same_vars (x) (free_vars(Conditional(Var("z"), Var("m"), Var("t"))))) 
            "free_vars conditional all free" ;
  let x = vars_of_list ([]) in 
  unit_test (same_vars (x) (free_vars(Fun("z", Unop(Negate, Var("z")))))) 
            "free_vars fun no free var" ;
  let x = vars_of_list (["m"]) in 
  unit_test (same_vars (x) (free_vars(Fun("z", Binop(Plus, Var("z"), Var("m")))))) 
            "free_vars fun one free var" ;   
  let x = vars_of_list (["z"]) in 
  unit_test (same_vars (x) (free_vars(Let("z", Unop(Negate, Var("z")), Num(4))))) 
            "free_vars let free var in 2nd expr" ;
  let x = vars_of_list (["m"; "z"]) in 
  unit_test (same_vars (x) (free_vars(Let("z", Binop(Plus, Var("m"), Var("z")), Num(4))))) 
            "free_vars let two free var" ;
  let x = vars_of_list ([]) in 
  unit_test (same_vars (x) (free_vars(Let("z", Binop(Plus, Num(2), Num(3)), Var("z"))))) 
            "free_vars let no free var" ;
  let x = vars_of_list ([]) in 
  unit_test (same_vars (x) (free_vars(Letrec("z", Unop(Negate, Var("z")), Num(4))))) 
            "free_vars letrec var in 2nd expr" ;
  let x = vars_of_list (["m"]) in 
  unit_test (same_vars (x) (free_vars(Letrec("z", Binop(Plus, Var("m"), Var("z")), Num(4))))) 
            "free_vars letrec two free var" ;
  let x = vars_of_list ([]) in 
  unit_test (same_vars (x) (free_vars(Letrec("z", Binop(Plus, Num(2), Num(3)), Var("z"))))) 
            "free_vars letrec no free var" ;
  let x = vars_of_list ([]) in 
  unit_test (same_vars (x) (free_vars(Raise))) 
            "free_vars raise" ;
  let x = vars_of_list ([]) in 
  unit_test (same_vars (x) (free_vars(Unassigned))) 
            "free_vars unassigned" ;
  let x = vars_of_list ([]) in 
  unit_test (same_vars (x) (free_vars(App((Fun("z", Binop(Plus, Var("z"), Num(1)))), Num(3))))) 
            "free_vars letrec no free var" ;;

(* Testing subst *)
let subst_test () = 
  unit_test (subst("z")(Num(2))(Var("z")) = Num(2))
            "subst binop var = varname" ;
  unit_test (subst("x")(Num(2))(Var("m")) = Var("m"))
            "subst binop var not = varname" ;
  unit_test (subst("x")(Num(2))(Num(2)) = Num(2))
            "subst num" ;
  unit_test (subst("x")(Num(2))(Bool(true)) = Bool(true))
            "subst bool" ;
  unit_test (subst("z")(Num(2))(Unop(Negate, Var("z"))) = Unop(Negate, Num(2)))
            "subst unop var = varname" ;
  unit_test (subst("z")(Num(2))(Unop(Negate, Var("m"))) = Unop(Negate, Var("m")))
            "subst unop var = varname" ;
  unit_test (subst("z")(Num(2))(Binop(Plus, Var("z"), Num(2))) = Binop(Plus, Num(2), Num(2)))
            "subst binop var = varname" ;
  unit_test (subst("x")(Num(2))(Binop(Plus, Var("z"), Num(2))) = Binop(Plus, Var("z"), Num(2)))
            "subst binop var not = varname" ; 
  unit_test (subst("x")(Num(2))(Conditional(Var("x"), Var("z"), Var("m"))) = Conditional(Num(2), Var("z"), Var("m")))
            "subst conditional one var = varname" ;
  unit_test (subst("x")(Num(2))(Conditional(Var("p"), Var("z"), Var("m"))) = Conditional(Var("p"), Var("z"), Var("m")))
            "subst conditional no var = varname" ;
  unit_test (subst("x")(Num(2))(Fun("x", Binop(Plus, Var("x"), Num(3)))) = Fun("x", Binop(Plus, Var("x"), Num(3))))
            "subst fun x = varname pt 2" ;
  unit_test (subst("y")(Num(2))(Fun("x", Binop(Plus, Var("y"), Num(3)))) = Fun("x", Binop(Plus, Num(2), Num(3))))
            "subst fun x not = varname and not in varidset" ;
  unit_test (subst("y")(Binop(Plus, Var("x"), Num(1)))(Fun("x", Binop(Plus, Var("y"), Num(3))))
            = Fun("var1", Binop(Plus, Binop(Plus, Var("x"), Num(1)), Num(3))))
            "subst fun x not = varname and in varidset" ;
  unit_test (subst("x")(Num(2))(Let("x", Binop(Plus, Num(2), Num(3)), Var("x"))) = Let("x", Binop(Plus, Num(2), Num(3)), Var("x")))
            "subst let x = varname pt 1" ;
  unit_test (subst("x")(Num(2))(Let("x", Binop(Plus, Var("x"), Num(3)), Var("x"))) = Let("x", Binop(Plus, Num(2), Num(3)), Var("x")))
            "subst let x = varname pt 2" ;
  unit_test (subst("y")(Num(2))(Let("x", Binop(Plus, Var("y"), Num(3)), Var("x"))) = Let("x", Binop(Plus, Num(2), Num(3)), Var("x")))
            "subst let x not = varname and not in varidset" ;
  unit_test (subst("y")(Binop(Plus, Var("x"), Num(1)))(Let("x", Binop(Plus, Var("y"), Num(3)), Var("x")))
            = Let("var2", Binop(Plus, Binop(Plus, Var("x"), Num(1)), Num(3)), Var("var2")))
            "subst let x not = varname and in varidset" ;
  unit_test (subst("x")(Num(2))(Letrec("x", Binop(Plus, Var("x"), Num(3)), Var("x"))) = Letrec("x", Binop(Plus, Var("x"), Num(3)), Var("x")))
            "subst letrec x = varname pt 2" ;
  unit_test (subst("y")(Num(2))(Letrec("x", Binop(Plus, Var("y"), Num(3)), Var("x"))) = Letrec("x", Binop(Plus, Num(2), Num(3)), Var("x")))
            "subst letrec x not = varname and not in varidset" ;
  unit_test (subst("y")(Binop(Plus, Var("x"), Num(1)))(Letrec("x", Binop(Plus, Var("y"), Num(3)), Var("x")))
            = Letrec("var3", Binop(Plus, Binop(Plus, Var("x"), Num(1)), Num(3)), Var("var3")))
            "subst letrec x not = varname and in varidset" ;
  unit_test (subst("z")(Num(2))(Raise) = Raise)
            "subst raise" ;
  unit_test (subst("z")(Num(2))(Unassigned) = Unassigned)
            "subst unassigned" ;
  unit_test (subst("x")(Num(2))(App(Var("x"), Var("y"))) = App(Num(2), Var("y")))
            "subst app pt 1" ;
  unit_test (subst("x")(Num(2))(App(Var("x"), Var("x"))) = App(Num(2), Num(2)))
            "subst app pt 1" ;;

(* Testing eval_s *)
let eval_s_test () = 
  unit_test ((eval_s(Num(5))(Env.empty ())) = Env.Val(Num(5))) 
            "eval_s num" ;
  unit_test ((eval_s (Bool(true))(Env.empty())) = Env.Val(Bool(true))) 
            "eval_s bool" ;
  unit_test ((eval_s (Unop(Negate, Num(5)))(Env.empty())) = Env.Val(Num(~-5))) 
            "eval_s unop negate num" ;       
  unit_test (try let _ = eval_s (Unop(Negate, Bool(true)))(Env.empty()) in false with 
              | EvalError "not an integer" -> true 
              | _ -> false) 
            "eval_s unop negate not num" ;
  unit_test ((eval_s (Binop(Plus, Num(5), Num(5)))(Env.empty())) = Env.Val(Num(10)))
            "eval_s binop + 2 nums" ; 
  unit_test ((eval_s (Binop(Times, Num(5), Num(5)))(Env.empty())) = Env.Val(Num(25)))
            "eval_s binop * 2 nums" ; 
  unit_test ((eval_s (Binop(Divide, Num(5), Num(5)))(Env.empty())) = Env.Val(Num(1)))
            "eval_s binop / 2 nums" ;
  unit_test ((eval_s (Binop(Minus, Num(5), Num(5)))(Env.empty())) = Env.Val(Num(0)))
            "eval_s binop - 2 nums" ;
  unit_test ((eval_s (Binop(Equals, Num(5), Num(5)))(Env.empty())) = Env.Val(Bool(true)))
            "eval_s binop = 2 nums" ;
  unit_test ((eval_s (Binop(LessThan, Num(5), Num(5)))(Env.empty())) = Env.Val(Bool(false)))
            "eval_s binop < 2 nums" ;
  unit_test ((eval_s (Binop(GreaterThan, Num(6), Num(5)))(Env.empty())) = Env.Val(Bool(true)))
            "eval_s binop > 2 nums" ;
  unit_test ((eval_s (Binop(Equals, Bool(true), Bool(true)))(Env.empty())) = Env.Val(Bool(true)))
            "eval_s binop = 2 bools" ;
  unit_test ((eval_s (Binop(LessThan, Bool(true), Bool(true)))(Env.empty())) = Env.Val(Bool(false)))
            "eval_s binop < 2 bools" ;
  unit_test (try let _ = eval_s (Binop(Plus, Bool(true), Bool(true)))(Env.empty()) in false with 
            | EvalError "improper types" -> true 
            | _ -> false) 
            "eval_s binop plus not num" ;
  unit_test (try let _ = eval_s (Binop(Equals, Fun("x", Num(5)), Fun("x", Num(5))))(Env.empty()) in false with 
            | EvalError "improper types" -> true 
            | _ -> false) 
            "eval_s binop equals not num or bool" ;
  unit_test (try let _ = eval_s (Binop(Plus, Bool(true), Num(5)))(Env.empty()) in false with 
            | EvalError "improper types" -> true 
            | _ -> false) 
            "eval_s binop diff types" ;
  unit_test ((eval_s(Conditional(Bool(false), Num(5), Num(15)))(Env.empty ())) = Env.Val(Num(15)))
            "eval_s conditional" ;
  unit_test ((eval_s(Fun("x", Num(5)))(Env.empty ())) = Env.Val(Fun("x",Num(5)))) 
            "eval_s fun" ;
  unit_test ((eval_s(Raise)(Env.empty ())) = Env.Val(Raise)) 
            "eval_s raise" ;
  unit_test ((eval_s(Unassigned)(Env.empty ())) = Env.Val(Unassigned)) 
            "eval_s unassigned" ;
  unit_test ((eval_s(Let("x", Num(5), Binop(Plus, Var("x"), Num(1))))(Env.empty ())) = Env.Val(Num(6))) 
            "eval_s let subst int" ;
  unit_test (try let _ = eval_s (Let("x", Num(5), Binop(Plus, Var("y"), Num(1))))(Env.empty ()) in false with 
            | EvalError "Unbound Var" -> true 
            | _ -> false) 
            "eval_s let not work" ;
  unit_test ((eval_s(App(Fun("x", Binop(Plus, Var("x"), Num(1))), Num(5)))(Env.empty ())) = Env.Val(Num(6))) 
            "eval_s app" ;
  unit_test (try let _ = eval_s (App(Fun("x", Binop(Plus, Var("y"), Num(1))), Num(5)))(Env.empty ()) in false with 
            | EvalError "Unbound Var" -> true 
            | _ -> false) 
            "eval_s app not work" ;
  unit_test ((eval_s(Letrec("x", Fun("x", Binop(Plus, Var("x"), Num(1))), Num(10)))(Env.empty())) = Env.Val(Num(10))) 
            "eval_s letrec" ;;
    
(* Testing eval_d and eval_l *)

let eval_d_test () = 
let z = Env.extend (Env.empty()) ("x") (ref(Env.Val(Num(5)))) in
unit_test ((eval_d(Var("x"))(z)) = Env.Val(Num(5))) 
  "eval_d var" ;
unit_test (try let _ = eval_d(Var("x"))(Env.empty ()) in false with 
  | EvalError "not found" -> true 
  | _ -> false) 
  "eval_d var not work" ;
unit_test ((eval_d(Num(5))(Env.empty ())) = Env.Val(Num(5))) 
  "eval_d num" ;
unit_test ((eval_d(Num(5))(Env.empty ())) = Env.Val(Num(5))) 
  "eval_d num" ;
unit_test ((eval_d (Bool(true))(Env.empty())) = Env.Val(Bool(true))) 
  "eval_d bool" ;
unit_test ((eval_d (Unop(Negate, Num(5)))(Env.empty())) = Env.Val(Num(~-5))) 
  "eval_d unop negate num" ;       
unit_test (try let _ = eval_d (Unop(Negate, Bool(true)))(Env.empty()) in false with 
    | EvalError "not an integer" -> true 
    | _ -> false) 
  "eval_d unop negate not num" ;
unit_test ((eval_d (Binop(Plus, Num(5), Num(5)))(Env.empty())) = Env.Val(Num(10)))
  "eval_d binop + 2 nums" ;
unit_test ((eval_d(Conditional(Bool(false), Num(5), Num(15)))(Env.empty ())) = Env.Val(Num(15)))
            "eval_d conditional" ;
unit_test ((eval_d(Fun("x", Num(5)))(Env.empty ())) = Env.Val(Fun("x",Num(5)))) 
            "eval_d fun" ;
unit_test ((eval_d(Raise)(Env.empty ())) = Env.Val(Raise)) 
            "eval_d raise" ;
unit_test ((eval_d(Unassigned)(Env.empty ())) = Env.Val(Unassigned)) 
            "eval_d unassigned" ;
unit_test ((eval_d(App(Fun("x", Binop(Plus, Var("x"), Num(1))), Num(5)))(Env.empty ())) = Env.Val(Num(6))) 
            "eval_d app pt 1" ;
let z = Env.extend (Env.empty()) ("x") (ref(Env.Val(Num(5)))) in
unit_test ((eval_d(App(Fun("x", Binop(Plus, Var("x"), Num(1))), Var("x")))(z)) = Env.Val(Num(6))) 
            "eval_d app with environment" ;
unit_test ((eval_d(Let("x", Num(5), Binop(Plus, Var("x"), Num(1))))(Env.empty ())) = Env.Val(Num(6))) 
            "eval_d let subst int" ;
let z = Env.extend (Env.empty()) ("x") (ref(Env.Val(Num(2)))) in
unit_test ((eval_d(Let("x", Num(5), Binop(Plus, Var("x"), Num(1))))(z)) = Env.Val(Num(6))) 
            "eval_d let subst int with environment" ;
unit_test ((eval_d(Letrec("x", Num(5), Binop(Plus, Var("x"), Num(1))))(Env.empty ())) = Env.Val(Num(6))) 
            "eval_d letrec subst int" ;
let z = Env.extend (Env.empty()) ("x") (ref(Env.Val(Num(2)))) in
unit_test ((eval_d(Letrec("x", Num(5), Binop(Plus, Var("x"), Num(1))))(z)) = Env.Val(Num(6))) 
            "eval_d letrec subst int with environment" ;
unit_test ((eval_d(Let("x", Num(1), Let("f", Binop(Plus, Var("x"), Num(5)), Let("x", Num(2), Var("f")))))(Env.empty())) = Env.Val(Num(6))) 
            "eval_d let defined twice" ;  
unit_test ((eval_l(Let("x", Num(1), Let("f", Binop(Plus, Var("x"), Num(5)), Let("x", Num(2), Var("f")))))(Env.empty())) = Env.Val(Num(6))) 
            "eval_l let defined twice" ;;

let module_tests () =
  let open Env in 
  let z = empty() in 
  unit_test (close (Fun("x", Binop(Plus, Var("x"), Num(1))))(z) = Closure(Fun("x", Binop(Plus, Var("x"), Num(1))), z))
            "closure function" ;
  unit_test (try let _ = close(Num(5))(empty()) in false with 
      | EvalError "not a function" -> true 
      | _ -> false) 
            "closure not a function" ;
  let z = extend (empty()) ("x") (ref(Val(Num(2)))) in
  unit_test (lookup z "x" = Val(Num(2)))
            "lookup/extend function" ;
  let z = extend (empty()) ("x") (ref(Val(Num(2)))) in
  unit_test (try let _ =lookup z "y" in false with 
            | EvalError "not found" -> true 
            | _ -> false) 
            "lookup/extend pt 2" ;;
  
(* Calling the tests *)

let test_all () =
  free_vars_test () ;
  subst_test () ;
  eval_s_test () ;
  eval_d_test () ;
  module_tests () ;;
 

let _ = test_all () ;;
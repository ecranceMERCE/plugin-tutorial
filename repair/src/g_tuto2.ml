let __coq_plugin_name = "tuto2_plugin"
let _ = Mltop.add_known_module __coq_plugin_name

# 3 "src/g_tuto2.mlg"
 

(*
 * In this exercise, we will extend our Coq plugin from before!
 * Last time, we wrote a plugin that manipulates terms from Coq
 * and then defines new terms. This time, we'll use that same idea
 * to implement a form of proof repair!
 *
 * As always, this will be discussion-based, with the usual format.
 *)
(*open Pp*)
open Stdarg
open Termutils
(*open Exercise*)



let () = Vernacextend.vernac_extend ~command:"SaveMap" ~classifier:(fun _ -> Vernacextend.classify_as_sideeff) ?entry:None 
         [(Vernacextend.TyML (false, Vernacextend.TyTerminal ("Map", 
                                     Vernacextend.TyNonTerminal (Extend.TUentry (Genarg.get_arg_tag wit_constr), 
                                     Vernacextend.TyNonTerminal (Extend.TUentry (Genarg.get_arg_tag wit_constr), 
                                     Vernacextend.TyTerminal (":=", Vernacextend.TyNonTerminal (
                                                                    Extend.TUentry (Genarg.get_arg_tag wit_constr), 
                                                                    Vernacextend.TyNil))))), 
         (let coqpp_body o n e
         () = Vernacextend.VtDefault (fun () -> 
# 29 "src/g_tuto2.mlg"
    
     let sigma, env = global_env () in
     let sigma, old_ind = internalize env o sigma in
     let sigma, new_ind = internalize env n sigma in
     let sigma, map = internalize env e sigma in
     (* TODO move me, comment, etc *)
     let rec range (min : int) (max : int) : int list =
       if min < max then
         min :: range (min + 1) max
       else
         []
     in
     (* TODO move me, comment, etc *)
     let rec zoom_product_type env typ =
       let open EConstr in
       match kind sigma typ with
       | Constr.Prod (n, t, b) ->
          zoom_product_type (push_local (n, t) env) b
       | _ ->
          (env, typ)
     in
     (* TODO move me, comment, etc *)
     let reduce_type env trm sigma =
       let sigma, typ = Typing.type_of ~refresh:true env sigma trm in
       sigma, Reductionops.nf_betaiotazeta env sigma typ
     in
     (* TODO move me, comment, etc *)
     let unfold_args_app trm sigma =
       let open EConstr in
       let (f, args) = destApp sigma trm in
       let rec unfold trm sigma =
         match kind sigma trm with
         | Constr.App (f, args) ->
            List.append (unfold f sigma) (Array.to_list args)
         | _ ->
            [trm]
       in List.append (List.tl (unfold f sigma)) (Array.to_list args)
     in
     (* TODO move me, comment, etc *)
     let unfold_args trm sigma =
       let open EConstr in
       if isApp sigma trm then unfold_args_app trm sigma else []
     in
     (* TODO move me, comment, etc *)
     let rec first_fun trm sigma =
       let open EConstr in
       match kind sigma trm with
       | Constr.App (f, args) ->
          first_fun f sigma
       | _ ->
          trm
     in
     (* TODO move me, comment, etc *)
     let get_swap_map env old_ind (f : EConstr.t) (sigma : Evd.evar_map) =
       let open EConstr in
       let open Environ in
       let open Declarations in
       let ((i_o, ii_o), u_o) = destInd sigma old_ind in
       let m_o = lookup_mind i_o env in
       let b_o = m_o.mind_packets.(0) in
       let cs_o = b_o.mind_consnames in
       let ncons = Array.length cs_o in
       map_state
         (fun i sigma ->
           let c_o = mkConstructU (((i_o, ii_o), i), u_o) in
           let sigma, c_o_typ = reduce_type env c_o sigma in
           let env_c_o, c_o_typ = zoom_product_type env c_o_typ in
           let nargs = nb_rel env_c_o - nb_rel env in
           let c_o_args = Array.of_list (List.map mkRel (List.rev (range 1 (nargs + 1)))) in
           let c_o_app = mkApp (c_o, c_o_args) in
           let typ_args : EConstr.t list = unfold_args c_o_typ sigma in
           let c_o_lifted = mkApp (f, Array.of_list (List.append typ_args [c_o_app])) in
           let c_o_lifted_red = Reductionops.nf_all env sigma c_o_lifted in
           let swap = ((((i_o, ii_o), i), u_o), destConstruct sigma (first_fun c_o_lifted_red sigma)) in
           sigma, swap)
         (range 1 (ncons + 1))
         sigma
     in
     let sigma, swap_map = get_swap_map env old_ind map sigma in
     (*
      * TODO: invert map, define inverted function,
      * save both directions to a table
      *)
     ()
   
              ) in fun o
         n e ?loc ~atts () -> coqpp_body o n e
         (Attributes.unsupported_attributes atts)), None))]

let () = Vernacextend.vernac_extend ~command:"SaveMap" ~classifier:(fun _ -> Vernacextend.classify_as_sideeff) ?entry:None 
         [(Vernacextend.TyML (false, Vernacextend.TyTerminal ("Configure", 
                                     Vernacextend.TyTerminal ("Swap", 
                                     Vernacextend.TyNonTerminal (Extend.TUentry (Genarg.get_arg_tag wit_constr), 
                                     Vernacextend.TyNonTerminal (Extend.TUentry (Genarg.get_arg_tag wit_constr), 
                                     Vernacextend.TyNil)))), (let coqpp_body o
                                                             n
                                                             () = Vernacextend.VtDefault (fun () -> 
                                                                  
# 125 "src/g_tuto2.mlg"
    
     let sigma, env = global_env () in
     let sigma, old_ind = internalize env o sigma in
     let sigma, new_ind = internalize env n sigma in
     (*
      * TODO: retrieve map, define old and new constructors,
      * define old and new eliminators, save configuration
      *)
     ()
   
                                                                  ) in fun o
                                                             n ?loc ~atts ()
                                                             -> coqpp_body o
                                                             n
                                                             (Attributes.unsupported_attributes atts)), None))]

let () = Vernacextend.vernac_extend ~command:"SwapCases" ~classifier:(fun _ -> Vernacextend.classify_as_sideeff) ?entry:None 
         [(Vernacextend.TyML (false, Vernacextend.TyTerminal ("Swap", 
                                     Vernacextend.TyNonTerminal (Extend.TUentry (Genarg.get_arg_tag wit_constr), 
                                     Vernacextend.TyNonTerminal (Extend.TUentry (Genarg.get_arg_tag wit_constr), 
                                     Vernacextend.TyTerminal ("in", Vernacextend.TyNonTerminal (
                                                                    Extend.TUentry (Genarg.get_arg_tag wit_constr), 
                                                                    Vernacextend.TyTerminal ("as", 
                                                                    Vernacextend.TyNonTerminal (
                                                                    Extend.TUentry (Genarg.get_arg_tag wit_ident), 
                                                                    Vernacextend.TyNil))))))), 
         (let coqpp_body o n e i
         () = Vernacextend.VtDefault (fun () -> 
# 146 "src/g_tuto2.mlg"
    
     let sigma, env = global_env () in
     let sigma, old_ind = internalize env o sigma in
     let sigma, new_ind = internalize env n sigma in
     let sigma, trm = internalize env e sigma in
     (*
      * TODO: retrieve configuration, pass to sub-like transformation
      *)
     ()
   
              ) in fun o
         n e i ?loc ~atts () -> coqpp_body o n e i
         (Attributes.unsupported_attributes atts)), None))]


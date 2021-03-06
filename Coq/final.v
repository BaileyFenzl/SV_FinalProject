Require Export Poly.

(*
Natprod: 
fst -> the character
snd -> the probability of the character appearing. Lower is less often
higher is more often

 *)

Module my_mod. 
Inductive natprod : Type :=
| pair : nat -> nat -> natprod.


Definition fst (p : natprod) : nat :=
  match p with
  | pair x y => x
  end.

Definition snd (p : natprod) : nat :=
  match p with
  | pair x y => y
  end.


(** Since pairs are used quite a bit, it is nice to be able to
    write them with the standard mathematical notation [(x,y)] instead
    of [pair x y].  We can tell Coq to allow this with a [Notation]
    declaration. *)

Notation "( x , y )" := (pair x y).


Inductive tree : Type :=
| leaf : natprod -> tree              (* leaf is just a character *)
| node : nat -> tree -> tree -> tree. (*weight of branch -> left subtree -> right subtree*)

Notation "[ n ]" := (leaf n).


Definition example_tree_1 : tree :=
  node 10 [(1 , 3)] [(1 , 7)].

Definition example_tree_2 : tree :=
  node 20 ( node 5 [(1,3)] [(2,2)]) [(1,15)].
  



 (* Insertion sort: For the overall ease of the algorithm we want the alphabet sorted
from least likely to appear to most likely to appear

For this case, I'll use insertion sort*)

(*standard library is breaking things*)
Fixpoint leb_nat (n m : nat) : bool :=
  match n with
  | O => true
  | S n' =>
      match m with
      | O => false
      | S m' => leb_nat n' m'
      end
  end.


(* takes two trees and compair their values*)
Fixpoint t_le (t1 t2 : tree) : bool :=
  match t1 with
  | leaf t1_p =>
    match t2 with
    | leaf t2_p => leb_nat (snd t1_p) ( snd t2_p)
    | node t2_w _ _=> leb_nat (snd t1_p) t2_w
    end
  | node t1_w _ _ =>
    match t2 with
    | leaf t2_p => leb_nat t1_w (snd t2_p)
    | node t2_w _ _ => leb_nat t1_w t2_w
    end
  end.

Definition example_treelist_1 : list tree :=
  [ [(1,2)] ; [(2, 4)] ; [(3,5)] ; [(4, 6)] ].

Example t_le_ex1:
  t_le [(1,1)] [(2,1)] = true.
Proof. auto. Qed.

Example t_le_ex2:
  t_le [(1,1)] [(2,2)] = true.
Proof. auto. Qed.

Example t_le_ex3:
  t_le [(1,2)] [(2,1)] = false.
Proof. auto. Qed.

Fixpoint insert_t_list (t:tree)(ls : list tree) : list tree :=
  match ls with
  | nil => t::nil
  | f::b => match (t_le t f) with
            | true => (t::f::b)
            | false => f :: (insert_t_list t b)
            end
  end.

Example ins_ex_1:
  insert_t_list [(1,3)] example_treelist_1 = [ [(1,2)] ; [(1,3)]; [(2, 4)] ; [(3,5)] ; [(4, 6)]].
Proof. auto. Qed.
  
(*soring a tree list via insertionsort*)  
Fixpoint treelist_sort (ls : list tree) : list tree :=
  match ls with
  | nil => nil
  | h::t => insert_t_list h (treelist_sort t)
  end.

Example treelist_sort_ex:
 treelist_sort [[(1,53)]; [(2,7)]; [(3,3)]] =  [[(3,3)] ; [(2,7)] ; [(1, 53)]].
Proof.
  auto. Qed.

Fixpoint get_weight (t : tree) : nat :=
  match t with
  | leaf n => snd n
  | node w _ _ => w
  end.

(*
These don't work! I have to try something else


Fixpoint Huffman_helper (ls : list tree) : (list tree) :=
  match ls with
  | nil => [] (*should never hit this case*)
  | h :: nil => cons h nil
  | h1 :: h2 :: tail =>
    Huffman_helper (treelist_sort ((node ((get_weight h1) + (get_weight h2)) h1 h2) :: tail))
  end.

Definition Huffman_tree (ls : list tree) : (list tree) :=
  Huffman_helper ( treelist_sort ls).


*)
(*
a =1; b=2; c=3; d=4; e=5; f=6
 *)
(* Intoruction to Algorithms 3rd edition page 432*)

Definition huff_tree_ex_base : (list tree) :=
  [ [(6, 5)]; [(5,9)]; [(3,12)]; [(2,13)]; [(4,16)]; [(1, 45)]].


(*produces the smalles tree *)
Fixpoint get_tree_min (ls : list tree) :  tree :=
  match ls with
  | nil => [(0,0)]
  | h :: [] => h
  | h :: t =>
    match t_le h (get_tree_min t) with
    | true => h
    | false => (get_tree_min t)
    end
  end.


Example min_tree_ex:
  get_tree_min huff_tree_ex_base = [(6,5)].
Proof.
  simpl. auto. Qed.

Fixpoint tree_eq ( t1 t2 : tree) : bool :=
  match t1, t2 with
  | leaf t1_p, leaf t2_p => match beq_nat (fst t1_p) (fst t2_p) with
                                | false => false
                                | true => beq_nat (snd t1_p) (snd t2_p)
                                end
  | leaf _, node _ _ _ => false
  | node _ _ _, leaf _ => false 
  | node w1 t1_l t1_r, node w2 t2_l t2_r => match beq_nat w1 w2 with
                                            | false => false
                                            | true => andb (tree_eq t1_l t2_l) (tree_eq t1_r t2_r)
                                            end
  end.


(*removes an element from a treelist*)
Fixpoint treelist_remove (t : tree) (ls : list tree) : list tree :=
  match ls with
  | nil => nil
  | h :: tail => match (tree_eq t h) with
              | true => tail
              | false => h :: (treelist_remove t tail)
                 end
 end.

Definition remove_min ( ls : list tree) : list tree :=
  treelist_remove (get_tree_min ls) ls.

Example remove_min_ex1:
  remove_min [[(1,6)]; [(2,3)]; [(3,4)]] = [[(1,6)]; [(3,4)]] .
Proof.
  unfold remove_min. simpl. auto. Qed.

Definition min_weight ( ls : list tree) : nat :=
  get_weight (get_tree_min ls).

Definition snd_min ( ls : list tree) : tree :=
  get_tree_min ( remove_min ls).

Definition snd_weight (ls : list tree) : nat :=
  get_weight ( snd_min ls).

Definition lowest_2_mins (ls : list tree) : list tree :=
  remove_min (remove_min ls).

Check node ((min_weight  example_treelist_1) + (snd_weight  example_treelist_1))  (get_tree_min  example_treelist_1) (snd_min  example_treelist_1).

Fixpoint Huffman_helper (ls : list tree) : (list tree) :=
  match ls with
  | nil => [] (*should never hit this case*)
  | h :: nil => cons h nil
  | h1 :: h2 :: [] => cons (node (min_weight ls + snd_weight ls) (get_tree_min ls) (snd_min ls)) nil
  | h1 :: h2 :: tail =>
      node ((min_weight ls) + (snd_weight ls))  (get_tree_min ls) (snd_min ls) :: (lowest_2_mins ls)
  end.

(* failed again. takign another approach*)


(*nat is the size of the list*)
Fixpoint Huffman_halp (ls : list tree) (n :nat) : list tree :=
  match n with
  |  0 => nil
  |  1 => ls
  | S n => Huffman_halp (Huffman_helper ls) n
  end.



Example Hufftree_ex_1 :
  Huffman_halp huff_tree_ex_base 5 = cons (node 100 [(1, 45)]
                                        ( node  55 
                                               (node 25 [(3,12)] [(2,13)])
                                               (node 30
                                                     (node 14 [(6, 5)] [(5,9)])
                                                     [(4,16)]))) nil.
Proof.            
  unfold huff_tree_ex_base.
(*simpl*) Abort.


(* trying this approach with the other definition*)


 
Fixpoint Huffman_helper' (ls : list tree) : (list tree) :=
  match ls with
  | nil => [] 
  | h :: nil => cons h nil
  | h1 :: h2 :: tail =>
    treelist_sort ((node ((get_weight h1) + (get_weight h2)) h1 h2) :: tail)
  end.


Fixpoint Generate_Huff_Tree (ls : list tree) (n :nat) : list tree :=
  match n with
  |  0 => nil
  |  1 => ls
  | S n =>  Generate_Huff_Tree (Huffman_helper' ls) n
  end.


Example Hufftree_ex_1 :
 Generate_Huff_Tree huff_tree_ex_base (length huff_tree_ex_base) = cons (node 100 [(1, 45)]
                                        ( node  55
                                               (node 25 [(3,12)] [(2,13)])
                                               (node 30
                                                     (node 14 [(6, 5)] [(5,9)])
                                                     [(4,16)]))) nil.
Proof.
  unfold huff_tree_ex_base. simpl. auto. Qed.



(* A datatype that holds 
1) the character
2) the probability for that charavter
3) The huffman code for that character
*)
Inductive Huff_alpha : Type :=
| Huffman_alpha : nat -> nat -> list nat -> Huff_alpha.

(* helper struct*)

(* for some reason the Huff alpha maker is freaking out when I use ++ to append two lists
so I'm making another helper*)
Fixpoint add_end (ls : list nat) (n : nat) : (list nat) :=
  match ls with
  | [] => cons n nil
  | h :: t => (cons h nil) ++ (add_end t n)
  end.
                      

Fixpoint Make_Huff_Alpha_helper (t : tree) ( ls :list nat) : list Huff_alpha :=
  match t with
  | node _ lt rt =>
    (Make_Huff_Alpha_helper lt (add_end ls 0) ) ++  (Make_Huff_Alpha_helper rt (add_end ls 1) )
  | leaf lf => cons ((Huffman_alpha  (fst lf) (snd lf) ls)) nil
  end.

  
Fixpoint Make_Huff_Alpha (ls : list tree) : list Huff_alpha :=
  match ls with
  | t :: [] => Make_Huff_Alpha_helper t nil
  | [] =>  cons (Huffman_alpha 0 0 [ 0;0]) nil
  | h :: t =>   cons (Huffman_alpha 0 0 [ 0;0]) nil
  end.

Example Huff_Alpha_Ex :
  Make_Huff_Alpha (Generate_Huff_Tree huff_tree_ex_base (length huff_tree_ex_base)) =
   [Huffman_alpha 1 45 (cons 0 nil); Huffman_alpha 3 12 [1; 0; 0]; 
   Huffman_alpha 2 13 [1; 0; 1]; Huffman_alpha 6 5 [1; 1; 0; 0]; 
   Huffman_alpha 5 9 [1; 1; 0; 1]; Huffman_alpha 4 16 [1; 1; 1]].
Proof.
  simpl. auto.
Qed.


(*
Decoding
- *encoding followed by decoding is identiy funcion
- optimality 
- 

*)
  (* takes a character and a list, returs a huff char*)
Fixpoint single_char_encode ( n : nat) (ls : list Huff_alpha)  : list nat :=
  match ls with
  |  nil => nil
  |  h :: t => match h with
               |  Huffman_alpha char _ hls => if beq_nat n char then hls else (single_char_encode n t)
         
               end
  end.

Definition Huff_ex_base_Alpha : (list Huff_alpha) :=
    (Make_Huff_Alpha (Generate_Huff_Tree huff_tree_ex_base (length huff_tree_ex_base))).
  

Example single_char_encode_ex :
  single_char_encode 3 Huff_ex_base_Alpha = [1;0;0].
Proof.
  simpl. auto. Qed.

(*
Takes a list of chracters, and returns an encoded list
*)               
Fixpoint encode (ms : list nat) ( alph : list Huff_alpha) : (list nat)  :=
  match ms with
  | nil => nil
  | h :: t => (single_char_encode h alph) ++ (encode t alph)
  end.

(* tests two nat lists for equivalence.
I couldn't find this in the standard library*)

Fixpoint ls_equiv (l1 : list nat) (l2 : list nat) : bool :=
  match l1, l2 with
  | nil, nil => true
  | nil, _ => false
  | _,nil => false
  | h1 :: t1, h2 :: t2 => if beq_nat h1 h2 then ls_equiv t1 t2 else false
  end.

(*takes a huff char, and an alphabet, and returns 
whether or not that set is in the alphabet *)
Fixpoint in_alpha ( ls : list nat) (alph : list Huff_alpha) : bool :=
match alph with
| nil => false
| h :: t => match h with
          
            |  Huffman_alpha _ _ hls =>
               if ls_equiv hls ls then true else in_alpha ls t
            end
end.


(*takes an encoded char that's known to be in the list, and returns the decoded character *)
Fixpoint decode_helper ( char : list nat) ( alph : list Huff_alpha) :  nat:=
  match alph with
  | nil => 0
  | h :: t => match h with
             
              | Huffman_alpha c p hls => if ls_equiv char hls then c
                                         else decode_helper char t
              end
  end.

  (*takes an encoded list, an alphabet, a list that gets passed and returns a decoded list *)


Fixpoint make_decode ( ls : list nat) (alph : list Huff_alpha) (pass : list nat) : (list nat) :=
  match ls with (*to determine if parce list is empty*)
  | nil => if (ls_equiv pass nil) then nil else cons (decode_helper pass alph) nil
  | h :: t => if in_alpha (pass ++ (cons h nil)) alph then
               (cons (decode_helper (pass ++ (cons h nil)) alph) nil) ++ (make_decode t alph [])
              else make_decode t alph (pass ++  (cons h nil))
  end.

Definition decode ( ls :list nat) (alph : list Huff_alpha) : (list nat) :=
  make_decode ls alph nil.

(*
Remembering our basic example
   [Huffman_alpha 1 45 (cons 0 nil); A
   Huffman_alpha 3 12 [1; 0; 0];     C
   Huffman_alpha 2 13 [1; 0; 1];     B
   Huffman_alpha 6 5 [1; 1; 0; 0];   F
   Huffman_alpha 5 9 [1; 1; 0; 1];   E
   Huffman_alpha 4 16 [1; 1; 1]].    D

using  Huff_ex_base_Alpha
 
where ( a = 1, b = 2, c = 3, d = 4, e = 5, f = 6)

Example sentence 
  
[a; f; b; e; c; d]
[1; 6; 2; 5; 3; 4]

manually encoded

[ 0 ;
1 ; 1 ; 0; 0;
1 ; 0 ; 1;
1 ; 1; 0 ; 1;
1; 0; 0;
1; 1; 1]


 *)

Example encode_test :
  encode [1; 6; 2; 5; 3; 4]  Huff_ex_base_Alpha =
[ 0 ;
1 ; 1 ; 0; 0;
1 ; 0 ; 1;
1 ; 1; 0 ; 1;
1; 0; 0;
  1; 1; 1].

Proof.
  simpl. reflexivity. Qed.

Example decode_test:
  decode [ 0 ;1 ; 1 ; 0; 0; 1 ; 0 ; 1; 1 ; 1; 0 ; 1; 1; 0; 0; 1; 1; 1]  Huff_ex_base_Alpha
  =   [1; 6; 2; 5; 3; 4].
Proof.
  simpl. unfold Huff_ex_base_Alpha. simpl. unfold decode. auto. Qed.

Example identity_test_1 :
  decode (encode [1; 6; 2; 5; 3; 4] Huff_ex_base_Alpha)  Huff_ex_base_Alpha = [1; 6; 2; 5; 3; 4] .
Proof.
  auto. Qed.
Example identity_test_2 :
 encode (decode  [ 0 ;1 ; 1 ; 0; 0; 1 ; 0 ; 1; 1 ; 1; 0 ; 1; 1; 0; 0; 1; 1; 1]  Huff_ex_base_Alpha)
        Huff_ex_base_Alpha =   [ 0 ;1 ; 1 ; 0; 0; 1 ; 0 ; 1; 1 ; 1; 0 ; 1; 1; 0; 0; 1; 1; 1].
Proof. auto. Qed.

Lemma decode_nil :
forall (alpha : list Huff_alpha),
  encode [] alpha = [].
Proof.
  intros. auto. Qed.

Fixpoint char_in_alpha (x : nat) (alpha : list Huff_alpha): bool :=
  match alpha with
  | [] => false
  | h :: t => match h with
             
              | Huffman_alpha c _ _ => if beq_nat x c then true else char_in_alpha x t
              end
  end.
  

  
Lemma single_char_iden:
  forall (alpha : list Huff_alpha) (x : nat),
  (char_in_alpha x alpha) = true  ->  decode (single_char_encode x alpha) alpha = cons x nil.
Proof.
  intros. generalize dependent x.  induction alpha.

  intros. simpl. inversion H. 
  intros. auto. rewrite <-  IHalpha.   admit. 
  
 
Admitted.
  
  

Lemma Identity_helper_gen :
  forall (l1 l2 : list nat) (alpha : list Huff_alpha), 
  decode ( l1 ++ l2) alpha = (decode l1 alpha) ++ (decode l2 alpha).
Proof.
  SearchAbout list. intros. 
  
  intros. generalize dependent l2. generalize dependent alpha. induction l1.
  auto.

  intros. simpl. simpl in IHl1.  
Admitted.
                                               
Lemma identity_helper :
  forall  (x : nat) ( hls : list nat) ( alpha : list Huff_alpha),
  decode (single_char_encode x alpha ++ encode hls alpha) alpha
  = decode ( single_char_encode x alpha) alpha ++ decode ( encode hls alpha) alpha.
Proof.
  intros. rewrite Identity_helper_gen. auto. Qed.

Theorem identiy :
  forall ( hls : list nat) ( alpha : list Huff_alpha),
    decode (encode hls alpha) alpha = hls.
Proof.
  intros.
  induction hls. simpl. auto.

  simpl. simpl in IHhls.  rewrite identity_helper.  rewrite IHhls. rewrite single_char_iden.
  auto. admit.  Qed.

                               

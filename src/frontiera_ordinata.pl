
% EXPORT
% type frontiera(Nodo) -->  o ; f(Nodo, frontiera(Nodo), frontiera(Nodo))
%   
% pred frontiera_vuota(-F:frontiera(Nodo))
%

% IMPORT
% type Nodo:  istanzia il tipo generico Nodo
%             dotato di ordinamento totale:
% pred leq(+A:Nodo, +B:Nodo)   ordinamento totale

%%%%   IMPLEMENTAZIONE: le frontiere sono alberi binari con le
%      seguenti proprieta' invarianti:
%
% Proprieta' di priorita':   la radice di ogni albero e sottoalbero
%         ne e' il minimo
%
% Proprieta' di bilanciamento:  per ogni albero e sottoalbero,
% detti ND ed NS i numeri dei nodi dei sottoalberi destro e sinistro,
% vale:    ND = NS  o ND = NS+1
%
% Il bilanciamento garantisce che se T e' il numero totale
% dei nodi di un albero, i cammini hanno lunghezza
% L <= log_2(T)+1 


%%%%%%%%%%%%	  La frontiera vuota:

frontiera_vuota(o).

%%%%%%%%%%%%%     aggiungi(+L:list(Nodo),
%                          +F:frontiera(Nodo),
%                          -F1: frontiera(Nodo))
%                 F1 = inserimento ordinato di L in F
%                 l'ordinamento e' dato dal predicato
%                 leq(+A:Nodo, +B:Nodo)
%		  usato in ins 

aggiungi([],F,F).
aggiungi([N|V], F, F1) :-
      ins(N,F,FF),
      aggiungi(V,FF,F1),
      ( enable_counters(1) -> check_all_counters ; true ).

%%%%%%%%%      scelta(-N:Nodo, 
%                     +F:frontiera(Nodo), 
%		      -F1:frontiera(Nodo))
%              N = nodo minimo di F (con ordinamento leq)
%              e F1 = F meno N            

scelta(X, f(X,o,o), o) :- 
%	dec_counter(cur_frontier)
%	,
	!.
scelta(N, f(N,S,D), f(N1,S1,D1)) :-
   once(ext_foglia(F, D, DmenoF)),
   once(riempi(F, f(_,DmenoF,S), f(N1,S1,D1))).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       IMPLEMENTAZIONE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% ins(+N:X,+F:frontiera(X),-F1:frontiera(X)):
%   pre:  F frontiera di priorita'
%   post:  F1 = F unito X e F1 frontiera priorita'

ins(X, o, f(X,o,o)):- !.
ins(X, f(N,S,D), f(N1,D,S1)) :- 
   (
   leq(X,N) -> 
       (  N1 = X,
          ins(N, S, S1)
        )
       ;
       (  N1 = N,
          ins(X, S, S1))
   ).

%%% ext_foglia(-Foglia:X, +F:frontiera(X), -F1:frontiera(X))
%%            Foglia e' una foglia di F, 
%%	      F1 = F meno Foglia, 
%%	      si mantiene ordinamento e bilanciamento.   
%%            Tempo O(log(numNodi(F)))

ext_foglia(F, f(F,o,o), o) :- !.
ext_foglia(F, f(N,S,D), f(N,ND,S)) :-
    ext_foglia(F,D,ND).

%%% riempi(+N:X, +F:frontiera(X), -F1:frontiera(X))
%%            N e' un nodo arbitrario,
%%            F e' una frontiera da cui la radice e' stata tolta;
%%                diremo che F ha un "buco", che indicheremo con _ : 
%%		  F = f(_, S, D)
%%	      F1 riempie il buco _ di F con Nodo, portandolo al posto
%%                giusto per mantenere l'ordinamento
%%            Tempo O(log(numNodi(F)))


% caso base1:  F = f(_,o,o), cio F contiene solo il buco _,
%              che viene riempito con il nodo N

riempi(N, f(_,o,o), f(N,o,o)).
          
% caso base 2:   F = f(_,o,f(ND,o,o)), cioe' F contiene il buco e sola
%                una foglia, a destra per il bilanciamento:
%                se N <= ND, riempie il buco,
%                altrimenti lo riempie ND e N va al posto di ND

riempi(N, f(_,o,f(ND,o,o)),f(N, o, f(ND,o,o))) :-
     leq(N,ND), !.
riempi(N, f(_,o,f(ND,o,o)),f(ND, o, f(N,o,o))).


% caso ricorsivo 1:  due sottoalberi con radici N1,N2
%                    e N <= di entrambe:   mettiamo N nel
%                    buco senza chiamata ricorsiva alcuna
riempi(N, f(_,f(N1,S1,D1),
                f(N2,S2,D2)),
            f(N,f(N1,S1,D1),
                f(N2,S2,D2))) :-
     leq(N,N1),
     leq(N,N2), !.

% caso ricorsivo 2:  due sottoalberi con radici N1,N2
%                    e, per il cut!,  N > di almeno uno fra N1,N2
%                    e, per il test leq(N1,N2), N1 e' il minimo
%                    fra N, N1, N2:  mettiamo N1 nel buco, aprendo
%                    un buco nel sotto-albero di N1;

%                    Ricorsivamente, riempiamo il buco con N in tale
%                    sottoalbero

riempi(N, f(_,f(N1,S1,D1),
                f(N2,S2,D2)),
            f(N1,RiempitoS,
                f(N2,S2,D2))) :-
     leq(N1,N2), !,
     riempi(N, f(_, S1,D1), RiempitoS).

% caso ricorsivo 3:  due sottoalberi con radici N1,N2
%                    e, per i due cut!,  N2 e' il minimo
%                    fra N, N1, N2:  mettiamo N2 nel buco, aprendo
%                    un buco nel sotto-albero di N2;
%                    Ricorsivamente, riempiamo il buco con N in tale
%                    sottoalbero

riempi(N, f(_,f(N1,S1,D1),
                f(N2,S2,D2)),
            f(N2,f(N1,S1,D1),
                 RiempitoD)) :-
     riempi(N, f(_, S2,D2), RiempitoD).




%%========================  FINE =============================================

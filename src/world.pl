%  Il mondo statico:

%%=====================   I NODI sono le posizioni del robot
%                         nel corridoio, nei laboratori e nelle stanze

%%  type num --> 101; ..; 131.
%   AUSILIARI, per generare i numeri

%% num(?X:num)
% 
num(X) :- 
   ground(X) ->  X > 100,
	         X < 132,
		 1 is (X mod 2)
                 ;
                 in(X,101,131), 1 is (X mod 2).

%% in(-A:num, +B:num, +C:num)
%
in(X,X,Y) :- X =< Y.
in(X,Y,Z) :- Y < Z,
	     Y1 is Y+1,
             in(X,Y1,Z).

%%  type luogo --> labA; labB; labC; labD;
%%                 stanza(num); 
%%                 corridoio(num). //posizione corridoio di fronte
%%				   // a stanza(num)  

posizione(lab, X) 		  :- ground(X) -> 
				       member(X, [labA, labB, labC, labD]), !
				       ;
				       member(X, [labA, labB, labC, labD]).
posizione(corridoio,corridoio(X)) :- num(X).
posizione(stanza   ,stanza(X)) 	  :- num(X).

%% posizione(?X:luogo)
% 
posizione(X) :-  ground(X) -> ( 
			        (  posizione(lab,X), !); 
                                (  posizione(corridoio,X), !);
				(  posizione(stanza,X), !)
			      )
                              ;
			      (
			        posizione(lab,X); 
                                posizione(corridoio,X);
			        posizione(stanza,X)
			      ).
%% in(?X:luogo)
% 
in(X) :- posizione(X).

%% type stanza --> stanza(num).
%% type configurazioni_posta --> list(list(stanza)).

%% powerset(+X:list(stanza),-Y:configurazioni_posta)
% 	Y = insieme delle parti di X
powerset([],[[]]).
powerset([X|Xs], Y) :- powerset(Xs, Y1), findall([X|E], member(E,Y1),Y2), append(Y1,Y2,Y).

%% configurazione_posta(?X:list(stanza))
% 	X  una possibile configurazione di posta a bordo del robot
configurazione_posta(X) :- ground(X) -> ( 
					  configurazioni_posta(Y),
					  permutation(X,PX), 
					  member(PX, Y), !
					)
					;
					configurazioni_posta(Y),
					member(X, Y).

%% type posizione --> in(luogo).
%  type configurazione_posta --> list(stanza).
%
%% and(in(+X: luogo), ?Y:configurazione_posta)
%
and(in(X), Y) :- ground(Y) -> ( in(X), configurazione_posta(M), Y = M, ! )
			      ;
                              ( in(X), configurazione_posta(M), Y = M ). 

%% type stato --> and(posizione, configurazione_posta).
%
%% nodo(+X:stato)
%
nodo(and(in(X), Y)) :- and(in(X), Y).

%%%%%%%%%%%%%%%    I COSTI E I VICINI

%% costo(?X: stato, ?Y: stato, -K: number)
%
% costo ad un passo tra due nodi
%
costo(X,Y,K) :- 
    daC(X,Y,K);
    daC(Y,X,K).  

%% vicini(?X: stato, -L: list(stato))
%
% L � la lista di nodi vicini al nodo X
%
vicini(X,L) :- findall(V, costo(X,V,_), L).

%%%%%%%%%%%%%%%%%%%%%  Passaggi da un nodo ad un altro, con costo

%% da(?X:luogo, ?Y:luogo, ?K: number)
%
%% dai laboratori
da(labA, labD,           1.5).
da(labA, corridoio(101), 1  ).
da(labB, labC,           1.5).
da(labB, corridoio(105), 1  ).
da(labD, corridoio(127), 1  ).
da(labC, corridoio(121), 1  ).

%% da corridoio a stanze
da(corridoio(N), stanza(N), 1) :- num(N).

%% da corridoio a corridoio
da(corridoio(N), corridoio(M), K) :-
  ground(N) -> 
         groundN(N,M,K)
         ;
         (   ground(M) -> groundM(N,M,K)
                          ;
                          num(N), groundN(N,M,K)
         ).

%% groundN(+N:num, ?M:num, -K:number)
%
groundN(N,M,K) :- N=131, M=101, K=5 
		  ;
		  1 is (N mod 2), M is N+2, M < 132, K=1.

%% groundM(?N:num, +M:num, -K:number)
%
groundM(N,M,K) :- N=131, M=101, K=5 
		  ;
		  1 is (M mod 2), N is M-2, N > 100, K=1.

%% daC(?X:stato, ?Y:stato, -C:number)
%
daC(and(in(X),M), and(in(Y),M), C) :- da(X,Y,C).
daC(and(in(X),M), and(in(X),N), 0.5) :- ground(M) -> configurazione_posta(N), subset(N,M), subtract(M,N,[X]).

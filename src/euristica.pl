:- consult(distance).

%% h(+S:stato, -W: float)
%
%  calcola il valore euristico dello stato
%					    
h(S, W) :- (mode(_,_,3,_);mode(_,_,4,_)), h3(S,W), !.
h(S, W) :-  mode(_,_,5,_)               , h5(S,W), !.
h(S, W) :- (mode(_,_,6,_);mode(_,_,7,_)), h6(S,W), !.

%% h(+P:posizione, -W: float)
%
%  calcola il valore euristico della posizione,
%	
h(P, W) :- h1(P,W), !.

%% h1(+P: posizione, -W: float)
%
%  W e' la distanza da P a labA
%
h1(P, W) :- ground(P) -> (
                          distance(in(P), in(labA), W), !
			)
                        ;
			posizione(P),
			distance(in(P), in(labA), W).			

%% h3(+S: stato, -W: float)
%
% W e' il valore euristico di P, calcolato come 
% + distanza da P a labA (W1)
% + numero di consegne da effettuare (N)
% - 0.5 se mi trovo in una stanza in cui devo consegnare
%
h3(S,W) :- ground(S) -> ( 
			  S = and(in(P),M),
	                  distance(in(P), in(labA), W1), 
			  length(M, N),
                          ( member(P,M) -> D = 0.5; D = 0 ),
			  W is W1 + N - D, !
			)
                        ;
		        (
                          nodo(S),
                          S = and(in(P),M),
			  length(M, N),
	                  distance(in(P), in(labA), W1), 
                          ( member(P,M) -> D = 0.5; D = 0 ),
			  W is  W1 + N - D
			).

%% h5(+S: stato, -W: float)
%
% W e' il valore euristico di P, calcolato come 
% + distanza da P a labA (W1)
% + stima delle distanze da P alle stanze in cui devo consegnare (Q)
%
h5(S,W) :- ground(S) -> ( 
			  S = and(P,M),
	                  distance(P, in(labA), W1), 
			  stima_distanze(S,Q),
			  W is W1 + Q, !
			)
                        ;
			(   
			  nodo(S),
			  S = and(P,M),
			  distance(P, in(labA), W1),
			  stima_distanze(S,Q),
			  W is W1 + Q
			).

%% h6(+S: stato, -W: float)
%
% W e' il valore euristico di P, calcolato come 
% + distanza da P a labA (W1), diviso per 100
% + stima delle distanze da P alle stanze in cui devo consegnare (Q1)
% + stima delle distanze dalle stanze in cui devo consegnare al labA (Q2)
h6(S,W) :- ground(S) -> ( 
			  S = and(P,M),
			  d(P, in(labA), W1), 
			  stima_distanze(S,Q1),
			  stima_distanze(and(in(labA),M),Q2),
			  W is W1/100 + Q1 + Q2,
			  !
			)
                        ;
			(   
			  nodo(S),
			  S = and(P,M),
			  d(P, in(labA), W1),
			  stima_distanze(S,Q1),
			  stima_distanze(and(in(labA),M),Q2),
			  W is W1/100 + Q1 + Q2
			).

%% stima_distanze(+S:nodo, -Q: float)
%
stima_distanze(S,Q) :- S = and(P,MC),
		       somma_distanze(P,MC,Q1), 
		       posta(M),
		       length(M,LM),
		       Q is Q1/LM.

%% somma_distanze(+P: posizione, +L: list(stanza), -D: float)
%
somma_distanze(_P,[],0).
somma_distanze(P,[H|T],D) :- d(P,in(H),D1), somma_distanze(P,T,D2), D is D1 + D2, !.

%% d(+A: posizione, +B: posizione, -D: float)
%
d(in(X),in(Y),D) :- mode(_,_,7,_) -> (distanza(X,Y,D), !; distanza(Y,X,D))
                                     ;
				     distance(in(X),in(Y),D).












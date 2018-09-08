:- consult(delivery).
:- consult(cerca2).

:- dynamic path/4.
:- dynamic start/1.
:- dynamic goal/1.

%% genera_nodo(+L: list(stanza), -X: stato)
%
%  genera una lista di stati a partire da una lista di stanze
%
genera_nodo(L, X) :- member(P,L), 
                     subtract(L,[P],M), 
		     powerset(M,PM), 
		     member(CM,PM), 
		     X =.. [and, in(P), CM].

%% node(?X: stato)
%
% se X e' ground, ritorna true
% altrimenti, elenca i possibili stati X
%
node(X) :- ground(X) ->
			(
			  (
			    start(I),
			    (X = I -> !)
			  )
			  ;
			  (
			    goal(F),
			    (X = F -> !)
			  )
			  ;
			  (
			    X = and(in(P),M),
			    genera_nodo([P|M], X), !
			  )
			)
			;
			(
			  start(X)
			  ;
			  goal(X)
			  ;
			  (
			    start(and(in(_),M)),
			    genera_nodo(M, X)
			  )
			).


%% edge(+S1: stato, +S2: stato)
%
% ritorna true se esiste un arco tra S1 e S2
% 
edge(and(in(PX),[]), and(in(PY),[])) :- start(and(in(_PI),MI)), 
				        member(PX,MI),
				        goal(and(in(PY),[])).

edge(and(in(PX),MX),and(in(PY),MY)) :- (ground(PX),ground(MX), node(and(in(PX),MX))) ->
					 ( (ground(PY),ground(MY),node(and(in(PY),MY))) ->
					    (
					      ( member(PY,MX), subset(MY,MX), subtract(MX,[PY],MY), ! )
					      ; fail, writeln('ERRORE')
					    )
					    ;
					    (
					      member(PY,MX),
					      subtract(MX,[PY],MY)
					    )
					).

				
%% risolvi2(+X:nodo, -U:nodo_completo)
%
risolvi2(N,U) :-
  nodo(N) -> 
    frontiera_vuota(Vuota),
    aggiungi([nc(N,[],0)],Vuota,F0),
    cerca2(F0,U), !
    ; writeln('NON NODO').


%% costo2(+X: stato, +Y: stato, -C: float)
% 
% restituisce il costo C tra lo stato X e lo stato Y
%
costo2(X,Y,C) :- path(X,Y,_,C).

%% vicini2(+X: stato, -L:list(stato))
%
% restituisce la lista di stati vicini ad X
%
vicini2(X,L) :- findall(V, edge(X,V), L).


%% dei(+NumeroStanze: integer, +Strategy: integer, +Stats: integer)
%
% vedi dei/4, con Interactive = 0
%
dei(NS,Str,Stats) :- dei(NS,0,Str,Stats).


%% dei(+NumeroStanze: integer, +Interactive: integer, +Strategy: integer, +Stats: integer)
%
%  per la descrizione dei parametri, vedi inizia2/4
%
dei(NS,Interactive,Str,Stats) :- Stats = 1 ->
                        (
                          call(time(inizia2(NS,Interactive,Str,1))), !
                        )
                        ;
                        (
                          call(inizia2(NS,Interactive,Str,Stats)), !
                        ).

%% inizia2(+NumeroStanze: integer, +Strategy: integer, +Stats: integer)
%
%   -= NUMERO STANZE =-
%   n -> numero stanze
%
%   -= INTERACTIVE =-
%   0 -> modalita' non interattiva
%   1 -> modalita' interattiva
%
%   -= STRATEGY =-
%   0 -> Best first
%   1 -> A* con h su pos
%   2 -> A* con h su pos, con precalcolo di h
%   3 -> A* con h su pos e quantita' posta a bordo, con precalcolo di h
%   4 -> A* con h su pos e quantita' posta a bordo, con precalcolo di h e uso di consult
%   5 -> A* con h su pos e distanza posta a bordo, con precalcolo di h
%   6 -> A* con h su pos e distanza posta a bordo da pos iniziale e allo stato finale, con precalcolo di h
%   7 -> A* con h su pos e distanza posta a bordo da pos iniziale e allo stato finale, con precalcolo di h e distanza e nomi di predicato diversi
%
%   -= STATS =-
%   0 -> nessuna statistica
%   1 -> statistica sul tempo di esecuzione
%   2 -> statistica sulla memoria massima utilizzata
%   3 -> statistica sulla memoria utilizzata (su file)
%
inizia2(NS, Interactive, Str,Stats) :-
	init(NS,Interactive,Str,Stats),
	stato_iniziale(S), asserisci(start(S)),
	trovato(G), asserisci(goal(G)),
	ritrai(stato_iniziale(_)),
	ritrai(trovato(_)),
	%( mode(_,_,7,_) -> precalcola_distanza; true),
	%( abilita_precalcolo(1) -> precalcola_valore_h; true),
	ritrai(mode(_,_,_,_)),
	asserisci(mode(NS,0,0,Stats)),	 % esegue il precalcolo dei cammini e dei costi sui sottografi del grafo complessivo usando best-first
        search,
	ritrai(stato_iniziale(_)),
	ritrai(trovato(_)),
	start(S), asserisci(stato_iniziale(S)), 
	goal(G), asserisci(trovato(G)),
	ritrai(mode(_,_,_,_)),
	asserisci(mode(NS,0,Str,Stats)), % esegue il calcolo del cammino e dei costi sui sottografi del grafo ridotto usando la strategia definita dal parametro Str
	risolvi2(S,U),
	stampa_output_algo(U),
	( Stats = 2 -> stampa_counters, !; true ),
	clean.


%% search
%
% esegue il precalcolo dei cammini e dei costi sui sottografi del grafo complessivo
%
search :- foreach(node(X), ( 
	   asserisci(stato_iniziale(X)),
	   foreach(edge(X,Y), calcola_path(X,Y)),
	   ritrai(stato_iniziale(_))
	  )).


%% calcola_path(+X: stato, +Y:stato)
%
% calcola e asserisce in memoria il cammino e il costo tra X e Y
%
calcola_path(X,Y) :-  asserisci(trovato(Y)),
		      risolvi(X,nc(_,Cammino,Costo)),
		      asserisci(path(X,Y,Cammino,Costo)),
		      ritrai(trovato(_)).

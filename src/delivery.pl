:- consult(world).
:- consult(init).

%%%%  LA SOLUZIONE

:- dynamic posta/1.
:- dynamic counter/2.
:- dynamic mode/4.
:- dynamic configurazioni_posta/1.
:- dynamic enable_counters/1.
:- dynamic abilita_precalcolo/1.
:- dynamic valore_h/2.
:- dynamic distanza/3.
:- dynamic stato_iniziale/1.
:- dynamic trovato/1.

%% go(+NumeroStanze: integer, +Strategy: integer, +Stats: integer) 
%
% vedi go/4, con Interactive = 0
%
go(NS,Str,Stats) :- go(NS,0,Str,Stats).

%% go(+NumeroStanze: integer, +Interactive: integer, +Strategy: integer, +Stats: integer) 
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
go(NS,I,Str,Stats) :- Stats = 1 -> 
                        (   
			  call(time(inizia(NS,I,Str,1))), !
			)
			;
			(  
			  call(inizia(NS,I,Str,Stats)), !
			).


%% inizia(+NumeroStanze: integer, +Interactive: integer, +Strategy: integer, +Stats: integer) 
%
% per la descrizione degli argomenti, vedi go/4
%
inizia(NS,I,Str,Stats) :-
	init(NS,I,Str,Stats),
	( mode(_,_,7,_) -> precalcola_distanza; true),
	( abilita_precalcolo(1) -> precalcola_valore_h; true),
        stato_iniziale(X),
	risolvi(X,U),
	stampa_output_algo(U),
	( Stats = 2 -> stampa_counters; true ),
	( Stats = 3 -> close(out); true ),
        ( (between(1,5,NS), set_consegne(NS,M), stato_iniziale(and(in(labA),M)), trovato(and(in(labA),[]))) -> (U = nc(_,_,C), check_costo(C)); true ),
	clean.


%% risolvi(+X:nodo, -U:nodo_completo)
%
risolvi(N,U) :-
  nodo(N) -> 
    frontiera_vuota(Vuota),
    aggiungi([nc(N,[],0)],Vuota,F0),
    cerca(F0,U), !
    ; writeln('NON NODO').


%% mostra_cammino(+X:nodo_completo)
%
mostra_cammino(nc(N,Camm,_)) :-
    revMostra([N|Camm]),
    nl.


%% revMostra(+X:list(posizione))
%
revMostra([]):-
    nl.
revMostra([N|R]) :-
    revMostra(R),
    writeln(N).


%% mostra_costo(+X:nodo_completo)
%
mostra_costo(nc(_,_,C)) :- 
	write('COSTO  '),
	writeln(C).


%% check_costo(+C: integer)
%
%  controlla la correttezza del costo.
%  I valori indicati sono stati ottenuti utilizzando l'algoritmo Best-first, impostando
%  - come stato iniziale, la posizione labA e la lista di consegne definita da set_consegne;
%  - come stato finale, la posizione labA e la lista di consegne vuota.
%
check_costo(C) :- (
		   (mode(1,_,_,_), C \= 12.5);
		   (mode(2,_,_,_), C \= 21.5);
		   (mode(3,_,_,_), C \= 28.0);
		   (mode(4,_,_,_), C \= 30.5);
		   (mode(5,_,_,_), C \= 33.0)
		  ) -> ( writeln('==> ERRORE <=='), clean); true.


%% vai(+X:stato,+Y:stato)
%
%  determina se da X a Y c'� stato uno spostamento
%
vai(X,Y) :- X = and(in(A),M), 
	    Y = and(in(B),M), 
	    A \= B.


%% mostra_azioni(+X:nodo_completo)
%
%  stampa le azioni
%
mostra_azioni(nc(_,Camm,_)) :- 
    reverse(Camm, RCamm),
    stati_ad_azioni(RCamm).


%% estrai_testa(+X:list(elem),-Y:elem)
%
%  Y = testa di X
%
estrai_testa([],[]).
estrai_testa([H|_],H).

%% stati_ad_azioni(+X:list(stato))
%
%  associa ad ogni coppia di stati del cammino un'azione di spostamento o di consegna
%
stati_ad_azioni([H|T]) :- 
    T \= [] -> 
      (
	estrai_testa(T,Y), 	% Y e' il secondo elemento della lista in input
	( 
	  vai(H,Y) -> 		% determina se c'e' stato uno spostamento
	      stampa_spostamento(H,Y)
	      ;
	      stampa_consegna
	),
	stati_ad_azioni(T)
      );
      trovato(X) -> stampa_spostamento(H,X).


%% stampa_spostamento(+H:stato, +Y:stato)
%
stampa_spostamento(H,Y) :-  
    nl, 
    H = and(in(D),_),
    Y = and(in(A),_),
    write('vai da '),
    write(D), 
    ( 
      D = stanza(_) -> 
	write('    a ')
	;
	(
	  D = corridoio(_) ->
	    write(' a ')
	    ;	  
	    write('           a ')
	)
    ),
    write(A).

%% stampa_consegna
%
stampa_consegna :- 
    write(' e consegna la posta!').

%% stampa_counters
%
stampa_counters :- nl,nl,
		   counter(globalused,GU), write('globalused: '), writeln(GU),
		   counter(localused,LU), write('localused: '), writeln(LU).


%% stampa_output_algo(+U:nodo_completo)
%
%  stampa a richiesta cammino, azioni e costo
%
stampa_output_algo(U) :- % mostra_cammino(U),
                         mostra_azioni(U), 
			 nl,nl,
			 mostra_costo(U).

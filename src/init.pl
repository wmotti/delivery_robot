%% init(+NumeroStanze: integer, +Interactive: integer, +Strategy: integer, +Stats: integer) 
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
init(NS,I,Str,Stats) :-  assert(asserzioni([asserzioni(_)])),		% inizializza il registro delle asserzioni
			 asserisci(mode(NS,I,Str,Stats)),
			 ( not(stato_iniziale(_X))->
			   (
			      ( I = 1 -> (				% modalita' interattiva
				      writeln('Inserisci lo stato iniziale (termina con un punto):'),
				      write('=> luogo di partenza: '),
				      read(S),
				      write('=> configurazione iniziale posta: '),				      
				      read(M),
				    ( 
					( length(M,LM), LM \= NS ) -> 
					   ( nl, write('warning: hai inserito una lista di '), write(LM), write(' stanze invece di '), writeln(NS), nl,
					     ritrai(mode(_,_,_,_)), 
					     asserisci( mode(LM,I,Str,Stats)  )
					   )
					;
					true
					)
				        
				    )
			            ;					% modalita' non interattiva
				    (   
				      S = labA,				% inizializza la posizione iniziale
				      set_consegne(NS,M)		% inizializza la lista delle consegne
				    )
			      ), 
			      asserisci(stato_iniziale(and(in(S),M)))
			   ); true
			 ),
			 ( not(trovato(_Y)) -> asserisci(trovato(and(in(labA),[])))
					       ; 
					       true ),
			 set_strategy(Str),				% inizializza la strategy
                         ( Str >= 2 -> ( asserisci(abilita_precalcolo(1)); true )
	                                ; 
					true
	                 ),
			 ( Str   = 4 -> open('h.pl', write, _Fdh, [alias(h_out),buffer(false)])
					; 
					true
	                 ),
	                 ( Stats >= 2 -> ( (asserisci(enable_counters(1)), consult(stats), init_counters); true )
					    ; 
	                                    true
  	                 ),
	                 ( Stats = 3 ->  ( open('output.dat', write, _Fd, [alias(out),buffer(false)]))
					  ; 
					  true
			 ),
	                 asserisci(posta(M)),				% es. M = [a,b,c]
			 powerset(M,PM),
			 asserisci(configurazioni_posta(PM)).		% es. PM = [[],[a],[b],[c],[a,b],[a,c],[b,c],[a,b,c]]


%% set_consegne(+NS: integer, -M: list(stanza))
%
%  usato nella modalita' non interattiva,
%  inizializza la lista delle consegne con valori prefissati
%
set_consegne(NS,M) :- 
	     (   
	        NS = 1 -> M = [stanza(109)];
		NS = 2 -> M = [stanza(109),stanza(117)];
	        NS = 3 -> M = [stanza(109),stanza(117),stanza(131)];
		NS = 4 -> M = [stanza(109),stanza(117),stanza(131),stanza(105)];
		NS = 5 -> M = [stanza(109),stanza(117),stanza(131),stanza(105), stanza(115)];
		NS = 6 -> M = [stanza(109),stanza(117),stanza(131),stanza(105), stanza(115), stanza(125)];
		NS = 7 -> M = [stanza(109),stanza(117),stanza(131),stanza(105), stanza(115), stanza(125), stanza(103)];
		NS = 8 -> M = [stanza(109),stanza(117),stanza(131),stanza(105), stanza(115), stanza(125), stanza(103), stanza(113)];
		NS = 9 -> M = [stanza(109),stanza(117),stanza(131),stanza(105), stanza(115), stanza(125), stanza(103), stanza(113), stanza(123)];
		NS = 10 -> M = [stanza(109),stanza(117),stanza(131),stanza(105), stanza(115), stanza(125), stanza(103), stanza(113), stanza(123), stanza(101)]
	       ).


%% set_strategy(+Str: integer)
%
%  carica il file che implementa la strategia desiderata
%
set_strategy(Str) :- Str = 0 ->
                          consult(best_first)
			  ;
			  consult(a_star).


%% asserisci(+A: predicato(argomenti))
%
%  funzione wrapper di assert che inserisce 
%  il predicato nel registro delle asserzioni
%
asserisci(A) :- assert(A),
		A =.. [H|T], 
		string_to_atom(S,H),		% converte da atomo a stringa
		length(T,LT),			% conto il numero di argomenti
	        rinomina_stringa(S,LT,NS),	% sostituisce agli argomenti il simbolo "_"
		string_to_atom(NS,X),		% converte da stringa a atomo
		term_to_atom(Y,X),		% converte da atomo a termine
		asserzioni(L), 			
		not(member(Y,L)) -> (
				    append([Y], L, NL), 
				    retractall(asserzioni(_)), 
				    assert(asserzioni(NL))
				    ); true.


%% rinomina_stringa(+S: string, +N: integer, -NS: string)
%
%  sostituisce agli argomenti il simbolo "_"
%
%  es. rinomina_stringa( "p(a,b)", "p(_,_)" ).
%
rinomina_stringa(S,N,NS) :- N = 1, string_concat(S,'(_)',NS), !.
rinomina_stringa(S,N,NS) :- N = 2, string_concat(S,'(_,_)',NS), !.
rinomina_stringa(S,N,NS) :- N = 3, string_concat(S,'(_,_,_)',NS), !.
rinomina_stringa(S,N,NS) :- N = 4, string_concat(S,'(_,_,_,_)',NS), !.


%% ritrai_tutto(+L: list(predicato))
%
%  esegue il retractall di tutte le asserzioni contenute nel registro L
%
ritrai_tutto([]) :- true.
ritrai_tutto([H|T]) :-  retractall(H),
	                % write('Retract di '), writeln(H), 
			ritrai_tutto(T).


%% ritrai(+X: predicato)
%
%  esegue il retractall dell'asserzione X
%
ritrai(X) :- retractall(X),
	     % write('Retract di '), writeln(X),
	     asserzioni(L), 
	     delete(L,X,NL), 
	     retractall(asserzioni(_)), 
	     assert(asserzioni(NL)).


clean :- ( asserzioni(X) -> ritrai_tutto(X); true ).


%% rinomina_luogo(+P: luogo, -R: stringa)
%
%  traduce il luogo in una stringa
%
%  es. rinomina_luogo(stanza(101), s101).
%
rinomina_luogo(P,R) :- P = stanza(X), string_concat('s',X,R), !.
rinomina_luogo(P,R) :- P = corridoio(X), string_concat('c',X,R), !.
rinomina_luogo(P,R) :- R = P, !.


%% genera(+X: stato, -T: predicato)
%
%  prende in input uno stato;
%  ne calcola il valore euristico ;
%  rinomina il luogo definito nello stato;
%  restituisce un predicato avente come 
%  - nome: la rinomina della posizione
%  - argomenti: la lista delle consegne da effettuare e il valore euristico calcolato
%
genera(X,T) :- X = and(in(P),M),
	       h6(X,W),
	       rinomina_luogo(P,R),
	       string_to_atom(R,A),
	       T =.. [A,M,W].

%% precalcola_valore_h
%
%  a seconda dell'euristica utilizzata, 
%  precalcola il valore h su posizione o stato e 
%  lo asserisce o lo scrive su file
% 
precalcola_valore_h :-  mode(_,_,7,_),  foreach(nodo(X), foreach(genera(X,T), asserisci(T))),                               !.
precalcola_valore_h :- (mode(_,_,3,_); 
		        mode(_,_,5,_); 
			mode(_,_,6,_)), foreach(nodo(X), foreach(h(X,W), (asserisci(valore_h(X,W))))),                      !.
precalcola_valore_h :-  mode(_,_,4,_),  foreach(nodo(X), foreach(h(X,W), stampa_h_su_file(X,W))), close(h_out), consult(h), !.
precalcola_valore_h :-                  foreach(posizione(X), foreach(h(X,W), (asserisci(valore_h(X,W))))).


%% precalcolo_distanza
%
%  calcola e memorizza le distanze tra
%  - una posizione qualsiasi e il laboratorio A
%  - i laboratori B, C, e una stanza qualsiasi
%  - una posizione nel corridoio e una stanza qualsiasi
%  - una stanza e l'altra, se il numero della prima stanza � =< al numero della seconda stanza
%
precalcola_distanza :- 
	foreach(posizione(X), (
		              foreach(distance(in(X),in(labA),D), asserisci(distanza(X,labA,D)))
        )),
	foreach(posizione(X), ( 
		X \= labA ->  (
		              foreach(posizione(stanza,Y),( 
				  foreach(( X \= stanza(_C) ; (X = stanza(A), Y = stanza(B), A =< B) ), (
 				      foreach( distance(in(X),in(Y),D), asserisci(distanza(X,Y,D)) )
				  ))
			      ))
		); true
	)).
	
%% stampa_h_su_file(+X: stato, +W: float)
%
%  scrive su file stringhe del tipo "valore_h(X,W)".
%
stampa_h_su_file(X,W) :- write(h_out,'valore_h('),
	                 write(h_out,X),
	                 write(h_out,','),
	                 write(h_out,W),
	                 write(h_out,').\n').
%% inc_counter(+Z: counter)
%
%  incrementa il contatore di nome Z
%
inc_counter(Z) :- counter(Z,X),
                  Y is X + 1,
	          update_counter(Z,Y).

%% dec_counter(+Z: counter)
%
%  decrementa il contatore di nome Z
%		  
dec_counter(Z) :- counter(Z,X),
                  Y is X - 1,
	          update_counter(Z,Y).

%% check_counter(+Z: counter)
%
%  controlla il valore del contatore di nome Z
%  ed eventualmente aggiorna il valore massimo memorizzato 
%
check_counter(X) :- (statistics(X,C), !; C = 0),
	            ( mode(_,_,_,3) -> stampa(C) ; true ),
	            counter(X,C_massimo),
		    C_massimo < C -> update_counter(X,C); true.

%% update_counter(+Z: counter, +C: integer)
%
%  aggiorna il contatore di nome Z con il valore C
%	
update_counter(X,C) :- ritrai(counter(X,_)),
		       asserisci(counter(X,C)).

%% assert_counters
%  
assert_counters :- statistics(globalused,G), asserisci(counter(globalused,G)),
		   statistics(localused,L), asserisci(counter(localused,L)).


%% retractall_counters
%
retractall_counters :- ritrai(counter(_,_)), !; true.


%% init_counters
%
init_counters :- retractall_counters,
		 assert_counters,
		 !.


%% check_all_counters
%
check_all_counters :- check_counter(globalused),
                      check_counter(localused),
		      ( mode(_,_,_,3) ->  write(out, '\n'); true ).


%% stampa(+X: float)
%
stampa(X) :- write(out, X),
	     write(out, ',').
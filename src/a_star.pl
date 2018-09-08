%%%  STRATEGIA A*

%%   USA FRONTIERA ORDINATA, implementata come priority queue 
%%   
%%   La frontiera importa dalla strategia un ordinamento totale
%
%    leq(+N1: nodo_completo, +N2: nodo_completo)
%%   

:- consult(cerca).
:- consult(frontiera_ordinata).
:- consult(euristica).

%%%% ORDINA LA FRONTIERA in base al costo, implementando
%    leq come segue  

%% leq(+NC1: nodo_completo, +NC2: nodo_completo)
%
%  definisce la relazione di ordinamento
%
leq(nc(N1,_,Costo1),nc(N2,_,Costo2)) :- mode(_,_,7,_),
					get_valore_h(N1,W1),		% legge i valori asseriti in memoria 
					get_valore_h(N2,W2),		% con predicati di nome diverso
					Costo1+W1 =< Costo2+W2, !.

leq(nc(N1,_,Costo1),nc(N2,_,Costo2)) :- mode(_,_,1,_),  
	                                N1 = and(in(P1),_),		
				        N2 = and(in(P2),_),		
				        h(P1, W1),			% calcola il valore h 
				        h(P2, W2), 			% in funzione della posizione attuale
					Costo1+W1 =< Costo2+W2, !.

leq(nc(N1,_,Costo1),nc(N2,_,Costo2)) :- mode(_,_,2,_), 
	                                N1 = and(in(P1),_),
                                        N2 = and(in(P2),_),
				        valore_h(P1, W1),		% legge in memoria il valore h
				        valore_h(P2, W2),		% definito in funzione della posizione attuale
					Costo1+W1 =< Costo2+W2, !.

leq(nc(N1,_,Costo1),nc(N2,_,Costo2)) :-  ( mode(_,_,3,_); 
				           mode(_,_,4,_);
				           mode(_,_,5,_);
				           mode(_,_,6,_) ),
	                                 valore_h(N1, W1),		% legge in memoria il valore h
					 valore_h(N2, W2),		% definito in funzione dello stato attuale
					 Costo1+W1 =< Costo2+W2, !.

/*
leq(nc(_N1,Camm1,Costo1),nc(_N2,Camm2,Costo2)) :- mode(NS,_,8,_),
						count_consegne(Camm1,CC1),
						count_consegne(Camm2,CC2),
						Costo1  =< Costo2, !.

count_consegne([], 0) :- !.
count_consegne([H|T], CC) :- posta(M), H = and(in(P),_), count_consegne(T,CC1), (member(P,M) -> CC is CC1 + 1; CC is CC1).
*/

%% get_valore_h(+X: stato, +W: predicato)
%
%  rinomina il luogo definito nello stato X (es. stanza(101) -> s101),
%  e chiama il predicato cosi' nominato al fine di leggere in memoria 
%  il valore euristico dello stato X
%
get_valore_h(X,W) :-  X = and(in(P),M),
		      rinomina_luogo(P,R),	
		      string_to_atom(R,T),	% converte da stringa a atomo
		      call(T,M,W).

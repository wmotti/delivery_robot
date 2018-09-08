%%%  STRATEGIA best first

%%   USA FRONTIERA ORDINATA, implementata come priority queue 
%%   
%%   La frontiera importa dalla strategia un ordinamento totale
%
%    leq(+N1: nodo_completo, +N2: nodo_completo)
%%   

:- consult(cerca).
:- consult(frontiera_ordinata).


%%%% ORDINA LA FRONTIERA in base al costo, implementando
%    leq come segue  

%% leq(+NC1: nodo_completo, +NC2: nodo_completo)
%
leq(nc(_,_,Costo1),nc(_,_,Costo2)) :-
       Costo1 =< Costo2.

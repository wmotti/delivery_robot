%%%%  Algoritmo completo generico

%%%%***********************   INTERFACCIA IMPORT DAL PROBLEMA  

% type nodo.
% pred costo(+N1: nodo, +N2: nodo, -C: float).
%            C = costo(N1,N2)
%
% pred vicini(+N: nodo, -V: list(nodo)).
%            V = lista vicini di N
%
% pred trovato(+N: nodo).
%         vero se N e' una soluzione/goal   


%%%%***********************   INTERFACCIA IMPORT DALLA STRATEGIA


% type frontiera(nodo_completo).    
%		     Sequenza di nodi completi, implementata 
%                    per avere una aggiunta efficiente

% pred aggiunta(+L: list(nodo_completo), +F1:frontiera, -F2:frontiera)
%        aggiunta di L in F1 ottenendo F2
%	 dipende dalla strategia implementata

% pred scelta(-N: nodo_completo, +F1:frontiera, -F2:frontiera)
%       N scelto da F1, F2 = F1 da cui tolgo N




%% **********************  Interfaccia EXPORT:  l'algoritmo di ricerca

% type cammino = list(nodo).

% type nodo_completo --> nc(nodo,cammino,float).

% pred cerca(+F: frontiera, N: nodo_completo)
%     se termina, N contiene una soluzione e 
%     un cammino dalla soluzione alla radice

%%% ************************ AUSILIARIO

% trasforma(list(nodo), Nodo_completo, list(nodo_completo))
%   trasforma(Vicini, nc(N,CamminoN,CostoN), NC):
%   frasforma la lista dei Vicini in una lista di nodi completi:
%   ogni nodo  V in Vicini diventa    
%   nc(V, [N|CamminoN], CostoN + costoArco(N,V)) 


%% *******************  IMPLEMENTAZIONE

cerca(F,nc(N, P, C)) :-
	scelta(nc(N, P, C),F,_),
        trovato(N).		  % dal problema

cerca(F,U) :-
        scelta(nc(N,P,C),F,F1),   % dalla strategia
	vicini(N,L),              % dal problema
	trasforma(L,nc(N,P,C),NL),
	aggiungi(NL,F1,NF),       % dalla strategia
        cerca(NF,U).		  % ricorsione coda


/* 
trasforma([],_,[]).
trasforma([   V               | R ], nc(N,Camm,Cost), 
          [nc(V, [N|Camm], NC)| NR]) 
        :-
        costo(N,V,CA),            % dal problema
        NC is Cost + CA,
        trasforma(R, nc(N,Camm,Cost), NR). 
*/


%%%%%%  TRASFORMA CHE TAGLIA I CICLI

trasforma([],_,[]).
trasforma([   V               | R ], nc(N,Camm,Cost), 
          [nc(V, [N|Camm], NC)| NR]) 
        :-
        not(member(N, Camm)),!,
        costo(N,V,CA),            % dal problema
        NC is Cost + CA,
        trasforma(R, nc(N,Camm,Cost), NR). 

trasforma([_ | R ], nc(N,Camm,Cost), NR) :-
         trasforma(R, nc(N,Camm,Cost), NR). 







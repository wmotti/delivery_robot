%% distance(+X:posizione, +Y:posizione, -D:float)
%
%  D e' la distanza da X a Y
%
distance(X, X, 0) :- !.
distance(X, Y, D) :- manh(X, Y, D).


%% manh(+A: posizione, +B: posizione, -D: float)
%
%  D e' la distanza di Manhattan da X a Y
%
manh(A, B, D) :-   (
		       ( A = in(stanza(_)), B = in(corridoio(_)) );
		       ( A = in(X), posizione(lab,X), B = in(corridoio(_)) );
		       ( A = in(stanza(X)), B = in(stanza(Y)), X > Y );
		       ( A = in(X), posizione(lab,X), B = in(stanza(_)) );
		       ( A = in(X), X = labA, B = in(Y), posizione(lab,Y), Y \= labA )
		    ) ->
			  manhattan(B, A, D)
			  ;
			  manhattan(A ,B, D).


  %%%%%%%%%%%%%%%%%%%%%%% 
 %%                     %%
%%% DISTANZA TRA STANZE %%%
 %%                     %%
  %%%%%%%%%%%%%%%%%%%%%%%
   
%% manhattan(+A:posizione, +B:posizione, -D:number)
%

% distanza tra stanze "vicine" ma non adiacenti
manhattan(in(stanza(X)), in(stanza(Y)), 2) :- 
  (	
    (X = 117, Y = 119);
    (X = 111, Y = 113)
  ), !.

% distanza tra stanze appartenenti a blocchi tra loro paralleli
manhattan(in(stanza(X)), in(stanza(Y)), 5) :- 
  (
    (X = 101, Y = 127);
    (X = 103, Y = 125);
    (X = 105, Y = 123);
    (X = 107, Y = 121);
    (X = 109, Y = 119)	  
  ), !.

%  distanza tra due stanze generiche
manhattan(in(stanza(X)), in(stanza(Y)), D) :- 
  (  
    ( between(101,111,X),between(101,111,Y)  );
    ( between(113,117,X),between(113,117,Y)  );
    ( between(119,131,X),between(119,131,Y)  )
  ) -> 
    ( abs((X-Y)/2, D), !) 
   ;
   ( 
	( 
	       X >= 101, X =< 111, 
               Y >= 113, Y =< 117 
        ) -> 
		( 
			manhattan(in(stanza(X)),in(stanza(111)),D1), 
			manhattan(in(stanza(111)),in(stanza(113)),D2), 
			manhattan(in(stanza(113)),in(stanza(Y)),D3), 
			D is D1 + D2 + D3, !
		)
		;
		( 
		       X >= 113, X =< 117, 
                       Y >= 119, Y =< 131 
                ) -> 
			( 
				manhattan(in(stanza(X)),in(stanza(117)),D1), 
				manhattan(in(stanza(117)),in(stanza(119)),D2), 
				manhattan(in(stanza(119)),in(stanza(Y)),D3), 
				D is D1 + D2 + D3, !
			)
			;
			( 
			        X >= 101, X =< 111, 
                       	        Y >= 119, Y =< 131 
               	         ) -> 
				( 
					X = 111 -> 
						(
							manhattan(in(stanza(111)),in(stanza(109)),D1),
							manhattan(in(stanza(109)),in(stanza(119)),D2),
							manhattan(in(stanza(119)),in(stanza(Y)),D3),
							D is D1 + D2 + D3, !
						)
			                 	;
			                 	(   
					  		( manhattan(in(stanza(X)), in(stanza(Z)), 5), between(119,131,Z)), 
						        manhattan(in(stanza(Z)), in(stanza(Y)), D1),
							D is D1 + 5, ! 
						 )
			    	)
   )
.

  %%%%%%%%%%%%%%%%%%%%%%%%%%% 
 %%                         %%
%%% DISTANZA TRA LABORATORI %%%
 %%                         %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%

manhattan(in(labC), in(labA), 5) :- !.
manhattan(in(labD), in(labA), 1.5) :- !.
manhattan(in(labB), in(labA), 3) :- !.


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%                           %%
%%% DISTANZA TRA STANZE e LAB %%%
 %%                           %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

manhattan(in(stanza(101)), in(labA), D) :- manhattan(in(stanza(111)), in(stanza(113)), D), !.
manhattan(in(stanza(113)), in(labA), D) :- manhattan(in(stanza(101)), in(stanza(111)), D), !.
manhattan(in(stanza(127)), in(labA), D) :- manhattan(in(stanza(113)), in(stanza(117)), D1), 
					   D is D1 * 1.33, !.

manhattan(in(stanza(X)), in(labA), D) :- 
  ( X > 101, X =< 111 ) -> 
    ( 
      manhattan(in(stanza(101)), in(stanza(X)), D1),
      manhattan(in(stanza(101)), in(labA),      D2),
      D is D1 + D2, !
    );
  ( X > 113, X =< 117 ) -> 
    ( 
      manhattan(in(stanza(113)), in(stanza(X)), D1),
      manhattan(in(stanza(113)), in(labA),      D2),
      D is D1 + D2, !
    );
 ( X >= 119, X < 127 ) -> 
    ( 
      manhattan(in(stanza(X)),   in(stanza(127)), D1),
      manhattan(in(stanza(127)), in(labA),        D2),
      D is D1 + D2, !
    );
  ( X > 127, X =< 131 ) -> 
    ( 
      manhattan(in(stanza(127)), in(stanza(X)), D1),
      manhattan(in(stanza(127)), in(labA),      D2),
      D is D1 + D2, !
    )
.



manhattan(in(stanza(105)), in(labB), D) :- manhattan(in(stanza(111)), in(stanza(113)), D), !.
manhattan(in(stanza(113)), in(labB), D) :- manhattan(in(stanza(105)), in(stanza(111)), D), !.
manhattan(in(stanza(121)), in(labB), D) :- manhattan(in(stanza(113)), in(stanza(117)), D1), 
					   D is D1 * 1.33, !.

manhattan(in(stanza(X)), in(labB), D) :- 
  ( X >= 101, X =< 111 ) -> 
    ( 
      manhattan(in(stanza(105)), in(stanza(X)), D1),
      manhattan(in(stanza(105)), in(labB),      D2),
      D is D1 + D2, !
    );
  ( X >= 113, X =< 117 ) -> 
    ( 
      manhattan(in(stanza(113)), in(stanza(X)), D1),
      manhattan(in(stanza(113)), in(labB),      D2),
      D is D1 + D2, !
    );
 ( X >= 119, X =< 121 ) -> 
    ( 
      manhattan(in(stanza(X)),   in(stanza(121)), D1),
      manhattan(in(stanza(121)), in(labB),        D2),
      D is D1 + D2, !
    );
  ( X >= 121, X =< 131 ) -> 
    ( 
      manhattan(in(stanza(121)), in(stanza(X)), D1),
      manhattan(in(stanza(121)), in(labB),      D2),
      D is D1 + D2, !
    )
.

manhattan(in(stanza(105)), in(labC), D) :- manhattan(in(labD),in(labA),D1), 
                                           manhattan(in(stanza(101)),in(labA),D2),
                                           D is D1 + D2 , !.
manhattan(in(stanza(117)), in(labC), D) :- manhattan(in(stanza(105)), in(stanza(111)), D), !.
manhattan(in(stanza(121)), in(labC), D) :- manhattan(in(stanza(113)), in(stanza(117)), D), !. 

manhattan(in(stanza(X)), in(labC), D) :- 
  ( X >= 101, X =< 111 ) -> 
    ( 
      manhattan(in(stanza(105)), in(stanza(X)), D1),
      manhattan(in(stanza(105)), in(labC),      D2),
      D is D1 + D2, !
    );
  ( X >= 113, X =< 117 ) -> 
    ( 
      manhattan(in(stanza(117)), in(stanza(X)), D1),
      manhattan(in(stanza(117)), in(labC),      D2),
      D is D1 + D2, !
    );
 ( X >= 119, X =< 121 ) -> 
    ( 
      manhattan(in(stanza(X)),   in(stanza(121)), D1),
      manhattan(in(stanza(121)), in(labC),        D2),
      D is D1 + D2, !
    );
  ( X >= 121, X =< 131 ) -> 
    ( 
      manhattan(in(stanza(121)), in(stanza(X)), D1),
      manhattan(in(stanza(121)), in(labC),      D2),
      D is D1 + D2, !
    )
.
    

manhattan(in(stanza(101)), in(labD), D) :- manhattan(in(stanza(105)), in(labC), D).
manhattan(in(stanza(117)), in(labD), D) :- manhattan(in(stanza(101)), in(stanza(111)), D), !.
manhattan(in(stanza(127)), in(labD), D) :- manhattan(in(stanza(113)), in(stanza(117)), D), !. 

manhattan(in(stanza(X)), in(labD), D) :- 
  ( X >= 101, X =< 111 ) -> 
    ( 
      manhattan(in(stanza(101)), in(stanza(X)), D1),
      manhattan(in(stanza(101)), in(labD),      D2),
      D is D1 + D2, !
    );
  ( X >= 113, X =< 117 ) -> 
    ( 
      manhattan(in(stanza(117)), in(stanza(X)), D1),
      manhattan(in(stanza(117)), in(labD),      D2),
      D is D1 + D2, !
    );
 ( X >= 119, X =< 127 ) -> 
    ( 
      manhattan(in(stanza(X)),   in(stanza(127)), D1),
      manhattan(in(stanza(127)), in(labD),        D2),
      D is D1 + D2, !
    );
  ( X >= 127, X =< 131 ) -> 
    ( 
      manhattan(in(stanza(127)), in(stanza(X)), D1),
      manhattan(in(stanza(127)), in(labD),      D2),
      D is D1 + D2, !
    )
.


    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%                                %%
%%% DISTANZA TRA CORRIDOIO e LAB A %%%
 %%                                %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

manhattan(in(corridoio(X)), in(labA), D) :- manhattan(in(stanza(X)), in(labA), D1), 
					    D is D1-1, !.

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%                                 %%
%%% DISTANZA TRA STANZA e CORRIDOIO %%%
 %%                                 %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


manhattan(in(stanza(X)), in(corridoio(Y)),D) :- manhattan(in(corridoio(X)), in(stanza(Y)),D), !.

manhattan(in(corridoio(X)), in(stanza(Y)),D) :- 
	(   
	  ( between(101,111,X), between(101,111,Y) );
	  ( between(113,117,X), between(113,117,Y) );
	  ( between(119,131,X), between(119,131,Y) )
	) -> 
	  ( manhattan(in(stanza(X)),in(stanza(Y)),D1),
	    D is D1 + 1, ! )
	  ;
	  (
            ( X < Y -> manhattan(in(stanza(X)),in(stanza(Y)),D1); manhattan(in(stanza(Y)),in(stanza(X)),D1)),
	   D is D1 - 1, ! ).


  %%%%%%%%%%%%%%%%%%%%%%%
 %%                     %%
%%% FUNZIONI AUSILIARIE %%%
 %%                     %%
  %%%%%%%%%%%%%%%%%%%%%%%

%% abs(+X:relative_number, -A:number)
%
abs(X,A) :- X > 0 -> A is X
                     ; 
                     A is -X.

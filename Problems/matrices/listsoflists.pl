/* Implementation of cart_prod */

make_pairs(X, [H], [[X, H]]).
make_pairs(X, [H|T], [[X, H] | RestPairs]) :-
    make_pairs(X, T, RestPairs).

unify([], _, []).
unify(_, [], []).
unify([H|T], [First|Rest], [[H|First] | ResultTail]) :-
    unify([H], Rest, Temp1),
    unify(T, [First|Rest], Temp2),
    append(Temp1, Temp2, ResultTail).

cart_prod([_, []], []).
cart_prod([[], _], []).

cart_prod([[HA|TA], B], CP) :-
    make_pairs(HA, B, SomePairs),
    cart_prod([TA, B], RestPairs),
    append(SomePairs, RestPairs, CP).

cart_prod([First|Rest], CP) :-
    cart_prod(Rest, RestCP),
    unify(First, RestCP, CP).

% Alternative Implementation of cart_prod, using "findall".
%
% cart_prod([A, B], CP) :- findall([X,Y], (member(X, A), member(Y,B)), CP).
% cart_prod([First|Rest], CP) :-
%    cart_prod(Rest, RestCP),
%    findall([X|V], (member(X, First), member(V, RestCP)), CP).


/* Implementation of matr_transp */

first_column([], [], []).
first_column([[X|Row] | M], [X|Xs], [Row|Rest]) :-
    first_column(M, Xs, Rest).

matr_transp([[] | _], []).
matr_transp(M, [FirstCol|Rest]) :-
    M = [[_|_] | _],
    first_column(M, FirstCol, WithoutFirstCol),
    matr_transp(WithoutFirstCol, Rest).


/* Implementation of matr_mult */

dot_product([X], [Y], Result) :- Result is X*Y.
dot_product([X|Xs], [Y|Ys], Result) :-
    dot_product(Xs, Ys, Temp),
    Result is X*Y + Temp.

% Calculates the matrix multiplication of Row (1xN) and M (NxY)
% (can also be considered as a seperate case of matr_mult)

compute_result_row(_, [[] | _], []).
compute_result_row(Row, M, [X|Xs]) :-
    first_column(M, FirstColOfM, MWithoutFirstCol),
    dot_product(Row, FirstColOfM, X),
    compute_result_row(Row, MWithoutFirstCol, Xs).

matr_mult([], _, []).
matr_mult([M1Row|M1RestRows], M2, [First | Rest]) :-
    compute_result_row(M1Row, M2, First),
    matr_mult(M1RestRows, M2, Rest).


/* Implementation of matr_det */

% nth_row(M, N, R, M1) is true iff R is the nth row of M and M1
% is M without R.

nth_row([Row|Rows], 1, Row, Rows) :- Row = [_|_].
nth_row([Row|Rows], N, R, [Row|Rest]) :-
    Row = [_|_], N > 1, N1 is N-1,
    nth_row(Rows, N1, R, Rest).

% nth_col(M, N, C, M1) is true iff C is the nth column of M and
% M1 is M without C. Notice that that the nth column of a matrix
% is the same as the nth row of its transpose.

nth_col(M, N, Col, MWithoutCol) :-
    matr_transp(M, MT),
    nth_row(MT, N, Col, MT1),
    matr_transp(MT1, MWithoutCol).

matr_det([[X]], X).
matr_det(M, Det) :-
    M = [FirstRow | _], FirstRow = [_,_|_],
    matr_det_aux(FirstRow, M, Det, 1, 1).

matr_det_aux([], _, 0, _, _).
matr_det_aux([X|Xs], M, Det, Sign, N) :-
    nth_col(M, N, _, [_|SubM]),
    matr_det(SubM, Minor),
    N1 is N+1, NextSign is (-1)*Sign,
    matr_det_aux(Xs, M, RestCofacts, NextSign, N1),
    Det is Sign*X*Minor + RestCofacts.

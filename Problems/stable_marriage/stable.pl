:- lib(fd).

% Note: since a man A is married to a woman B iff B is married to A,
% only one call to labeling/1 is needed.

produce_output([], [], []).
produce_output([Man|Men], [Wife|Wives], [Man-Wife | Rest]) :-
    produce_output(Men, Wives, Rest).

stable(Marriages) :-
    men(Men), women(Women), 
    def_vars(Men, Women, Wives, Husbands),
    state_constrs(Men, Women, Wives, Husbands),
    labeling(Wives),
    produce_output(Men, Wives, Marriages).

def_vars(Men, Women, Wives, Husbands) :-
    length(Men, N),
    length(Wives, N), Wives :: Women,
    length(Husbands, N), Husbands :: Men.

state_constrs(Men, Women, Wives, Husbands) :-
    stability_constr(Men,   Wives,    Women, Husbands),
    stability_constr(Women, Husbands, Men,   Wives),
    iff_constr(Men, Wives, Women, Husbands).

stability_constr([], [], _, _).
stability_constr([X|Xs], [X_partner|X_partners], Ys, Y_partners) :-
    prefers(X, X_prefs),
    element(X_partner_pos, X_prefs, X_partner),
    impose_stability(Ys, Y_partners, X_prefs, X_partner_pos, X),
    stability_constr(Xs, X_partners, Ys, Y_partners).

impose_stability([], [], _, _, _).
impose_stability([Y|Ys], [Y_partner|Y_partners], X_prefs, X_partner_pos, X) :-
    prefers(Y, Y_prefs),
    element(Y_pos, X_prefs, Y),
    element(X_pos, Y_prefs, X),
    element(Y_partner_pos, Y_prefs, Y_partner),
    (X_partner_pos #> Y_pos #=> X_pos #> Y_partner_pos),
    impose_stability(Ys, Y_partners, X_prefs, X_partner_pos, X).

iff_constr([], [], _, _).
iff_constr([Man|Men], [Wife|Wives], Women, Husbands) :-
    iff_constr1(Man, Wife, Women, Husbands),
    iff_constr(Men, Wives, Women, Husbands).

iff_constr1(_, _, [], []).
iff_constr1(Man, Wife, [Woman|Women], [Husband|Husbands]) :-
    Man #= Husband #<=> Woman #= Wife,
    iff_constr1(Man, Wife, Women, Husbands).
create_graph(NNodes, Density, Graph) :-
    cr_gr(1, 2, NNodes, Density, [], Graph).

cr_gr(NNodes, _, NNodes, _, Graph, Graph).
cr_gr(N1, N2, NNodes, Density, SoFarGraph, Graph) :-
    N1 < NNodes,
    N2 > NNodes,
    NN1 is N1 + 1,
    NN2 is NN1 + 1,
    cr_gr(NN1, NN2, NNodes, Density, SoFarGraph, Graph).
cr_gr(N1, N2, NNodes, Density, SoFarGraph, Graph) :-
    N1 < NNodes,
    N2 =< NNodes,
    rand(1, 100, Rand),
    (Rand =< Density ->
      append(SoFarGraph, [N1 - N2], NewSoFarGraph) ;
      NewSoFarGraph = SoFarGraph),
    NN2 is N2 + 1,
    cr_gr(N1, NN2, NNodes, Density, NewSoFarGraph, Graph).

rand(N1, N2, R) :-
    random(R1),
    R is R1 mod (N2 - N1 + 1) + N1.

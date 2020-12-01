:- compile(graph).

:- lib(ic).
:- lib(branch_and_bound).

vertexcover(NNodes, Density, Cover) :-
    create_graph(NNodes, Density, Graph),
    def_vars(NNodes, Nodes),
    state_constrs(Nodes, Graph),
    CoverCardinality #= sum(Nodes),
    bb_min(search(Nodes, 0, input_order, indomain, complete, []),
           CoverCardinality, _),
    form_cover(1, Nodes, Cover).

% Each node in the graph either exists in the cover or not
def_vars(NNodes, Nodes) :-
    length(Nodes, NNodes),
    Nodes #:: [0,1].

% For each edge in the graph, at least one of its incident
% nodes must appear in the vertex cover

state_constrs(_, []).
state_constrs(Nodes, [N1-N2 | Graph]) :-
    n_th(N1, Nodes, Node1),
    n_th(N2, Nodes, Node2),
    Node1 #= 1 or Node2 #= 1,
    state_constrs(Nodes, Graph).

n_th(1, [Node| _], Node).
n_th(N, [_| Nodes], Node) :-
    N \= 1, N1 is N - 1,
    n_th(N1, Nodes, Node).

form_cover(_, [], []).
form_cover(N, [0|T], Cover) :- N1 is N+1, form_cover(N1, T, Cover).
form_cover(N, [1|T], [N|Cover]) :- N1 is N+1, form_cover(N1, T, Cover).

/** Notes:
 *
 * 1. The Machines variable is a list of (<machine_type>, <ID>) tuples, produced by get_machines.
 *
 * 2. Each task T corresponds to 3 variables:
 * 
 *    Start: when the task starts being processed.
 *    End:   when the task stops being processed.
 *    M_ID:  the ID of the machine on which the task is being processed. This ID can be mapped back
 *           to a single machine type, with the help of id_range.
 *
 */

:- lib(ic).
:- lib(branch_and_bound).

jobshop(Jobs, Staff, Schedule, Cost, Delta, Timeout) :-
	get_machines(Machines),
	findall(TL, (member(J, Jobs), job(J, TL)), TaskLists),
	flatten(TaskLists, Tasks),
	def_vars(Tasks, TaskVars, MaxDeadline),
	state_constrs(TaskLists, TaskVars, Staff, MaxDeadline, Machines),
	split_TaskVars(TaskVars, StartTimes, EndTimes, MachineIDs),
	Cost #= max(EndTimes),
	append(MachineIDs, StartTimes, GoalVars),
	bb_min(search(GoalVars, 0, input_order, indomain, complete, []),
		      Cost, bb_options{timeout:Timeout, delta:Delta}),
	schedule(TaskVars, Machines, Schedule).

get_machines(Machines) :-
	findall(m(M, N), machine(M, N), L),
	map_machines_to_ids(1, L, Machines).

map_machines_to_ids(_, [], []).
map_machines_to_ids(ID, [m(_, 0) | Rest], Machines) :-
	map_machines_to_ids(ID, Rest, Machines).
map_machines_to_ids(ID, [m(M, N) | Machs], [(M, ID) | Rest]) :-
	N > 0, NextID is ID+1, N1 is N-1,
	map_machines_to_ids(NextID, [m(M, N1) | Machs], Rest).

def_vars(Tasks, TaskVars, MaxDeadline) :-
	findall(D, (member(T, Tasks), task(T, _, D, _)), TaskDurations),
	findall(Quantity, machine(_, Quantity), MachineQuantities),
	MaxDeadline is sum(TaskDurations),
	TotalMachines is sum(MachineQuantities),
	length(Tasks, N), length(TaskVars, N),
	def_vars1(TaskVars, Tasks, MaxDeadline, TotalMachines).

def_vars1([], [], _, _).
def_vars1([TaskVar|Rest], [T|Ts], MaxDeadline, TotalMachines) :-
	TaskVar = (T, Start, End, M_ID),
	[Start, End] #:: 0..MaxDeadline,
	M_ID #:: 1..TotalMachines,
	def_vars1(Rest, Ts, MaxDeadline, TotalMachines).

state_constrs(TaskLists, TaskVars, Staff, MaxDeadline, Machines) :-
	serial_processing_constr(TaskVars),
	precedence_constr(TaskLists, TaskVars),
	correct_machine_type_constr(TaskVars, Machines),
	non_overlapping_tasks_constr(TaskVars),
	staff_availability_constr(0, MaxDeadline, TaskVars, Staff).

serial_processing_constr([]).
serial_processing_constr([(T, Start, End, _) | Rest]) :-
	task(T, _, Duration, _),
	End #= Start + Duration,
	serial_processing_constr(Rest).

precedence_constr([], _).
precedence_constr([TL|TLs], TaskVars) :-
	precedence_constr1(0, TL, TaskVars, TaskVars1),
	precedence_constr(TLs, TaskVars1).

precedence_constr1(_, [], TaskVars, TaskVars).
precedence_constr1(MinStart, [_|Ts], [(_, S, E, _) | Rest], TaskVars1) :-
	S #>= MinStart,
	precedence_constr1(E, Ts, Rest, TaskVars1).

correct_machine_type_constr([], _).
correct_machine_type_constr([(T, _, _, M_ID) | Rest], Machines) :-
	task(T, MachType, _, _),
	id_range(MachType, StartID, EndID, Machines),
	(M_ID #>= StartID and M_ID #=< EndID),
	correct_machine_type_constr(Rest, Machines).

id_range(MachType, StartID, EndID, [(MachType, ID) | _]) :-
	StartID = ID,
	machine(MachType, Count),
	EndID is StartID + Count - 1.
id_range(MachType, StartID, EndID, [(MachType1, _) | Machines]) :-
	MachType \= MachType1,
	id_range(MachType, StartID, EndID, Machines).

non_overlapping_tasks_constr([]).
non_overlapping_tasks_constr([(_, Start, End, M_ID) | Rest]) :-
	non_overlapping_tasks_constr1(Start, End, M_ID, Rest),
	non_overlapping_tasks_constr(Rest).

non_overlapping_tasks_constr1(_, _, _, []).
non_overlapping_tasks_constr1(S1, E1, M_ID1, [(_, S2, E2, M_ID2) | Rest]) :-
	(M_ID1 #= M_ID2 => (E1 #=< S2 or E2 #=< S1)),
	non_overlapping_tasks_constr1(S1, E1, M_ID1, Rest).

staff_availability_constr(MaxDeadline, MaxDeadline, _, _).
staff_availability_constr(TimeSlot, MaxDeadline, TaskVars, Staff) :-
	TimeSlot \= MaxDeadline,
	required_staff(TimeSlot, TaskVars, 0, ReqStaff),
	ReqStaff #=< Staff,
	NextTimeSlot is TimeSlot+1,
	staff_availability_constr(NextTimeSlot, MaxDeadline, TaskVars, Staff).

%% This works too:
%% Acc1 #= Acc + Staff * (Start #=< TimeSlot and TimeSlot #< End)
%%
%% The above constraint is better than the one seen below, speed-wise.

required_staff(_, [], ReqStaff, ReqStaff).
required_staff(TimeSlot, [(T, Start, End, _) | Rest], Acc, ReqStaff) :-
	task(T, _, _, Staff),
	((Start #=< TimeSlot and TimeSlot #< End) => Acc1 #= Acc + Staff),
	((Start #> TimeSlot or TimeSlot #>= End) => Acc1 #= Acc),
	required_staff(TimeSlot, Rest, Acc1, ReqStaff).

split_TaskVars([], [], [], []).
split_TaskVars([(_, S, E, M) | Rest], [S|Ss], [E|Es], [M|Ms]) :-
	split_TaskVars(Rest, Ss, Es, Ms).

schedule(_, [], []).
schedule(TaskVars, [(MachType, ID) | Machines],
         [execs(MachType, Timeline) | Rest]) :-
	findall((T, S, E, ID), member((T, S, E, ID), TaskVars), TVs),
	findall(S, member((_, S, _, _), TVs), StartTimes),
	sort(StartTimes, SortedStartTimes),
	simplify(SortedStartTimes, TVs, Timeline),
	schedule(TaskVars, Machines, Rest).

simplify([], _, []).
simplify([S|Ss], TaskVars, [t(T, S, E) | Rest]) :-
	member((T, S, E, _), TaskVars),
	simplify(Ss, TaskVars, Rest).

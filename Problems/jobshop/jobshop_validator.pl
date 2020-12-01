jobshop_works_correctly :-
    findall(S, jobshop(S), Solutions),
    validate(Solutions).

jobshop_with_manpower_works_correctly :-
    findall(S, jobshop_with_manpower(S), Solutions),
    validate1(Solutions).

validate([]).
validate([S|Sols]) :- validate_jobshop(S), validate(Sols).

validate1([]).
validate1([S|Sols]) :- validate_jobshop_with_manpower(S), validate(Sols).

validate_jobshop(Schedule) :-
   deadline(Deadline),
   findall(TL, job(_, TL), Tasks),
   findall(M/N, machine(M, N), L),
   validate_machines(Schedule, L),
   number_of_given_tasks(Tasks, TNG),
   number_of_tasks_in_schedule(Schedule, TNS),
   (TNG = TNS ->
      true ;
      (writeln('Bad number of tasks scheduled'),
       fail)),
   validate_jobs(Schedule, Deadline, Tasks).

validate_jobshop_with_manpower(Schedule) :-
   validate_jobshop(Schedule),
   validate_staff(Schedule).

validate_machines(_, []).
validate_machines(Schedule, [M/N|L]) :-
   findall(present, member(execs(M, _), Schedule), Pr),
   (length(Pr, N) ->
      true ;
      (writeln('Bad machines number in schedule'),
       fail)),
   validate_machines(Schedule, L).

number_of_given_tasks([], 0).
number_of_given_tasks([TL|Tasks], TNG) :-
   length(TL, N),
   number_of_given_tasks(Tasks, TNG1),
   TNG is N + TNG1.

number_of_tasks_in_schedule([], 0).
number_of_tasks_in_schedule([execs(_,TL)|Schedule], TNS) :-
   length(TL, N),
   number_of_tasks_in_schedule(Schedule, TNS1),
   TNS is N + TNS1.

validate_jobs(_, _, []).
validate_jobs(Schedule, Deadline, [TL|Tasks]) :-
   validate_tasks(Schedule, 0, Deadline, TL),
   validate_jobs(Schedule, Deadline, Tasks).

validate_tasks(_, _, _, []).
validate_tasks(Schedule, MinStart, MaxEnd, [Task|TL]) :-
   get_task_from_schedule(Schedule, Task, Start, End, M),
   (current_predicate(task/3) ->
      task(Task, Machine, Duration) ;
      (current_predicate(task/4) ->
         task(Task, Machine, Duration, _) ;
         fail)),
   (Machine = M ->
      true ;
      (write('Task '),
       write(Task),
       writeln(' scheduled on wrong machine'),
       fail)),
   (End - Start =:= Duration ->
      true ;
      (write('Bad duration for task '),
       write(Task),
       writeln(' in schedule'),
       fail)),
   (Start >= MinStart ->
      true ;
      (write('Task '),
       write(Task),
       writeln(' started too early'),
       fail)),
   (End =< MaxEnd ->
      true ;
      (write('Task '),
       write(Task),
       writeln(' ended after deadline'),
       fail)),
   NewMinStart is Start + Duration,
   validate_tasks(Schedule, NewMinStart, MaxEnd, TL).

get_task_from_schedule(Schedule, Task, Start, End, Machine) :-
   findall(S/E/M, (member(execs(M, TL), Schedule),
                   member(t(Task, S, E), TL)), TDL),
   length(TDL, N),
   (N = 0 ->
      (write('Task '),
       write(Task),
       writeln(' not scheduled'),
       fail) ;
       (N > 1 ->
          (write('Task '),
           write(Task),
           writeln(' scheduled more than once'),
           fail) ;
           TDL = [Start/End/Machine])).

validate_staff(Schedule) :-
   staff(Staff),
   deadline(Deadline),
   findall(MachSch, member(execs(_, MachSch), Schedule), MachSchs),
   flatten(MachSchs, Tasks),
   validate_slots(Tasks, Staff, 0, Deadline).

validate_slots(_, _, Deadline, Deadline).
validate_slots(Tasks, Staff, Time, Deadline) :-
   Time < Deadline,
   findall(TaskSt, (member(t(Task, Start, End), Tasks),
                    Time >= Start, Time < End,
                    task(Task, _, _, TaskSt)), TasksSt),
   NewTime is Time + 1,
   compute_sum(TasksSt, TotalStaff),
   (TotalStaff =< Staff ->
      true ;
      (write('More staff required from time point '),
       write(Time),
       write(' to time point '),
       writeln(NewTime),
       fail)),
   validate_slots(Tasks, Staff, NewTime, Deadline).

compute_sum([], 0).
compute_sum([X|L], Sum) :-
   compute_sum(L, NewSum),
   Sum is NewSum + X.


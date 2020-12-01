/* Shared predicates */

get_machines(Deadline, MachAvs) :-
    findall(m(M, N), machine(M, N), L),
    expand(L, Deadline, [], MachAvs).

expand([], _, MachAvs, MachAvs).
expand([m(M, N) | L], Deadline, MachAvs1, MachAvs4) :-
    expand_one(M, N, Deadline, MachAvs2),
    append(MachAvs1, MachAvs2, MachAvs3),
    expand(L, Deadline, MachAvs3, MachAvs4).

expand_one(_, 0, _, []).
expand_one(M, N, Deadline, [m(M, Avs) | MachAvs]) :-
    N > 0, N1 is N - 1, length(Avs, Deadline),
    expand_one(M, N1, Deadline, MachAvs).

expand_task(_, 0, []).
expand_task(T, D, [T|Ts]) :- D > 0, D1 is D - 1, expand_task(T, D1, Ts).

% A slightly different version of sublist
sublist(S, L, S_StartsAt) :-
    append(L1, L2, L), append(S, _, L2), length(L1, S_StartsAt).

schedule_task(TL, TargetM, [m(TargetM, Avs) | _], InsertedAt) :-
    sublist(TL, Avs, InsertedAt).
schedule_task(TL, TargetM, [_|MachAvs], InsertedAt) :-
    schedule_task(TL, TargetM, MachAvs, InsertedAt).

schedule([], []).
schedule([m(M, Ts) | MachAvs], [execs(M, Timeline) | Rest]) :-
    simplify(Ts, Timeline, 0),
    schedule(MachAvs, Rest).

simplify([], [], _).
simplify([T|Ts], [t(T, CurrTimeSlot, End) | Rest], CurrTimeSlot) :-
    atom(T), !, task(T, _, D), End is CurrTimeSlot + D,
    expand_task(T, D, TL),
    append(TL, Tail, [T|Ts]),
    simplify(Tail, Rest, End).
simplify([_|Ts], Timeline, CurrTimeSlot) :-
    NextTimeSlot is CurrTimeSlot + 1,
    simplify(Ts, Timeline, NextTimeSlot).


/* Implementation of jobshop */

jobshop(Schedule) :-
    deadline(Deadline),
    get_machines(Deadline, MachAvs),
    findall(TL, job(_, TL), Tasks),
    timetable(Tasks, MachAvs),
    schedule(MachAvs, Schedule).

timetable([], _).
timetable([J|Js], MachAvs) :-
    schedule_job(J, MachAvs, 0),
    timetable(Js, MachAvs).

schedule_job([], _, _).
schedule_job([T|Ts], MachAvs, MinStart) :-
    task(T, TargetM, D),
    length(Pad, MinStart),
    expand_task(T, D, TL),
    append(Pad, TL, PaddedTL),
    schedule_task(PaddedTL, TargetM, MachAvs, InsertedAt),
    EndsAt is MinStart + InsertedAt + D,
    schedule_job(Ts, MachAvs, EndsAt).


/* Implementation of jobshop_with_manpower */

jobshop_with_manpower(Schedule) :-
    deadline(Deadline), staff(S),
    get_staff(S, Deadline, StaffAvs),
    get_machines(Deadline, MachAvs),
    findall(TL, job(_, TL), Tasks),
    timetable(Tasks, MachAvs, StaffAvs),
    schedule(MachAvs, Schedule).

get_staff(_, 0, []).
get_staff(S, N, [S|T]) :- N > 0, N1 is N - 1, get_staff(S, N1, T).

timetable([], _, _).
timetable([J|Js], MachAvs, StaffAvs) :-
    schedule_job(J, MachAvs, 0, StaffAvs, UpdStaffAvs),
    timetable(Js, MachAvs, UpdStaffAvs).

schedule_job([], _, _, StaffAvs, StaffAvs).
schedule_job([T|Ts], MachAvs, MinStart, StaffAvs, UpdStaffAvs) :-
    task(T, TargetM, D, S),
    length(Pad, MinStart),
    expand_task(T, D, TL),
    append(Pad, TL, PaddedTL),
    schedule_task(PaddedTL, TargetM, MachAvs, InsertedAt),
    StartsAt is MinStart + InsertedAt, EndsAt is StartsAt + D,
    update_staff(0, StartsAt, EndsAt, S, StaffAvs, TempUpdStaffAvs),
    schedule_job(Ts, MachAvs, EndsAt, TempUpdStaffAvs, UpdStaffAvs).

update_staff(End, _, End, _, StaffAvs, StaffAvs).
update_staff(CurrTimeSlot, Start, End, S, [N|T], [N1|Rest]) :-
    Start =< CurrTimeSlot, CurrTimeSlot < End,
    N1 is N - S, N1 >= 0, NextTimeSlot is CurrTimeSlot + 1,
    update_staff(NextTimeSlot, Start, End, S, T, Rest).
update_staff(CurrTimeSlot, Start, End, S, [N|T], [N|Rest]) :-
    CurrTimeSlot < Start, NextTimeSlot is CurrTimeSlot + 1,
    update_staff(NextTimeSlot, Start, End, S, T, Rest).

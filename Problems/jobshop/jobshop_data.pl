job(j1,[t11,t12]).
job(j2,[t21,t22,t23]).
job(j3,[t31]).
job(j4,[t41,t42]).

task(t11,m1,2).
task(t12,m2,6).
task(t21,m2,5).
task(t22,m1,3).
task(t23,m2,3).
task(t31,m2,4).
task(t41,m1,5).
task(t42,m2,2).

task(t11,m1,2,3).
task(t12,m2,6,2).
task(t21,m2,5,2).
task(t22,m1,3,3).
task(t23,m2,3,2).
task(t31,m2,4,2).
task(t41,m1,5,4).
task(t42,m2,2,1).

machine(m1,1).
machine(m2,2).

staff(6).

deadline(14).

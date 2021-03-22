# Prolog-CSP

This project contains the solutions to various search problems, including some constraint satisfaction problems,
implemented in [ECLiPSe](https://en.wikipedia.org/wiki/ECLiPSe) Prolog. These problems were given as assignments
for the course Logic Programming ([YS05](http://cgi.di.uoa.gr/~takis/ys05.html)), NKUA. A brief description for
each problem follows:


### Matrices

Goal for this project is to get acquainted with matrices in prolog, which are represented as lists of lists. The
following predicates were implemented:

- cart_prod(Sets, CP) : CP is the cartesian product of the sets (lists) contained in Sets.
- matr_transp(M, T) : T is the transpose of the matrix M.
- matr_mult(M1, M2, M) : M is equal to the result of the matrix multiplication M1 • M2.
- matr_det(M, D) : D is equal to the determinant of the square matrix M.


### Jobshop

Goal for this project is to solve two variants of the [job-shop scheduling problem](https://en.wikipedia.org/wiki/Job_shop_scheduling),
viewing it as a search problem. The first one only takes into account the jobs, tasks, machine types/counts and total deadline, while the
second one adds an extra constraint: each task can only be completed by a number of workers (staff). Some auxiliary files provided for
this project are:

- jobshop_validator.pl : validates whether a schedule is valid or not (based on job overlap constraints etc).
- jobshop_data.pl : data file used to test the program.


### Vertex Cover

Goal for this project is to solve the [vertex cover problem](https://en.wikipedia.org/wiki/Vertex_cover), seen as an optimization problem.
Basically, given a graph (which can be produced by graph.pl), we want to find the smallest set of vertices in the graph that covers it.
The ECLiPSe libraries [ic](https://www.eclipseclp.org/doc/bips/lib/ic/index.html) and
[branch_and_bound](http://eclipseclp.org/doc/bips/lib/branch_and_bound/index.html) were used to solve this problem.


### Stable Marriages

Goal for this project is to solve the [stable marriages problem](https://en.wikipedia.org/wiki/Stable_marriage_problem), seen as a
[CSP](https://en.wikipedia.org/wiki/Constraint_satisfaction_problem). The idea is that we have N men and N women and a list of partner
preferences for each one of them (of the other sex), and we want to match them into pairs, so that no unstable pair exists. The ECLiPSe
library [fd](http://eclipseclp.org/doc/bips/lib/fd/index.html) was used for this problem, in order to use variables with symbolic name
domains, instead of integer domains. Some auxiliary files provided for this project are:

- randstablefddata.c : C source file that produces random data files to test the program with.
- stablefd_data : data file used to test the program.


### Jobshop Opt

Goal for this project is again to solve the second variant of the job-shop problem, seen as an optimization problem this time. The chosen
utility function is the maximum possible deadline for which the jobs can be scheduled (that is, we're trying to schedule the jobs such that
the last job is scheduled as early as possible). Some auxiliary files provided for this project are:

- jobshop_opt_data.pl : data file used to test the program.
- rand_js_data.c : C source file that produces random data files to test the program with.

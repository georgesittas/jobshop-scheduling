# Prolog-CSP

This project contains the solutions to various search problems, including some constraint satisfaction problems, in
[ECLiPSe](https://en.wikipedia.org/wiki/ECLiPSe) Prolog. These problems were given as assignments for the course Logic
Programming ([YS05](http://cgi.di.uoa.gr/~takis/ys05.html)), NKUA, and they all received a perfect score of 100/100.
A brief description of the problem definitions follows:


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
[branch_and_bound](http://eclipseclp.org/doc/bips/lib/branch_and_bound/index.html) were used to solve this problem and the ones that follow.

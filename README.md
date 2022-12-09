# Job-Shop Scheduling

The job-shop scheduling problem is explained [here](https://en.wikipedia.org/wiki/Job_shop_scheduling). The heuristic function used
in this solver is the maximum possible deadline for which the jobs can be scheduled; that is, we're trying to schedule the jobs, so
that the last job is scheduled as early as possible. The implementation utilizes the ECLiPSe libraries `ic` and `branch_and_bound`.

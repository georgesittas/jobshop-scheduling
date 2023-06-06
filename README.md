# Job-Shop Scheduling

The job-shop scheduling problem is explained [here](https://en.wikipedia.org/wiki/Job_shop_scheduling). The heuristic function used
in this solver is the maximum possible deadline for which the jobs can be scheduled; that is, we're trying to schedule the jobs in a
way that minimizes the last job's ending time.

The implementation utilizes the ECLiPSe Prolog libraries `ic` and `branch_and_bound`.

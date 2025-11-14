###### tags: `Cluster`
# Parallel environments in SGE
## The case of Don Clusterio

Important links:
http://www.softpanorama.org/HPC/Grid_engine/parallel_environment.shtml
https://anilmaurya.wordpress.com/2015/05/08/sge-parallel-environment-pe/#:~:text=Parallel%20environment%20(PE)%20is%20the,is%20used%20by%20parallel%20jobs.

# Add the environment
```bash
sudo qconf -ap smp
```
```
pe_name            smp
slots              100
user_lists         NONE
xuser_lists        NONE
start_proc_args    NONE
stop_proc_args     NONE
allocation_rule    $pe_slots
control_slaves     FALSE
job_is_first_task  TRUE
urgency_slots      min
accounting_summary FALSE
qsort_args         NONE
```

Here I added 100 slots total. It needs to have something >0. I assume it could have millions, most of them unused and unattainable, of course. 

We should now see it:
```bash
soporte@tesla:~$ qconf -spl
smp
```

# Add the environment to a queue
```bash
sudo qconf -aattr queue pe_list smp all.q
```



:warning: The script `fsl_sub` needs to be slightly modified to be able to handle parallel environments in Don Clusterio. In particular, it does not like the `-w e` flag in `qsub` and exec hosts cannot run `qconf`. I have so far only modified fsl_sub in version 6.0.2 and saved it [here](https://drive.google.com/file/d/1ZFGbKkHH92e6zkCyji1KaCzyCUtuWKfc/view?usp=sharing).

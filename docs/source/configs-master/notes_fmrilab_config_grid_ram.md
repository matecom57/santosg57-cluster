I need to control how much RAM processes can consume.
Apparently, if I make mem_free a consumable, then this is possible,    
and each exec node should have its memory available declared.

I got this idea from [here](https://arc.liv.ac.uk/pipermail/gridengine-users/2007-February/013212.html)


# Make mem_free consumable
You need to be in the `admin` host, in my case `tesla`, and be `admin`.

```
sudo qconf -mc
```
Find the line that says 
```
mem_free            mf         MEMORY    <=    YES         NO        0        0
```
and change the `consumable` to `YES`


# Congifure each node's free_mem
For each exec node, do:
```
MEMFREE=`qhost -F mem_total -h $1|tail -n 1|cut -d: -f3|sed -e 
s/total/free/`
qconf -mattr exechost complex_values $MEMFREE $1
```





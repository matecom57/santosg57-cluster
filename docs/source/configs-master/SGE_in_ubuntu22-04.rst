###### tags: `Cluster`

SGE in ubuntu 22.04
===================

The ubuntu packages for gridengine segfault at installation time. This seems to be a known bug since 18.04, and clearly it will not be fixed. SGE is nearly dead, abandoned in debian and derivatives, since most HPC clusters now favor SLURM, Torque or other modern job schedulers. I refuse to let go of SGE, as it is exactly what I need for my cluster.

Fortunately, some nice folks at the University of Michigan have [forked SGE](https://github.com/daimh/sge) and continue its development. We will follow their instructions and compile from scratch.

There are some details that are specific to my setup, since I wish to retain some of the features I had already implemented in my installation of SGE under ubuntu 18.04. 

* User `sgeadmin` already exists on the server, with `uid=119(sgeadmin) gid=127(sgeadmin) groups=127(sgeadmin)`. This user does _not_ exist on the client machines, and wish I could create it on client machines but :warning:  gid=127 and uid=119 already exist on client machines, attributed to other services upon installation, so we cannot use `sgeadmin`. Will instead use user `sge` with `uid=666` and `gid=666`, creating it first on the server, then on the clients. :heavy_check_mark: I crated a script to do it, so that I don't make mistakes. It's called `configs/fmrilab_configure_SGE_step01.sh`
* I already took care of `/etc/hosts` on all machines (client and server).


Install the binaries in server (`hahn`)
---------------------------------------

First, install the dependencies:

.. code:: Bash

   apt install git build-essential libhwloc-dev libssl-dev libtirpc-dev libmotif-dev libxext-dev libncurses-dev libdb5.3-dev libpam0g-dev pkgconf libsystemd-dev cmake

(they were already installed)

Now, as user `soporte`, clone the forked SGE to its home. This way I can configure/compile/install in the server. 

.. code:: Bash

   git clone https://github.com/daimh/sge.git
    
Enter the cloned folder and build.

.. code:: Bash

   cd /home/inb/soporte/sge
   cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/opt/sge -DSYSTEMD=ON
   cmake --build build -j
   sudo cmake --install build

Create the user `sge` and give it ownership of the binaries

.. code:: Bash

   sudo ../configs/fmrilab_configure_SGE_step01.sh
   sudo chown -R sge /opt/sge

Let's install the master server. As `root`:


.. code:: Bash

   cd /opt/sge
   ./install_qmaster
    
Now, within that installer, accept all defaults (ports, communication medium-NIS, etc). Defaults are accepted by pressing ENTER. I counted NINE presses until I got to the one we do need to change, which is where it asks for the `SGE_CELL`. I do not like `default` and will change it to `fmrilab`. Why? Because I have other scripts that still use that variable, so I will not mess with it.

Then, when it asks for a cluster name, I set it to `Don_Clusterio`, which gets assigned to `SGE_CLUSTER_NAME`.

When it asks whether if I installed via a package or if I've checked the file permissions, I say `NO`, so that it performs the check for me. Nice detail!

Remember, in my case all hosts are in one DNS domain (`inb.unam.mx`), so I can say `y` to that question (Select default GE hostname resolving method).

The rest is just accepting the defaults.

And _fuck_: at the end the service did not start. It seems to be looking for the `default` and not `fmrilab` folder within `/opt/sge/`. Something is wrong with the installation script. Ah, but I can fix it! In fact, it's supposed to be fixed. Edit `/etc/systemd/system/sgemaster.service` and modify `default` to `fmrilab` in lines with `ExcecStart` and `ExecStop`. Since this will be done in many machines, let's create a `sed` script for that. So I apply the script `fmrilab_configure_SGE_step02.sh`. Now I must reload the service. I've added that to the step02 script, so that I do not forget.

Finally, prepare and configure `hahn` as submit host

.. code:: Bash

   source /opt/sge/fmrilab/common/settings.sh
   qconf -as hahn


:information_source: For each client to install, we need to set it up as an administrative host within the server. So you may be coming back to this section every time you are configuring a new client. It's simle, suppose your exec client is `mansfield`, so as `root` in the server `hahn`, we do:

.. code:: Bash

   qconf -ah mansfield


Configuring clients (as ``root``)
-------------------------------

:warning: (don't forget to use ``qconf -ah CLIENTNAME`` in the server before you go any further.)

Create the ``sge`` user. Use the script ``/home/inb/soporte/configs/fmrilab_configure_SGE_step01.sh``


I was able to copy the ``/opt/sge`` directory from another fully configured exec client, and need not compile again. So, do this:

.. code:: Bash

    scp -rp soporte@mansfield:/opt/sge /opt/sge

Now, back to ``/opt/sge``...

.. code:: Bash

    chown -R sge /opt/sge/fmrilab
    ./install_execd

:warning: Be careful when entering the cell name, it's **``fmrilab``**. Don't be a fool.


Again, the service did not start automatically because the file ``/etc/systemd/system/sgeexecd.service`` points to the ``default`` instead of ``fmrilab`` 
cell name. A simple ``sed`` fixes it, and it is now reflected in ``fmrilab_configure_SGE_step02.sh``.
    


<details>    
    <summary>Option copying from server, not advised.</summary>
    
  We create the folders and copy the binaries from the server.

.. code:: Bash

   mkdir -p /opt/sge/fmrilab
   chown -R sge /opt/sge/fmrilab
   scp -pr soporte@hahn:/opt/sge /opt/sge
   cd /opt/sge

Configure exec client. I tried running ./install_execd directly, but it complained about not finding the binaries (which were there, by the way). So I compiled it within the client. This is quick.

.. code:: Bash

   cd /home/inb/soporte/sge
   cmake --install build


It did complain at the end about some write permissions for soporte's home, but it seems to have done the trick.     
</details>details>
    

:information_source: Sourcing `/opt/sge/fmrilab/common/settings.sh` changes the user's PATH to point to the binaries we installed, so I will need to add this to each user's profile. Update: I put it in `$FMRILAB_CONFIGFILE`, which every user runs upon login. Nice!

# Configuring queues

This is done in the server ``hahn``.

Create a queue with ``qconf -aq``, modify an existing one with ``conf -mq``.

.. code:: Bash

   sudo su
   source /opt/sge/fmrilab/common/settings.sh
   qconf -aq all.q

Add the host to the second line, hostlist.

Add the exec client to the hosts group:

If the host group does not exist, use ``qconf -ahgrp @allhosts``. If it already exists, use:

.. code:: Bash

    qconf -mhgrp @allhosts

and add it to the second line.

Add the new host as a submit and exec host:

.. code:: Bash

   qconf -as NEWHOSTNAME
   qconf -ae NEWHOSTNAME

and change its max number of slots to ``nproc-1``:

.. code:: Bash

   qconf -aattr queue slots "[NEWHOSTNAME.inb.unam.mx=7]" all.q


After that, ``qstat -f`` should show it in the list!

![](https://i.imgur.com/rmeDdWg.png)

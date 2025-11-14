


1 de agosto de 2018
lconcha
Disponible en:
https://github.com/lconcha/configs/blob/master/client_18-04.md

# Instalación 

Iniciamos con una PC con dos discos duros, uno chico (120GB) y uno grande (>750GB). En este caso el chico es `sdb` y el grande es `sda`. Se instala ubuntu desktop 18.04 (full instalation, no minimal, y se dan permisos para third-party codecs). La instalación y el sistema operativo se hacen en inglés.

## Particiones
Cuando pregunta dónde instalar ubuntu, le decimos "something else" y ajustamos nuestras particiones de acuerdo a:
```
/dev/sdb1	efi				536MB
/dev/sdb2	ext4	/		40GB (esta particion siempre asi)
/dev/sdb3 	ext4	/tmp	75GB (esta puede cambiar, ser mas grande; es lo que sobre del disco)
/dev/sdb4   swap			15GB (esta siempre asi)
/dev/sda1	ext4	/datos	750GB
```

El bootloader queda en `sdb` (o equivalente en cada máquina) porque es el SSD en este caso.. 

La particion en   `/tmp` debe ser suficientemente grande, digamos 75GB. Si no, ponerla en el otro disco. Esta partición es importante porque muchos trabajos del tipo de $fsl$ y $mrtrix$ ocupan muchos datos temporales que quedan en `/tmp` y,  si son muchos, puede llenar completamente el disco duro si la partición `/`y `/tmp` comparten la misma unidad física.

El nombre del primer usuario es `soporte_$hostname` y el password sigue la nomenclatura conocida. En caso de que solo contemos con un disco duro, entonces debe haber particiones distintas para `/` **(40GB siempre)**, `/tmp`, `/datos`(si es necesario) y swap.

El nombre del primer usuario es `soporte_$hostname` y el password sigue la nomenclatura conocida.



## root
Habilitamos la cuenta de root porque si no vamos a tener problemas de UID con el usuario lconcha que vive en el servidor (el default del primer usuario es UID=1000, y lconcha en el servidor es también 1000). Con el usuario root vamos a poder instalar todo. Esto será particularmente útil justo antes de instalar el NIS. **El password de root deberá ser el mismo que el que usemos para soporte_HOSTNAME.**

```
sudo passwd root
sudo passwd -u root
```


# Red
Ir a `settings`, después a `network` y en `wired` dar al ícono de configuración. En la pestaña `IPv4`. Cambiamos a manual.

Address: 172.24.*.* (según computadora)
Netmask: 255.255.255.224
Gateway: 172.24.80.126 (cambia en cada laboratorio)
Cambiar el DNS de Automatic a OFF y escribir los nuestros:
DNS: 132.248.10.2,132.248.204.1,208.67.222.222	

Poner `apply` y luego apagar y prender el ethernet device. 
`ip address` nos debería indicar bien nuestra dirección IP	


# Driver tarjeta de video
Casi todas las computadoras tienen tarjeta Nvidia, pero también puede ser AMD/ATI o Intel. Para saber cuál es, podemos abrir la PC y ver la tarjeta, o desde una terminal:
```
lspci | grep VGA
```
Si regresa algo como `VGA compatible controller: NVIDIA Corporation`, entonces sí tenemos una Nvidia.

Si regresa algo como `VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI]`,  en ese caso no se debe seguir este paso. Me falta saber cómo instalar la aceleración de AMD.

La configuración para Nvidia (y supongo que para ATI también) es gráfica. Se agregan los **drivers de la *tarjeta de video*** a través de la interface gráfica que se consigue presionando la tecla Meta (la del ícono del Windows), y escribir `software` , abrimos el programa y vamos a la pestaña `additional drivers` Seleccionamos el correspondiente a la tarjeta de video (Algo así como `Nvidia binary driver (proprietary), versión 390`, o el número más alto que aparezca. No utilizar el driver `nouveau`. No lo sé aún, pero supongo que para ATI ha de ser igual.

# Reboot
Una vez que reinicie la máquina, nos saludará la interface gráfica llamada `gdm`, donde podemos escribir nuestro nombre de usuario. Para fines de configuración, no la vamos a utilizar, porque vamos a hacer login de texto con el usuario `root`. Para ello:
**presionamos simultáneamente `Ctrl+Alt+F3` y hacemos login como root**.

# Hosts
Tengo un script que ayuda a configurar los hosts.
De aquí en adelante se asume que **hicimos login (de texto) como root.**
```
scp -r soporte@172.24.80.102:/home/inb/soporte/configs .
cd configs
./fmrilab_fix_hosts_file.sh
```

Probamos con un `ping tesla`, que nos debe funcionar.

**Nota:** La carpeta `configs` tiene varios scripts que vamos ir usando a lo largo de esta instalación. 


# verbose boot
Para facilitar detección de errores, hagamos que el boot sea feo pero informativo
```
nano /etc/default/grub
```

modificamos la línea que contiene `GRUB_CMDLINE_LINUX_DEFAULT` a que lea:
`GRUB_CMDLINE_LINUX_DEFAULT=""`

Y hacemos update a grub
```
update-grub
```



# NFS y autofs
Para que más adelante veamos `/home/inb`es importante que primero pongamos el NFS. 



*El  `/home/inb` queda en  fstab como NVSv4* Esto se configura:
```
mkdir /home/inb
./fmrilab_fix_fstab.sh
```

** Si la maquina no está aún configurada en el servidor `tesla`, debemos agregarla ahí usando el script `fmrilab_fix_hosts_file.sh` y agregarla por nombre a `/etc/netgroup`

Corremos un script para ello:
```
./fmrilab_fix_misc.sh
```



 **Ojo** El script también instalará `cachefilesd` para agilizar (en teoría) el acceso de los homes montados mediante nfs. Para ello, la ruta montada indicada en`auto.home` tiene 	 la opción `fsc`.


# NIS
Y para evitar problemas próximos, agregamos a `soporte` como sudoer
```
visudo
```


agregar:
```
soporte ALL=(ALL:ALL) ALL
```

Corremos el script
```
./fmrilab_config_nis.sh
```


Preguntará por un dominio, el cual es `fmrilab`

**OJO** El password de `soporte`, al ser designado por el NIS, es el mismo de siempre.

**OJO2** El script `fmrilab_config_nis.sh` contiene un paso muy interesante (latoso de encontrar solución) que elimina un problema de incompatibilidad entre `systemd.login` y `NIS`.  Para leer al respecto, vale la pena checar [este link](https://wiki.archlinux.org/index.php/NIS#.2Fetc.2Fpam.d.2Fpasswd), y la versión *ubuntizada* en [este otro link](https://askubuntu.com/questions/1031022/using-nis-client-in-ubuntu-18-04-crashes-both-gnome-and-unity).

**Ojo3:** Dado que `/home` de la máquina ha sido *cubierto* por `/home` indicado por `autofs`, el HOME del primer usuario de la máquina se va a desaparecer (no borrar, pero inaccesible porque hay una capa de autofs sobre /home).  Además, el UID del primero usuario normalmente es 1000, que colisiona con el UID del usuario `lconcha`en el servidor NIS, por lo que si alguna vez de usa el usuario soporte_HOSTNAME, es posible que pida el password de lconcha, lo cual está mal. Para evitar problemas, el script de arriba va a cambiar el home del primer usuario a una carpeta adentro de `/localhome`  , y va a cambiar el UID del primer usuario (soporte_HOSTNAME) a 5000. Podemos asegurarnos que este paso corrió, utilizando `id soporte_HOSTNAME`, y veremos que UID=5000. :warning: No es cierto, esto no se puede hacer mientras soporte_HOSTNAME está logeado.

:warning: Actualización 28 sep 2020: Cambié la manera en que se exporta y monta `/home/inb`. Pasamos de NFSv3 a NFSv4, y ya no se monta mediante `autfs`, sino mediante `/etc/fstab`. La razón es que de pronto los homes se hicieron lentos y viene explicado [aquí](https://hackmd.io/@lconcha/S1dsZzKrP), y los pasos para arreglar una máquina en caliente vienen [acá](https://hackmd.io/@lconcha/rkrJeFkUv). El 28 de sep pasé todas las máquinas a homes mediante NFSv4 y fstab, y edité los scripts de este repositorio.

**Ojo4:** Tengo grabado en el google drive los archivos passwd y shadow, por si es necesario modificar el servidor. El archivo se llama baks_tesla.tar.gz



# NFS
**Este paso no puede ser automatizado** porque depende de cuántos discos duros tiene la máquina.

Instalamos lo necesario
```
apt install nfs-kernel-server
```


Editamos `/etc/exports` y agregamos
```
/datos/NEWHOSTNAME @fmrilab_hosts(rw,no_subtree_check,sync)
```
Si tenemos más discos duros que exportar, serán `/datos/NEWHOSTNAME2`, `/datos/NEWHOSTNAME3`, etc, y cada uno de ellos debe estar en `/etc/exports`, cada uno como una línea, con las mismas opciones a partir de @fmrilab_hosts...

Donde `NEWHOSTNAME`es el nombre que le hemos dado a este cliente.

Y reiniciamos el servidor NFS
```
/etc/init.d/nfs-kernel-server restart
```

**OJO** Tendremos que declarar este export en todas las otras máquinas, lo que se hace fácilmente si editamos `fmrilab_auto.misc` y corremos en cada máquina los scripts `fmrilab_fix_hosts_file.sh` y `fmrilab_fix_misc.sh`





# Configurar software
El software está centralizado. Algunas librerías y dependencias cambiaron entre ubuntu 14.04 y 18.04. Para arreglarlo, corremos el script
```
./fmrilab_softwareconfig.sh
```

Esto instala también varios programas que queremos que estén en la propia máquina (no centralizados, como fsl, mrtrix o freesurfer), por ejemplo: rstudio, google-chrome, chromium-browser, x2go, sshfs, inkscape, keepass, htop, tree, curl. Además se aprovecha para instalar (en un solo paso), los programas que se requieren para que mrtrix, fsl y freesurfer corran bien (tcsh, libmng, libgtkglext1, etc).


Ya casi vamos a rebootear, así que ahora:
```
apt update
apt upgrade
```

# reboot


# SGE
Todas las computadoras, excepto `tesla`, son nodos `submit` y `exec` dentro del cluster `fmrilab`. Configuremos una nueva computadora así. Para configurarla, hay que hacer ciertos pasos en la nueva computadora, a la que llamaremos `NEWHOST` (nombres comunes en el laboratorio son purcell, ernst, rhesus, arwen, etc. El servidor es `tesla`.

## Login en `NEWHOST`
Primero, hacemos login como `root` para instalar lo necesario en `NEWHOST`
```
apt install gridengine-exec gridengine-client
```
Este comando nos preguntará el `CELL name`, y ahí pondremos `fmrilab`


## Login en `tesla`
Ahora hacemos login somo `soporte` en `tesla` para agregar el nodo como exec y submit.

```
qconf -mq all.q
```

Esto abrirá un editor de texto con la configuración de la cola `all.q`. Agregar el host (`NEWHOST`, usando el nombre que le dimos) a la lista de hosts. (si el editor es vi, recuerda que presionar `i` nos permitirá editar, y para salir y grabar presionamos `ESC` y escribimos: `wq`).

Agregamos el NEWHOST al grupo de hosts
```
qconf -mhgrp @allhosts
```

Agregamos NEWHOST como submit host
```
qconf -as NEWHOSTNAME
```

Agregamos NEWHOST como exec host
```
qconf -ae NEWHOSTNAME
```

Es opcional, pero a mí me gusta cambiar el número máximo de slots para correr jobs de cada nuevo exec host. En general, la fórmula para número de slots es `nslots = nprocesadores - 1`. Para saber cuántos procesadores tenemos, podemos usar `nproc`.
```
qconf -aattr queue slots “[NEWHOSTNAME.inb.unam.mx=7]" all.q
```

## Login en `NEWHOST`
reconfigurar SGE para que ya lo reconozca el servidor.
```
sudo dpkg-reconfigure gridengine-exec
```
Ya debería ser posible ver el nuevo host usando
```
qstat -f
```
Si no está bien configurado, aparecerá el NEWHOST como `N/A`.


Probamos el cluster enviando un trabajo muy sencillo:
```
fsl_sub -N prueba hostname
```
Nos debe regresar en la terminal un número, que es nuestro *ticket* en la cola del cluster.  Si hacemos `qstat` lo veremos en la lista. Cuando desaparece, es que corrió. Si no vemos output de `qstat`, algo anda mal.

Al final, debe haber dos archivos nuevo llamado `prueba.o?????` y `prueba.e?????`. Los `?` indican números y son iguales al ticket que recibimos. Si hacemos `cat prueba.o?????` veremos el nombre del host donde corrió nuestra prueba, indicando que todo está bien.

**Ojo:**  El archivo de configuración que corre cada vez que se inicia una sesión, `$FMRILAB_CONFIGFILE` declara el valor de `SGE_ROOT`que, sin él, `fsl_sub` asume (incorrrectamente) que no hay un cluster SGE. El valor correcto de `SGE_ROOT` es `/var/lib/gridengine`. Este paso no debe hacerse al configurar una máquina, porque en cada sesión se va a declarar esta variable de entorno.


## Singularity
Nada más correr el script `fmrilab_config_singularity.sh`, que lo único que hace es una carpeta en /opt para que ahí quede el localstatedir (ver [aquí](https://singularity.lbl.gov/admin-guide) para más info).




## Ganglia monitor
Hay que correr el script `fmrilab_config_ganglia_client.sh`. Este script instala y configura ganglia de acuerdo a [estas instrucciones](HOWTO-ganglia.md) (ahí está también cómo instalarlo en el servidor `tesla`). A veces se tarda unos minutos en que aparezca en la web interface (en [http://172.24.80.102/ganglia](http://172.24.80.102/ganglia)), y en ocasiones es necesario apagar y volver a prender el servicio en el cliente usando `systemctl restart ganglia-monitor`.

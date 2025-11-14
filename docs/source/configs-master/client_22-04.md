


27 de mayo de 2022
lconcha
Disponible en:
https://github.com/lconcha/configs/blob/master/client_22-04.md

# Instalación 

Iniciamos con una PC con dos discos duros, uno chico (120GB) y uno grande (>750GB). En este caso el chico es `sdb` y el grande es `sda`. Se instala ubuntu desktop 18.04 (full instalation, no minimal, y se dan permisos para third-party codecs). La instalación y el sistema operativo se hacen en inglés.

## Particiones
Cuando pregunta dónde instalar ubuntu, le decimos "something else" y ajustamos nuestras particiones de acuerdo a:
```
/dev/sdb1	efi				536MB
/dev/sdb2	ext4	/		60 a 120 GB (min 60 en caso de un solo disco chico, max 120 para SSDs grandes)
/dev/sdb3 	ext4	/tmp	75GB (esta puede cambiar, ser mas grande; es lo que sobre del disco)
/dev/sdb4   swap			15GB (esta siempre asi)
/dev/sda1	ext4	/datos	750GB
```

El bootloader queda en `sdb` (o equivalente en cada máquina) porque es el SSD en este caso.. 

La particion en   `/tmp` debe ser suficientemente grande, digamos 75GB. Si no, ponerla en el otro disco. Esta partición es importante porque muchos trabajos del tipo de $fsl$ y $mrtrix$ ocupan muchos datos temporales que quedan en `/tmp` y,  si son muchos, puede llenar completamente el disco duro si la partición `/`y `/tmp` comparten la misma unidad física.

El nombre del primer usuario es `soporte_$hostname` y el password sigue la nomenclatura conocida. En caso de que solo contemos con un disco duro, entonces debe haber particiones distintas para `/` **(~70GB)**, `/tmp`, `/datos`(si es necesario) y swap.

El nombre del primer usuario es `soporte_$hostname` y el password sigue la nomenclatura conocida.



## root
Habilitamos la cuenta de root porque si no vamos a tener problemas de UID con el usuario lconcha que vive en el servidor (el default del primer usuario es UID=1000, y lconcha en el servidor es también 1000). Con el usuario root vamos a poder instalar todo. Esto será particularmente útil justo antes de instalar el NIS. **El password de root deberá ser el mismo que el que usemos para soporte_HOSTNAME.**

```
sudo passwd root
sudo passwd -u root
```


# Red

## En terminal

login root (en nueva terminal)

Utilizar el comando `nmtui`  para configurar la red.

Navegamos a la conección a editar y camniamos a manual la configuraicon de IPv4.

Address: 172.24.*.* (según computadora)
Gateway: 172.24.80.126 (cambia en cada laboratorio)
DNS servers: 132.248.10.2,132.248.204.1,208.67.222.222	

## En interfaz grafica
Ir a `settings`, después a `network` y en `wired` dar al ícono de configuración. En la pestaña `IPv4`. Cambiamos a manual.

Address: 172.24.*.* (según computadora)
Netmask: 255.255.255.224
Gateway: 172.24.80.126 (cambia en cada laboratorio)
Cambiar el DNS de Automatic a OFF y escribir los nuestros:
DNS: 132.248.10.2,132.248.204.1,208.67.222.222	

Poner `apply` y luego apagar y prender el ethernet device. 
`ip address` nos debería indicar bien nuestra dirección IP	


# Driver tarjeta de video
Usemos el comando `ubuntu-drivers`. Con `-list`  nos muestra si hay algo que instalar. De ser el caso, usamos:

```
ubuntu-drivers install
```


# Reboot
Una vez que reinicie la máquina, nos saludará la interface gráfica llamada `gdm`, donde podemos escribir nuestro nombre de usuario. Para fines de configuración, no la vamos a utilizar, porque vamos a hacer login de texto con el usuario `root`. Para ello:
**presionamos simultáneamente `Ctrl+Alt+F3` y hacemos login como root**.

:warning: ** No olvidar hacer login como root! **


# Hosts
Tengo un script que ayuda a configurar los hosts.
De aquí en adelante se asume que **hicimos login (de texto) como root.**
Nota: Por ahora el servidor es hahn con ip 172.24.80.109
```
scp -r soporte@172.24.80.109:/home/inb/soporte/configs .
cd configs
./fmrilab_fix_hosts_file.sh
```

Probamos con un `ping hahn`, que nos debe funcionar.

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

** Si la maquina no está aún configurada en el servidor `hahn`, debemos agregarla ahí usando el script `fmrilab_fix_hosts_file.sh` y agregarla por nombre a `/etc/netgroup`

Corremos un script para ello:
```
./fmrilab_fix_misc.sh
```



 **Ojo** El script también instalará `cachefilesd` para agilizar (en teoría) el acceso de los homes montados mediante nfs. Para ello, la ruta montada indicada en`auto.home` tiene 	 la opción `fsc`.

 **Ojo** Hay que agregar a la nueva PC como parte de `nethosts` editando el archivo `/etc/netgroup` en el servidor (`hahn`), y para que haga efecto hay que recompilar con `sudo make -C /var/yp`. Si no hacemos este paso, la nueva PC no va a poder ver los `/misc`.


# NIS
Y para evitar problemas próximos, agregamos a `soporte` como sudoer
```
visudo
```

agregar:
```
soporte ALL=(ALL:ALL) ALL
```

Y también agregamos a `staff` a la lista de sudoers corriendo:

```
fmrilab_add_sudoers.sh
```



Modificamos el UID del primer usuario de esta PC, de lo contrario va a colisionar con el de lconcha en el servidor (UID=1000)
```
./fmrilab_mod_uid_soporte_local.sh
```

Corremos el script
```
./fmrilab_config_nis.sh
```



**OJO** El password de `soporte`, al ser designado por el NIS, es el mismo de siempre.

**OJO2** El script `fmrilab_config_nis.sh` contiene un paso muy interesante (latoso de encontrar solución) que elimina un problema de incompatibilidad entre `systemd.login` y `NIS`.  Para leer al respecto, vale la pena checar [este link](https://wiki.archlinux.org/index.php/NIS#.2Fetc.2Fpam.d.2Fpasswd), y la versión *ubuntizada* en [este otro link](https://askubuntu.com/questions/1031022/using-nis-client-in-ubuntu-18-04-crashes-both-gnome-and-unity).

**Ojo3:** Dado que `/home` de la máquina ha sido *cubierto* por `/home` indicado por `autofs`, el HOME del primer usuario de la máquina se va a desaparecer (no borrar, pero inaccesible porque hay una capa de autofs sobre /home).  Además, el UID del primero usuario normalmente es 1000, que colisiona con el UID del usuario `lconcha`en el servidor NIS, por lo que si alguna vez de usa el usuario soporte_HOSTNAME, es posible que pida el password de lconcha, lo cual está mal. Para evitar problemas, el script de arriba va a cambiar el home del primer usuario a una carpeta adentro de `/localhome`  , y va a cambiar el UID del primer usuario (soporte_HOSTNAME) a 5000. Podemos asegurarnos que este paso corrió, utilizando `id soporte_HOSTNAME`, y veremos que UID=5000. :warning: No es cierto, esto no se puede hacer mientras soporte_HOSTNAME está logeado.

:warning: Actualización 28 sep 2020: Cambié la manera en que se exporta y monta `/home/inb`. Pasamos de NFSv3 a NFSv4, y ya no se monta mediante `autfs`, sino mediante `/etc/fstab`. La razón es que de pronto los homes se hicieron lentos y viene explicado [aquí](https://hackmd.io/@lconcha/S1dsZzKrP), y los pasos para arreglar una máquina en caliente vienen [acá](https://hackmd.io/@lconcha/rkrJeFkUv). El 28 de sep pasé todas las máquinas a homes mediante NFSv4 y fstab, y edité los scripts de este repositorio.

**Ojo4:** Tengo grabado en el google drive los archivos passwd y shadow, por si es necesario modificar el servidor. El archivo se llama baks_hahn.tar.gz



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

## Modulos

El software de modulos se instalo con fmrilab_softwareconfig (Nota al futuro: Dado que al fin del dia es un script, es posible centralizar los enviroment modules dentro de lanirem_software). 

Las configuraciones de los paths de los modulos de don clusterio se encuentran en FMRILAB_CONFIGFILE. Pero por si acaso actualizamos los modulos iniciales (los que apuntan a la carpeta de modulos del home de soporte) del enviroments module con 
```
./fmrilab_fix_modulespath_file.sh
```

# Matlab
*Nota* Con los modulos esto ya no sera necesario cuando centralicen matlab en lanirem_software.

Simplemente copiar la instalación de otra máquina. Eso ya incluye la licencia de red (que voltea a ver al servidor). Como `root`:

```
sudo rsync -avz --partial --progress  soporte@mansfield:/usr/local/MATLAB /usr/local/
```

## Singularity
Nada más correr el script `fmrilab_config_singularity.sh`, que lo único que hace es una carpeta en /opt para que ahí quede el localstatedir (ver [aquí](https://singularity.lbl.gov/admin-guide) para más info).


# Configurar fmrilab_profile

Copiamos fmrilab_profile.sh a /etc/profile.d . Este script contiene las configuraciones de arranque para las máquinas en don clusterio. Por el momento solo consifte en exportar la variable de sistema FMRILAB_CONFIGFILE que tiene todo los paths de los software 
```
./fmrilab_config_profile.sh
```


# reboot

Antes de reebotear una actualizacion del software y despues reboot
```
apt update
apt upgrade
apt reboot
```



# SGE
Con la llegada del 22.04 ya no se puede usar `gridengine` desde los repositorios, pues truenan al compilar. Afortunadamente existe un fork y hay que compilarlo manualmente. Instrucciones completas en [este link](./SGE_in_ubuntu22-04.md).

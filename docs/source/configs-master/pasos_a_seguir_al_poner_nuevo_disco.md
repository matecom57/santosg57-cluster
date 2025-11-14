1. Instalar físicamente disco mediante SATA
2. Entrar como `soporte` y abrir aplicación Disks.
 * Crear la partición del disco, si es necesario.
 * Copiar el UUID de la partición.

3. Editar `/etc/fstab` y agregar mediante la UUID el disco, apuntando hacia `/datos/HOSTNAME?` donde `?` es el número de disco que estamos poniendo.

4. Montar el disco
 * `mount /datos/HOSTNAME?`

5. Arreglar permisos.
 * `chgrp fmriuser /datos/HOSTNAME?`
 * `chmod g+rwX /datos/HOSTNAME?`
 * `chown soporte /datos/HOSTNAME?`

6. Exportar el disco editando `/etc/exports`

7. Reiniciar servidor NFS en HOST
 * `service nfs-kernel-server restart`

8. Editar el archivo maestro de `/home/inb/soporte/configs/fmrilab_auto.misc` y agregar la nueva línea.

9. En el resto de las máquinas ejecutar como root `/home/inb/soporte/configs/fmrilab_fix_misc.sh`

10. En sesamo agregar nuevo destino de backups. 
 * Entrar como `admin` a `sesamo` e ir a carpeta `/volume1/fmrilab/backup`.
 * Editar archivo `listOfDestinations=/volume1/fmrilab/backup/datos_backup_locations.txt`

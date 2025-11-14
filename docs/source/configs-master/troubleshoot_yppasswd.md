# yppasswd & ypserv
A veces se apaga el servidor de yppasswd. Esto tiene que hacerse en el servidor (hahn).


    # sudo service yppasswd start
   
   
    sudo systemctl enable yppasswdd
    sudo systemctl enable ypserv
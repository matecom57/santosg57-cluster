# Install ganglia on server (tesla)

:warning: I attempted to copy the instructions from 18.04 with minor changes.  Sadly **it is not working**.

https://www.alibabacloud.com/blog/how-to-install-ganglia-monitoring-server-on-ecs-ubuntu-18-04_595713


## Prepare the system (server, i.e. `tesla`)
```
sudo apt-get install apache2 mariadb-server php8.1
```

Got message:
```
You should also check the permissions and ownership of the /var/lib/mysql directory:            │

   adduser --system --group --home /var/lib/mysql mysql

You should also check the permissions and ownership of the var/lib/mysql directory:            │

  /var/lib/mysql: drwxr-xr-x   mysql    mysql
```

So I do as I'm told:
```
adduser --system --group --home /var/lib/mysql mysql

```
but I find that the user `mysql` already exists. So I now check the permissions, and they also seem fine:
```
drwxr-xr-x  4 mysql         mysql         4096 Jan 31 17:33 mysql/
```
Carry on, then...


Start Apache and MariaDB services, and also make them run at boot.
```
sudo systemctl start apache2
sudo systemctl enable apache2
sudo systemctl start mariadb
sudo systemctl enable mariadb
```

## Install ganglia in server (`tesla`)
```
sudo apt-get install ganglia-monitor rrdtool gmetad ganglia-webfrontend
```
(choose to restart Apache2 when asked. I got asked twice.)

Check if ganglia is up:
```
systemctl status ganglia-monitor.service
```

## Configure master node (`tesla`)
Edit `/etc/ganglia/gmetad.conf`. Change the line that says `data_source "my cluster" localhost` to read:
```
data_source "Don Clusterio" 172.24.80.102
```
where `Don_Clusterio` is the awesome name of the cluster and that is it's IP address of `tesla`, which is the server.

Now edit `/etc/ganglia/gmond.conf` to read this:
```
/* If a cluster attribute is specified, then all gmond hosts are wrapped inside
 * of a <CLUSTER> tag.  If you do not specify a cluster tag, then all <HOSTS> will
 * NOT be wrapped inside of a <CLUSTER> tag. */
cluster {
  name = "Don_Clusterio"
  owner = "INB-UNAM"
  latlong = "unspecified"
  url = "unspecified"
}

/* The host section describes attributes of the host, like the location */
host {
  location = "INB, UNAM Campus Juriquilla"
}

/* Feel free to specify as many udp_send_channels as you like.  Gmond
   used to only support having a single channel */
udp_send_channel {
  host = 172.24.80.102
/*  mcast_join = 239.2.11.71 */
  port = 8649
  ttl = 1
}

/* You can specify as many udp_recv_channels as you like as well. */
udp_recv_channel {
/*  mcast_join = 239.2.11.71 */
  port = 8649
/*  bind = 239.2.11.71 */
}

/* You can specify as many tcp_accept_channels as you like to share
   an xml description of the state of the cluster */
tcp_accept_channel {
  port = 8649
}
```

Copy the ganglia config file to Apache:
```
sudo cp /etc/ganglia-webfrontend/apache.conf /etc/apache2/sites-enabled/ganglia.conf
```
(this is in [this](https://www.alibabacloud.com/blog/how-to-install-ganglia-monitoring-server-on-ecs-ubuntu-18-04_595713) tutorial, but not in [this other one](https://hostpresto.com/community/tutorials/how-to-install-and-configure-ganglia-monitor-on-ubuntu-16-04/), but I did it anyway)

We now start the ganglia monitor:
```
systemctl restart ganglia-monitor.service
systemctl restart gmetad.service
systemctl restart apache2.service
```


## Configure client (any of the computers on the cluster)
I'm running this example on `mansfield`:

```
sudo apt install ganglia-monitor
```

Edit `/etc/ganglia/gmond.conf`
```
globals {
  daemonize = yes
  setuid = yes
  user = ganglia
  debug_level = 0
  max_udp_msg_len = 1472
  mute = no
  deaf = yes # this is important to reduce CPU usage
  host_dmax = 0 /*secs */
  cleanup_threshold = 300 /*secs */
  gexec = no
  send_metadata_interval = 0
}

/* If a cluster attribute is specified, then all gmond hosts are wrapped inside
 * of a <CLUSTER> tag.  If you do not specify a cluster tag, then all <HOSTS> will
 * NOT be wrapped inside of a <CLUSTER> tag. */
cluster {
  name = "aleph"
  owner = "INB-UNAM"
  latlong = "unspecified"
  url = "unspecified"
}

/* The host section describes attributes of the host, like the location */
host {
  location = "unspecified"
}

/* Feel free to specify as many udp_send_channels as you like.  Gmond
   used to only support having a single channel */
udp_send_channel {
/*  mcast_join = 239.2.11.71 */
  host = 172.24.80.102
  port = 8649
  ttl = 1
}
```

And, finally, start the ganglia monitor service
```
systemctl start ganglia-monitor
```

Now you can go to the server web interface:
http://172.24.80.102/ganglia

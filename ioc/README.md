# Image for EPICS IOC

Docker image for a ready-to-use EPICS ioc with various support modules

# How to use this image

## Start an ioc instance

Starting an ioc instance is simple:
```bash
$ docker run --name some-ioc -it paluma.ruhr-uni-bochum.de/epics/ioc:tag
```
... where `some-ioc` is the name you want to assign to your container and `tag` is the tag specifying the ioc version you want.

By default, an interactive ioc-shell is started within the container which requires STDIN to be open (`-i` flag of `docker run`).

### Databases and Protocols

This image also provides a collection of various database and protocol files for [StreamDevice](https://paulscherrerinstitute.github.io/StreamDevice/).
The environment variables `DB_FILE_PATH` and `STREAM_PROTOCOL_PATH` are set inside the container to point to the respective location of these files.

If you want to load e.g. the `hmp4040.db` database, you can use the following command in the ioc shell:
```
dbLoadRecords( "$(DB_FILE_PATH)/hmp4040.db" )
```

## Channel access connections

To allow Channel Access or PVaccess clients to see the PVs inside your ioc shell, the corresponding ports of the container need to be mapped
to the corresponding ports of your host system:
```bash
$ docker run --name some-ioc -it \
  -p 5064:5064 -p 5064:5064/udp \
  paluma.ruhr-uni-bochum.de/epics/ioc:tag
```

## Providing a custom start up script

You can provide your own start up script for the ioc.

If `/my/custom/my-st.cmd` is the path and name of your custom start-up script, you can start your EPICS ioc container like this:
```bash
$ docker run --name some-ioc -dit -v /my/custom:/config paluma.ruhr-uni-bochum.de/epics/ioc:tag my-st.cmd
```
Note that only the filename (*without* path) is given as a command to the container.
If a file with this name is located in `/config` the ioc shell will be started and reading the contents of this file.

If the `dbLoadDatabases` command is missing in your custom start-up script, the ioc shell loads it's default database definitions.

**ATTENTION:** any arguments after the first start-up script will be ignored by the ioc shell!!

## Starting a non-interactive ioc

The EPICS ioc supports a non-interactive mode. In this case it is mandatory to provide a proper start-up script that loads all
required drivers and databases. Otherwise the ioc will simply do nothing.

You can start the container in a non-interactive mode by using the command:
```bash
$ docker run --name some-ioc -d -v /my/custom:/config paluma.ruhr-uni-bochum.de/epics/ioc:tag -S my-st.cmd
```
The `-S` option in front of the start-up script tells the ioc shell to start the non-interactive mode.

## Connecting devices

Depending on the used interface of your devices, some additional options might be required for the container to be able to access the interfaces.

### Connecting to a serial device

Assuming you want to connect to a device with is connected to the serial interface `/dev/ttyS0` on your host system.
To give the ioc access to this device you need to start the container with the command:
```bash
$ docker run --name some-ioc -dit --device /dev/ttyS0 -v /my/custom:/config paluma.ruhr-uni-bochum.de/epics/ioc:tag my-st.cmd
```
The `--device <DEV>` option adds a host device to the container so that the ioc can access it.

### Connecting to a CAN bus

The available device support routines inside this image use libsocketcan for the connection.
Libsocketcan exposes the CAN bus interface as a network device.
To access this network device from with the container, network mode `host` is required:
```bash
$ docker run --name some-ioc -dit --network host -v /my/custom:/config paluma.ruhr-uni-bochum.de/epics/ioc:tag my-st.cmd
```
**ATTENTION:** This does *not* work with rootless docker!!

## Caveats

Network bridges (as the default docker network) do not forward broadcasts.
Thus the ioc shell cannot act as CA/PVaccess client by default.

There are possible workarounds:

- Use network mode `host`:
  ```bash
  $ docker run --name some-ioc -dit --network host -v /my/custom:/config paluma.ruhr-uni-bochum.de/epics/ioc:tag my-st.cmd
  ```
  **ATTENTION:** This approaches will not work with rootless docker!

- Create a docker network with `ipvlan` or `macvlan` drivers
  ```bash
  $ ip addr show up
  2: enp7s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
      link/ether 70:85:c2:33:f9:1b brd ff:ff:ff:ff:ff:ff
      inet 192.168.0.1/24 brd 192.168.0.255 scope global enp7s0
         valid_lft forever preferred_lft forever
  $ docker network create -d ipvlan \
      --subnet=192.168.0.128/25 \
      --gateway=192.168.0.1 \
      -o parent=enp7s0 pub_net
  $ docker run --name some-ioc -dit --network pub_net -v /my/custom:/config paluma.ruhr-uni-bochum.de/epics/ioc:tag my-st.cmd
  ```
  **ATTENTION:** This approaches will not work with rootless docker!
  The docker engine will assign an ip address to the container independend of any DHCP server eventually running on this network.
 
- Manually set the the list of CA/PVaccess servers:
  ```bash
  $ docker run --name some-ioc -dit -v /my/custom:/config \
    -e EPICS_CA_AUTO_ADDR_LIST=no -e EPICS_CA_ADDR_LIST=<LIST OF IP ADDRESSES OF CA SERVERS> \
    -e EPICS_PVA_AUTO_ADDR_LIST=no -e EPICS_PVA_ADDR_LIST=<LIST OF IP ADDRESSES OF PVA SERVERS> \
    paluma.ruhr-uni-bochum.de/epics/ioc:tag my-st.cmd
  ```

Due to the way the PVaccess protocoll is implemented, communication with the PVAserver of the IOC is not possible with bridge networks, even if the corresponding ports are mapped.
See [this issue](https://github.com/epics-base/pvAccessCPP/issues/197).

Either use host/ipvlan/macvlan network for the Docker container or add a pva-gateway with network host/ipvlan/macvlan that uses the bridged docker network as client side.

# Build

Some of the support modules are private git repositories.
In order to download the code, the docker build container needs access to your SSH key.
One way is to use the SSH agent:
```bash
$ eval $(ssh-agent)
$ ssh-add ~/.ssh/id_rsa
$ docker build --pull [--platform=linux/amd64,linux/arm64,linux/arm/v7] [--push] --ssh default [--build-arg ARG=VALUE]... -t <REGISTRY>/ioc:<TAG> .
```

## Docker Build Arguments

| Variable                 | Description                                             | Default value                        |
|--------------------------|---------------------------------------------------------|--------------------------------------|
| EPICS_BASE_IMG           | Name of the base image to use                           | paluma.ruhr-uni-bochum.de/epics/base |
| EPICS_BASE_VERSION       | Tag of the base image to use                            | 7.0.8.1                              |
| EPICS_MODULES            | Install path for modules relativ to EPICS_TOP           | modules/                             |
| IOC_NAME                 | Name of the IOC                                         | epicsIoc                             |
| IOC_TOP                  | Install path for the IOC relativ to EPICS_TOP           | ioc/                                 |
| EXECUTE_VERSION          | Version of devExecute module                            |                                      |
| IOCSTATS_VERSION         | Version of devIocStats module                           |                                      |
| AUTOSAVE_VERSION         | Version of autosave module                              |                                      |
| DEVGPIO_VERSION          | Version of devGpio module                               |                                      |
| DEVTHMPLEDPULSER_VERSION | Version of devThmp/devLepPulser modules                 |                                      |
| SNMP_VERSION             | Version of devSNMP module                               |                                      |
| WIENER_MIB_VERSION       | Version of Wiener MIB file for SNMP                     | 5704                                 |
| CALC_VERSION             | Version of calc module                                  |                                      |
| ASYN_VERSION             | Version of asyn module as Python tuple                  |                                      |
| DRVASYNI2C_VERSION       | Version of drvAsynI2C module                            |                                      |
| MODBUS_VERSION           | Version of modbus module as Py tuple                    |                                      |
| STREAM_VERSION           | Version of streamDevice module                          |                                      |
| IOCTEMPLATE_VERSION      | Version of our IOC template                             | 1.2.0                                |
| TZDATA                   | Used timezone                                           | Europe/Berlin                        |


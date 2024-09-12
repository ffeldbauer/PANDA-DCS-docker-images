## Load drivers
## Connect to R&S HMP4040 with HO732 via usb-serial interface
drvAsynSerialPortConfigure( "hmp_1", "/dev/ttyHameg", 0, 0, 0 )
asynSetOption( "hmp_1", 0, "baud", "9600" )
asynSetOption( "hmp_1", 0, "bits", "8" )
asynSetOption( "hmp_1", 0, "parity", "none" )
asynSetOption( "hmp_1", 0, "stop", "1" )
asynSetOption( "hmp_1", 0, "clocal", "Y" )
asynSetOption( "hmp_1", 0, "crtscts", "N" )
asynSetOption( "hmp_1", 0, "ixon", "N" )
asynSetOption( "hmp_1", 0, "ixoff", "N" )
asynSetOption( "hmp_1", 0, "ixany", "N" )
## Connect to R&S HMP4040 via ETH
#drvAsynIPPortConfigure( "hmp_1", "192.168.0.5:5025 TCP", 0, 0, 0 )

## Load record instances
dbLoadTemplate ("/config/hameg_demo.sub" )

iocInit()


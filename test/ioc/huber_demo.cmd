## drvAsynIPPortConfigure( portName, hostInfo, priority, noAutoConnect, noProcessEos )
##
## portName        string   The portName that is registered with asynManager
## hostInfo        string   The Internet host name, port number, optional local port number,
##                          and optional IP protocol of the device.
## priority        int      Priority at which the asyn I/O thread will run.
##                          If this is zero or missing, then epicsThreadPriorityMedium is used.
## noAutoConnect   int      Zero or missing indicates that portThread should automatically connect.
##                          Non-zero if explicit connect command must be issued.
## noProcessEos    int      If 0 then asynInterposeEosConfig is called specifying both processEosIn and processEosOut.
drvAsynIPPortConfigure( "huber", "PilotONE-187144:502 TCP", 0, 0, 0 )


## modbusInterposeConfig( portName, linkType, timeoutMsec, writeDelayMsec )
##
## portName        string   Name of the asynIPPort/asynSerialPort previously created.
## linkType        int      Modbus link layer type:, 0 = TCP/IP, 1 = RTU, 2 = ASCII
## timeoutMsec     int      The timeout in milliseconds for write and read operations to the underlying asynOctet driver.
##                          This value is used in place of the timeout parameter specified in EPICS device support.
##                          If zero is specified then a default timeout of 2000 milliseconds is used.
## writeDelayMsec  int      The delay in milliseconds before each write from EPICS to the device.
##                          This is typically only needed for Serial RTU devices.
modbusInterposeConfig( "huber", 0, 300, 0 )


## drvModbusAsynConfigure( portName, tcpPortName, slaveAddress, modbusFunction, modbusStartAddress,
##                         modbusLength, dataType, pollMsec, plcType );
##
## portName             string   Name of the modbus port to be created.
## tcpPortName          string   Name of the asynIPPort/asynSerialPort previously created.
## slaveAddress         int      The address of the Modbus slave.
##                               This must match the configuration of the Modbus slave (PLC) for RTU and ASCII.
##                               For TCP the slave address is used for the "unit identifier", the last field in the MBAP header.
## modbusFunction       int      Modbus function code (1, 2, 3, 4, 5, 6, 15, 16, 123 (for 23 read-only), or 223 (for 23 write-only)).
## modbusStartAddress   int      Start address for the Modbus data segment to be accessed.
##                               For relative addressing this must be in the range 0-65535 decimal, or 0-0177777 octal.
##                               For absolute addressing this must be set to -1.
## modbusLength         int      The length of the Modbus data segment to be accessed.
##                               This is specified in bits for Modbus functions 1, 2, 5 and 15.
##                               It is specified in 16-bit words for Modbus functions 3, 4, 6, 16, or 23.
##                               For absolute addressing this must be set to the size of required by the largest single Modbus operation that may be used.
## modbusDataType       string   This sets the default data type for this port. This is the data type used if the drvUser field of a record is empty, or if it is MODBUS_DATA.
## pollMsec             int      Polling delay time in msec for the polling thread for read functions.
##                               For write functions, a non-zero value means that the Modbus data should, be read once when the port driver is first created.
## plcType              string   Type of PLC (e.g. Koyo, Modicon, etc.). This parameter is currently used to print information in asynReport.
drvModbusAsynConfigure( "huberModbusR", "huber", 0xff, 3, 0, 115, "INT16",  200, "Huber PilotOne" )
drvModbusAsynConfigure( "huberModbusW", "huber", 0xff, 6, 0, 115, "INT16", 2000, "Huber PilotOne" )


## Load record instances
dbLoadRecords( "$(DB_FILE_PATH)/Huber_pilotone_modbus.db", "H=PANDA:LMD, N=COOLING:H1, PORT_R=huberModbusR, PORT_W=huberModbusW" )

iocInit()


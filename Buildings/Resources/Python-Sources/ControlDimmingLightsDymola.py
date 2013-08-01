'''
GeneralCalBayComm.py

Allows user to specify login, pw and command. Then sends signal to CalBay adapter

Created Jul 12, 2013

@author: Peter Grant

'''

import socket # Use the Python socket library to do TCP socket communications.
import time
import struct

CMDSLEEP = 0.10 # time in seconds to wait after sending command to read command.
RECVSIZE = 6553600  # number of bytes to read on recv after command.


class SocketClient(object):
    '''
    SocketClient class provides high-level Ethernet socket communications,
        via a small wrapper around the Python standard socket class.
    
    Can be used as basis for all TCP socket communications
    '''
    def __init__(self):
        '''
        Constructor
        
        @param target: Target IP address or hostname
        @param port: TCP port to use
        '''
        self.sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        #self.open(target, port)
    def open(self, target, port):
        '''
        Open connection to target
        
        @param target: Target IP address or hostname
        @param port: TCP port to use
        '''
        try:
            result = self.sk.connect((target, port))
        except socket.error as X:
            return 'Failure - connection could not be established.\r' + result + X
        else:
            return 'Success'
    def close(self):
        '''
        Clean up references
        '''
        return self.sk.close()
    def cmd(self, command):
        '''
        Send command to target and read response
        
        Assumes that TCP commands sent are echoed back.
        '''
        # use sendall() to block until whole command is sent.
        cmdlen = len(command) 
        self.sk.sendall(command)
        time.sleep(CMDSLEEP)
        r = self.sk.recv(RECVSIZE)
        return r[cmdlen:]
    
class FlexlabExtInterface(SocketClient):    
    '''
    Class to provide interface to Flexlab External TCP Interface.

    @param target: Target IP address or hostname
    @param port: TCP port to use
    @param pwd: (Optional) password for the WiFly device.

    '''

    def open(self, target, port, user = 'user', pwd = 'nopass'):
        # Could have comms problems either when opening port for the first time
        #   due to timeout or unavailable communications.
        try:
            #self.sk.settimeout(4)
            self.sk.settimeout(15)
            self.sk.connect((target, port))
        except socket.timeout:
            # occurs if not on the network and timeout is < 25
            resp = 'Failure - connection could not be established due to timeout.\r'
            resp += 'Please ensure that you can connect to the device.\r'
            return resp
        except socket.error as X:
            # occurs if not on network and timeout >= 25 
            return 'Failure - connection could not be established.\r' + str(X)
        else:
            # Connected; proceeed.
            
            # Always check user auth on open.
            try:
                #self.sk.send(' ' + user + pwd)
                resp = self.cmd('LOGIN:' + user + ':' + pwd)
            except socket.timeout as X:
                # occurs if not on the network and timeout is < 25
                return 'Failure - connection could not be established due to timeout.\r'
            except socket.error as X:
                # occurs if not on network and timeout >= 25 
                resp = 'Failure - connection could not be established.\r' + str(X)
                return resp
            else:
                # wait longer for device to respond.
                #time.sleep(CMDSLEEP * 2.5)  
                #resp = self.sk.recv(RECVSIZE)
                return ('Success:\n' + resp)

    def cmd(self, command):
        '''
        Send command to external interface and read response
        
        @param command: ASCII command to send to the central workstation.
        '''
        packed_len = struct.pack('>L', len(command))
        self.sk.sendall(packed_len + command)
        time.sleep(CMDSLEEP) # slowed this down from .05 in order to clean up errors in stress testing.
        r = self.sk.recv(RECVSIZE)
        # strip off command and \r\n
        #return r[cmdlen+2:]
        return r[4:]


#===============================================================================
# Testing code
#===============================================================================
    

#Login = 'P Grant'
#Password = 'pgrant213'
#Command = 'GetDAQ:WattStopper.HS1--4126F--Light Level-1'
#SendString = ":".join([Command,Login,Password])


#for i in range(0,3):

#SetPoint = 8

#def CalBayComm(Login, Password, Command):
def CalBayComm(SetPoint):

    conn = FlexlabExtInterface()
    print "Opening connection.\n"
    print "Sending command 'LOGIN:Philips 1:Philips 1':\n" + conn.open("128.3.20.130",3500,"P Grant","pgrant213")
    

    CurrentLight = conn.cmd('GetDAQ:WattStopper.HS1--4126F--Light Level-1:P Grant:pgrant213')
#    print "CurrentLight: " + CurrentLight
    CurrentDim = conn.cmd('GetDAQ:WattStopper.HS1--4126F--Dimmer Level-2:P Grant:pgrant213')
#    print "CurrentDim: " + CurrentDim
    NewDim = float(CurrentDim) - 100/1.5 * (1 - float(SetPoint)/float(CurrentLight))
#    print "NewDim: " + str(NewDim)

    conn.cmd('SETDAQ:WattStopper.HS1--4126F--Dimmer Level-2:' + str(NewDim) + ':P Grant:pgrant213') 

    time.sleep(30)

#    print "After 30s delay..."

    NewLight = conn.cmd('GetDAQ:WattStopper.HS1--4126F--Light Level-1:P Grant:pgrant213')
#    print "NewLight: " + NewLight
    NewDim = conn.cmd('GetDAQ:WattStopper.HS1--4126F--Dimmer Level-2:P Grant:pgrant213')
#    print "NewDim: " + NewDim

    #print "Checking light levels in office 4126F"
    #print "Sending command to read WattStopper.HS1--4126F--Light Level-1:\n'GETDAQ:WattStopper.HS1--4126F--Relay-3:P Grant:pgrant213':\n"
    #res = float(conn.cmd(SendString))
#    print "Result: "+str(res)
    conn.close()
    #Output = 
#    results.append(CalBayComm(Login, Password, Command))

    CurrentLightOut = float(CurrentLight)
    NewLightOut = float(NewLight)
    NewDimOut = float(NewDim)

    return (CurrentLightOut, NewLightOut, NewDimOut, SetPoint)

#CalBayComm(SetPoint)

#    print Output
#    print i

#    import time

#    time.sleep(5)

#    time.sleep(25)

#print Output

    #Output = subprocess.check_output([CalBayComm(Login,Password,Command)]) 
    #, "Login", "Password", "Command"])
    #print Output


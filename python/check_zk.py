#!/usr/bin/env python3
''' Checks zookeeper cluster status using four letter words. '''

import socket

HOST = '127.0.0.1'
PORT = 2181

# Zookeeper four letter commands
# https://zookeeper.apache.org/doc/r3.4.8/zookeeperAdmin.html#sc_zkCommands

COMMANDS = [
    'conf',
    'cons',
    'crst',
    'dump',
    'envi',
    'ruok',
    'srst',
    'srvr',
    'stat',
    'wchs',
    'wchc',
    'wchp',
    'mntr'
]

class ZKStatus:
    ''' Manages and monitors Zookeeper cluster. '''

    def __init__(self, zk_host, zk_port):
        ''' ZKStatus init.
        params:
            zk_host - Zookeeper instance host
            zk_port - Zookeeper instance port
        '''
        self.zk_host = zk_host
        self.zk_port = zk_port

    def __connect(self, command):
        ''' Creates connection to a Zookeeper instance,
            and issues a four letter command. Returns the respone as object.
        params:
            command - four letter command a zookeper responds to
        '''
        # Check the commands
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as zk_socket:
                zk_socket.connect((self.zk_host, self.zk_port))
                zk_socket.sendall(command)
                data = zk_socket.recv(1024)
        except ConnectionRefusedError:
            return False
        return data

    def get_mntr(self):
        ''' Gets zookeper status with 'mntr' command.
        '''
        status = {}
        data = self.__connect(b'mntr')
        for line in data.split(b'\n'):
            if line != b'':
                key, value = line.decode("utf-8").split('\t')
                if key in ('zk_version', 'zk_server_state'):
                    status[key] = value
                else:
                    status[key] = int(value)
        return status

    def get_stat(self):
        ''' Gets basic stats with 'stat' command.
        '''
        data = self.__connect(b'stat')
        print(data)

    def get_ruok(self):
        ''' Gets server status with 'ruok' command.
        '''
        data = self.__connect(b'ruok')
        print(data)

if __name__ == '__main__':
    zk_status = ZKStatus(HOST, PORT)
    print(zk_status.get_mntr())
    zk_status.get_stat()

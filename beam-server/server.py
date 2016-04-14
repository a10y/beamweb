import SocketServer
from subprocess import Popen, PIPE
import sys

class BeamRequestHandler(SocketServer.BaseRequestHandler):
    def handle(self):
        self.data = self.request.recv(1024).strip()
        print("recvd {}".format(self.data))
        Popen(["open", self.data]) # open the url

HOST,PORT = "0.0.0.0", int(sys.argv[1])
server = SocketServer.TCPServer((HOST, PORT), BeamRequestHandler)
print("Serving at {}:{}".format(HOST, PORT))
server.serve_forever()


#This Python script is a workaround for Lua's limited abilities in executing system commands on separate threads.

import sys
import os

port = sys.argv[1]
name = sys.argv[2] + "'s game'"

# Spawn the new server
# print("lua netServer.lua " + str(port) + " \"" + str(name) + "\" &")
os.system("lua netServer.lua " + str(port) + " \"" + str(name) + "\" &")

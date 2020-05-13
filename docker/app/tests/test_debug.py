import sys
import pprint

def errx(msg=None):
    print
    print("[ERROR]: %s" % msg)
    exit(1)

def trace(data=None):
    pp = pprint.PrettyPrinter(indent=1)
    pp.pprint(data)

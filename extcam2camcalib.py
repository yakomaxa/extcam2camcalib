def read_cfg(file):
    from pandas import read_csv
    print("Reading cfg")
    cfg=read_csv(file,sep="=",header=None)

    dat=dict()
    dat['x']  =  float(cfg[1][cfg[0]=="x"])
    dat['y']  =  float(cfg[1][cfg[0]=="y"])
    dat['z']  =  float(cfg[1][cfg[0]=="z"])

    dat['rx']  = float(cfg[1][cfg[0]=="rx"])
    dat['ry']  = float(cfg[1][cfg[0]=="ry"])
    dat['rz']  = float(cfg[1][cfg[0]=="rz"])
    dat['fov'] = float(cfg[1][cfg[0]=="fov"])
    #print(dat)
    return(dat)

def fov2cameramatrix(fov, W, H , hetero=False):
    import math
    from math import tan
    print("Setting camera matrix")
    cx = W / 2
    cy = H / 2
    fy = 0.5 * H / tan(math.pi * fov * 0.5 / 180)

    if (hetero):
        fx = 0.5 * W / tan(math.pi * fov * 0.5 / 180)
    else:
        fx = fy

    cameramatrix=[fx,0,cx,0,fy,cy,0,0,1]
    return(cameramatrix)

def eular2quaternion(rx,ry,rz):
    from pyquaternion import Quaternion
    from math import pi
    from math import sin
    from math import cos
    import numpy as np
    print("Setting rotation")
    theta_x = 360 - rx
    theta_y = 360 - ry
    theta_z = 360 - rz

    sint = sin(pi * theta_x / 180)
    cost = cos(pi * theta_x / 180)
    Rx = np.array([ [1, 0, 0], [0, cost, -sint], [0, sint, cost] ])

    sint = sin(pi * theta_y / 180)
    cost = cos(pi * theta_y / 180)
    Ry = np.array([ [cost,0,sint],[0,1,0],[-sint,0, cost] ])

    sint = sin(pi * theta_z / 180)
    cost = cos(pi * theta_z / 180)
    Rz = np.array([ [cost,-sint,0],[sint,cost,0], [0,0,1] ])

    rotmat=np.dot(np.dot(Ry,Rx),Rz)
    q = Quaternion(matrix=rotmat)
    qcoefs=[q.vector[0],q.vector[1],q.vector[2],q.scalar]
    #print(qcoefs)
    return(qcoefs)


def write_oculusxml(template_xml, indata, out_xml):
    import xml.etree.ElementTree as et
    print("Writing xml")
    xml = et.parse(template_xml)
    root = xml.getroot()
    for elem in root:
        if (elem.tag == "image_width"):
            #print(elem.tag)
            elem.text = str(indata["dw"])

        if (elem.tag == "image_height"):
            #print(elem.tag)
            elem.text = str(indata["dh"])

        if (elem.tag == "camera_matrix"):
            for elem2 in elem:
                if (elem2.tag == "data"):
                    #print(elem2.tag)
                    s = ""
                    for si in range(0, 9):
                        s = s + str(indata["cameramatrix"][si]) + " "

                    elem2.text = s

        if (elem.tag == "translation"):
            for elem2 in elem:
                if (elem2.tag == "data"):
                    #print(elem2.tag)
                    s = str(indata["x"]) + " " + str(indata["y"]) + " " + str(indata["z"])
                    elem2.text = s

                    #elem2.text = indata["translation"]

        if (elem.tag == "rotation"):
            for  elem2 in elem:
                if (elem2.tag == "data"):
                    #print(elem2.tag)
                    s = ""
                    for si in range(0, 4):
                        s = s + str(indata["rotation"][si]) + " "

                    elem2.text = s

    xml.write(out_xml)

def main(infile, outfile,
         displaywidth=1280, displayheight=960, intercept=1.65):
    #displaywidth = 1280
    #displayheight = 960
    #slice = 1.65
    cfg=read_cfg(infile)
    outdata = dict()
    outdata["x"] = cfg["x"]
    outdata["y"] = cfg["y"] + intercept
    outdata["z"] = -cfg["z"]
    outdata["cameramatrix"] = fov2cameramatrix(fov=cfg["fov"], W=displaywidth, H=displayheight)
    outdata["rotation"] = eular2quaternion(cfg["rx"], cfg["ry"], cfg["rz"])
    outdata["dw"] = displaywidth
    outdata["dh"] = displayheight
    write_oculusxml(template_xml="./template.xml",indata=outdata,out_xml=outfile)

import sys
args=sys.argv
print(args[1], "->",args[2])
main(infile=args[1],outfile=args[2])

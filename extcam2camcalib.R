#!/bin/Rscript
# a script to covert externalcamera.cfg to cameracalibration.xml
# Define functions
## main()
## fov2cameramatrix()

main <- function(infile,
                 outfile,
                 template="template.xml",
                 slice=1.65,
                 displaywidth=1920,
                 displayheight=1080){
  
  # read externalcamera.cfg. x, y, z, rx, ry, rz, and fov are extracted. 
  # Other variables are ignored 
  cfg=read_cfg(file=infile)
  
  # define list
  outdata = list()
  # store quaternion for rotation
  # (rx, ry, rz) -> (i,j,k,real)
  outdata$rotation = euler2quaternion(rx = cfg$rx,
                                      ry = cfg$ry,
                                      rz = cfg$rz)
  # store camera matrix
  # (fov, displaywidth, displayheight) -> (fx,0,cx,0,fy,cy,0,0,1)
  outdata$cameramatrix = fov2cameramatrix(cfg$fov,
                                          W=displaywidth,
                                          H=displayheight)
  # coordinate transformation
  # correspondence was empirically found
  # (x,y,z) -> (X,Y,Zs)
  fov=cfg$fov
  coef=tan(pi*0.5*fov/180)
  # X = x 
  outdata$x = cfg$x
  # Y = y + silce 
  # I found slice = 1.65 is good, but what is this ???
  outdata$y = (cfg$y + slice)
  # Z = -z 
  outdata$z = -cfg$z  
  # display width and height 
  outdata$width = displaywidth
  outdata$height = displayheight
  
  # write it down
  write_oculusxml(template_xml = template, 
                  out_xml = outfile,
                  indata = outdata)
}

read_cfg <- function(file){
  # just read and extract x y z rx ry rz and fov
  tmp=read.table(file,sep="=",stringsAsFactors = F)
  extcam=tmp$V2
  names(extcam)=tmp$V1
  extcam_numeric=list()
  for (key in c("x","y","z","rx","ry","rz","fov")){
    extcam_numeric[[key]]=as.numeric(extcam[key])
  }
  return(extcam_numeric)
}
  
fov2cameramatrix <- function(fov,W,H,hetero=F){
  # compose camera matrix from fov and display height.
  # 0.5*H/f = tan(pi*fov*0.5/180)
  cx=W/2
  cy=H/2
  # calc vertial focus length
  fy = 0.5*H/tan(pi*fov*0.5/180)
  #         /|
  #       /  |
  #     /    |
  #   /      |  H/2  
  # / fov/2  |
  # ---------|
  #    fy
  #

    
  if (hetero){
     # calc vertial focus length if hetero = True
   fx = 0.5*W/tan(pi*fov*0.5/180)     
   }else{
     # set horizontal same as vertical if hetero = False
     fx=fy  
   }
 # 3 x 3 camera_matrix, though it's vector here...
  camera_matrix=c(fx,0,cx,
                  0, fy, cy,
                  0, 0, 1)
   return(camera_matrix)
 }

euler2quaternion <- function(rx, ry , rz){
  require(rotations) # need this to get quaternion
  
  # Calculate X, Y, Z rotation matrixes and synthesize them.
  # Then convert it to quaternion (i,j,k,real)
  theta_x = 360 - rx
  theta_y = 360 - ry
  theta_z = 360 - rz
  
  sint=sin(pi*theta_x/180)
  cost=cos(pi*theta_x/180)
  # compose Rotation matrix around x-axis
  Rx = t(matrix(c(1,0,0,0,cost,-sint,0,sint,cost),ncol=3,nrow=3))
  
  sint=sin(pi*theta_y/180)
  cost=cos(pi*theta_y/180)
  # compose Rotation matrix around y-axis
  Ry = t(matrix(c(cost,0,sint,0,1,0,-sint,0,cost),ncol=3,nrow=3))
  
  sint=sin(pi*theta_z/180)
  cost=cos(pi*theta_z/180)
  # compose Rotation matrix around z-axis
  Rz = t(matrix(c(cost,-sint,0,sint,cost,0,0,0,1),ncol=3,nrow=3))
  
  # In Unity, the order of rotaion is z -> x -> y
  rotmat=Ry%*%Rx%*%Rz
  #rotmat=Rz%*%Rx%*%Ry
  # make it as SO3 object, and then make it quaternion
  q=as.Q4(as.SO3(rotmat))
  # as vector 
  q.coef=as.vector(q)
  # in outfile, we need elements are ordered as i*sin j*sin k*sin cos
  q.coef=c(q.coef[2:4],q.coef[1])
  names(q.coef) = c("i","j","k","real")
  return(q.coef)
}


write_oculusxml=function(template_xml,
                         indata,
                         out_xml){
  require(xml2)
  # write data into xml
  # This currently requires template xml
  # image width, height, rotation, translation,and camera_matrix are modified.
 
  xml = read_xml(template_xml)
  
  # It's not beautiful, but I need 'tmp' to use xml_text()
  tmp=xml %>% xml_find_all("//opencv_storage/image_width")
  xml_text(tmp)=paste(indata$width) 
  # inserts need to be character, so paste() is here.
  
  tmp=xml %>% xml_find_all("//opencv_storage/image_height")
  xml_text(tmp)= paste(indata$height)
  
  tmp=xml %>% xml_find_all("//opencv_storage/camera_matrix//data")
  xml_text(tmp) = paste(indata$cameramatrix,collapse = " ") 
  # turn the vector into a space-separated string.
  
  tmp=xml %>% xml_find_all("//opencv_storage/rotation//data")
  xml_text(tmp) = paste(indata$rotation,collapse = " ")
  
  tmp=xml %>% xml_find_all("//opencv_storage/translation//data")
  xml_text(tmp)  = paste(indata$x,
                         indata$y,
                         indata$z)
  # just write a modified xml 
  write_xml(xml,file=out_xml)
}


args=commandArgs(TRUE)

main(infile = args[1],
     outfile = args[2],displaywidth = as.numeric(args[3]),displayheight = as.numeric(args[4]),slice=as.numeric(args[5]))

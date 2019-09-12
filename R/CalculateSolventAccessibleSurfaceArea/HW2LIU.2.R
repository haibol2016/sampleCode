##########################################################################
#
# Calculate solvent accessible surface area of each atoms in a protein based
# on the 3-D crystal structure information in PDB
#
##########################################################################


###########################################################################
# the Van der Vaals radii of C, H, O, N,S are got from (Bodi,1964)        #
# http://physlab.lums.edu.pk/images/f/f6/Franck_ref2.pdf                  #
#                                                                         #
###########################################################################
setwd("C:\\Users\\Haibo\\Desktop\\BCB569")

options(digits=10)
vdw.radii <- c(1.2, 1.7, 1.52, 1.55, 1.8)
names(vdw.radii) <- c("H", "C", "O", "N", "S")

probe.radius <- 1.4

outter.radii <- vdw.radii + probe.radius
outter.radii.squared <- outter.radii^2

numUnifPoints <- 500

#########################################################################
#                                                                       #
# input: a PDB txt file                                                 #
# output: all the lines atoms coordinates                               #
#                                                                       #
#########################################################################
readPDB <- function(file=NULL)
{
    pdb <- scan(file, character(0), sep = "\n", quote=NULL) # separate each line
    
    coord.lines <- grep("^ATOM",pdb, perl=T, value=T )
    
    # convert text to a data frame
    all.coords <- read.table(textConnection(coord.lines), header=F, stringsAsFactors=F)
    colnames(all.coords)<- c("Atom", "AtomNumber", "AtomName","Residue", "Chain", 
                             "ResidueNumber", "X", "Y","Z","Occupancy","TempFactor","Symbol")
    all.coords
}

##################################################################################################
#                                                                                                #
# Generation of N uniformly distributed points on the outter surface of a sphere with radius,r.  # 
# let Ra = atomRadius, Rp = probeRadius, then                                                    #
# the outter radius =  Ra + Rp, which is the second argument in the getUnifPointCoords()         #
# function. I implement 2 methods to generating uniform distributed 500 points on the sphere     # 
# surface.                                                                                       #
#                                                                                                #
##################################################################################################

# Method 1: using Golden Section spiral distribution

getUniformPointsCoords <- function(num=500, radius = 1, atomCenter= c(x0, y0, z0))
{
    
    points <- matrix(0, nrow=3, ncol=500)
    increase  <- pi*(3-sqrt(5))
    off <- 2/num
    
    for (i in 0:(num-1))
    {
        y <- i*off -1 + off/2
        r  <- sqrt(1-y^2)
        phi <- i*increase
        points[,i+1] <- radius*c(cos(phi)*r, y, sin(phi)*r)+atomCenter 
    }
    
    points
}




# Method 2: sampling from uniform distribution on spehere surface

getUnifPointCoords <-  function(num=500, radius=1, atomCenter=c(x0, y0,z0))
{
    theta <- 0
    phi <- 0
    set.seed(100000000) # set a seed for the random number generator
    x <- vector("numeric",num)
    y <- vector("numeric",num)
    z <- vector("numeric",num)
    for(i in 1:num)
    {    
        theta = 2*pi*runif(1,min =0, max=1)
        
        phi = acos(2*runif(1,min=0,max=1)-1.0)
        
        x[i] = radius*cos(theta)*sin(phi);
        y[i] = radius*sin(theta)*sin(phi);
        z[i] = radius*cos(phi);
    }
    
    points.mat <- rbind(x,y,z)
    coordinates <-points.mat+atomCenter
    coordinates
}

######################################################################################################                                                                                                   #
# calculate the averaged area represented by each point on the outter surface                       #
#####################################################################################################

getAvgPointArea <- function (num = 1, atomRadius= 1.55)
{
    avgArea <- 4*pi*(atomRadius + probe.radius)^2/num
    avgArea
}

#####################################################################################################
#                                                                                                   #
# Check if the points on the surface of a sphere is buried by other neighbouring atoms:             #
# if the distance between the point and the center of the sphere is less than the sum of            #
# the radius of the probing sphere and that pf the correspoding neighbouring atom, then             #
# this point is buried by the neighboring atom. Thus this point should not be counted for the SASA. #
# Vectorization of this step speed up a lot!!!!!!!                                                  #
#####################################################################################################
isBuried <- function(probeCenter=c(x1,y1,z1), neighborAtomCenter = t(all.coords), neighorAtom = atomNames)
{   

    mat <- matrix(probeCenter,nrow=3,ncol= total.atoms-1)-neighborAtomCenter
    dist.squared <- colSums(mat^2)
    any(dist.squared < outter.radii.squared[neighorAtom])
    
}

###############################################################################################
#                                                                                             #
#  calculate the atomwise SASA                                                                #
#                                                                                             #
###############################################################################################

getAtomSASA <- function(atomNum = 1,all.coords = all.coords, atomNames=atomNames, 
                        total.atoms=total.atoms, avgPointArea=avgPointArea)
{
    atomSymbol <- atomNames[atomNum]
    
    ##########################################################
    # Using method 2 to get uniformly distributed 500 points
    
    unifPoints <- getUnifPointCoords(num=500, radius=outter.radii[atomSymbol], atomCenter = all.coords[atomNum, 1:3])
    
    ##########################################################
    # using Golden Section Spiral distribution to get 500 points
    
    #unifPoints <- getUniformPointsCoords(num=500, radius = outter.radii[atomSymbol], atomCenter = all.coords[atomNum, 1:3])
    
    numAccessiblePoints <- numUnifPoints
    
    # transpose the coordinates matrix and remove the current atom's coordinates
    transposed.all.coords <- t(all.coords[-atomNum,])
    
   for ( i in 1:numUnifPoints)
    {   
       
       if(isBuried(probeCenter=unifPoints[,i], neighborAtomCenter = transposed.all.coords, neighorAtom = atomNames[-atomNum]))
       {
           numAccessiblePoints <- numAccessiblePoints-1
       }
    }
    atomSASA <- numAccessiblePoints*avgPointArea[atomSymbol]
    atomSASA
}


##################################################################################################
#                                                                                                #
# calculate solvent accessible surface area for each atom, then for each residue, and the total  #
# surface areas of the protein                                                                   #
##################################################################################################


pdb <- readPDB(file="2GB1.pdb")
all.coords <- as.matrix(pdb[,7:9])  
atomNames <- rownames(all.coords) <- pdb[,12]
total.atoms <- nrow(pdb)
avgPointArea <- getAvgPointArea(num=numUnifPoints, atomRadius=vdw.radii)

atomSASA <-vector("numeric", nrow(all.coords)) 
system.time (for ( i in 1: total.atoms)
{
    atomSASA[i] <- getAtomSASA(atomNum = i, all.coords = all.coords, 
                               atomNames=atomNames, total.atoms=total.atoms, avgPointArea=avgPointArea)
    print(i)
})

atomWiseSASA <- cbind(pdb, atomSASA)
write.table(atomWiseSASA, "atomwise.SASA.txt", sep ="\t", quote=F,row.names=F)

#######################################################################################
# Run the method 2 to generate 500 uniformly distributed points for 15 times to get the 
# average to minimize the variability due to random variation from runif() Total.SASA=3.999.76
#######################################################################################
areaOfAtom <- vector("numeric", nrow(all.coords)) 
for (trial in 1:15)
{
    atomSASA <-vector("numeric", nrow(all.coords))
    for ( i in 1: total.atoms)
    {
        atomSASA[i] <- getAtomSASA(atomNum = i, all.coords = all.coords, 
                                   atomNames=atomNames, total.atoms=total.atoms, avgPointArea=avgPointArea)
        print(i)
    } 
    areaOfAtom <- areaOfAtom +atomSASA
    print(trial)
}

atomWiseSASA <- areaOfAtom/15
write.table(atomWiseSASA, "atomwise.SASA.txt", sep ="\t", quote=F,row.names=F)

#################################################################################################
#                                                                                               #
#                             get SASA of each residue                                          #
#                                                                                               #
#################################################################################################

residuePos <- unique(pdb[,6])

residueSASA <- vector("numeric", length(residuePos))

for ( i in residuePos)
{
    residueSASA[i] <- sum(atomWiseSASA[pdb[,6]==i])
}

residueSASA <- cbind(unique(pdb[,c(4,6)]),residueSASA)

write.table(residueSASA, " residuewise.SASA.txt",sep ="\t", quote=F,row.names=F)

##########################################
#                                        #
#          get the total SASA            #
##########################################

proteinSASA <- sum(residueSASA[,3])

write.table(proteinSASA, " protein.SASA.txt",sep ="\t", quote=F,row.names=F)


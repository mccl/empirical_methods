# code for SMT WOrkshop on empirical musicology

#  LOAD DATA
dataPath="~/Dropbox/Statz/R/Data/smt2015/"  # set this to wherever the data are stored

# essens 
essensDb=read.table(paste(dataPath,"essens-downbeats.txt",sep=""), quote="\"")
essensLt=read.table(paste(dataPath,"essens-leading_tones.txt",sep=""), quote="\"")

# Frontiers piano data
pianoData=read.delim(paste(dataPath,"frontiersData.txt",sep=""))
pianoData$pitchHeight=pianoData$pitchHeight-(12*3+4)  # we coded lowest piano note a 1, so subtract 3 octaves plus a M3 to put middle C at 0

# load usefulRoutines.r
source(paste(dataPath,"usefulRoutines (for SMT).r",sep=""))
library(plyr)  # for doing counts of chi-square stuff

       # pitch info
majorAll=subset(pianoData, mode=="Major")$pitchHeight
minorAll=subset(pianoData, mode=="minor")$pitchHeight

    # timing info
majorT=subset(pianoData, mode=="Major")$articRate
minorT=subset(pianoData, mode=="minor")$articRate

#  string quartets
b1=read.table(paste(dataPath,"beetv1",sep=""), quote="\"")$V1
b2=read.table(paste(dataPath,"beetv2",sep=""), quote="\"")$V1

h1=read.table(paste(dataPath,"haydnv1",sep=""), quote="\"")$V1
h2=read.table(paste(dataPath,"haydnv2",sep=""), quote="\"")$V1

m1=read.table(paste(dataPath,"mozartv1", sep=""),quote="\"")$V1
m2=read.table(paste(dataPath,"mozartv2",sep=""), quote="\"")$V1

# Chopin Preludes 
majorC=subset(pianoData,composer=="chopin" & mode=="Major")$pitchHeight
minorC=subset(pianoData,composer=="chopin" & mode=="minor")$pitchHeight

# Bach Preludes and Fugues
majorB=subset(pianoData,composer=="bach" & mode=="Major")$pitchHeight
minorB=subset(pianoData,composer=="bach" & mode=="minor")$pitchHeight

# SETTING UP GLOBAL VALUES
# colors
majCol=rgb(1,0,0,.5)
minCol=rgb(0,0,1,.5)

v1Col=rgb(1,.5,.1,.5)
v2Col=rgb(0,0,0,.5)

# plotting values
globalMin=min(h1,h2,b1,b2,m1,m2,majorAll,minorAll)
globalMax=max(h1,h2,b1,b2,m1,m2,majorAll,minorAll)
globalRange=c(globalMin,globalMax)

# set max values for histograms here for convenience
bMax=6600  
mMax=6600
hMax=14000

aMax=25000
xrange=c(-12,42)
bgRange=c(150,200)
bgMax=13


# ----- FUNCTIONS

getNote=function(group,numNotes=1)
{
  sample(group,numNotes)
}

# plots a histogram of a sample, using a default x range that works for the string quartet and piano data
# useful in demonstrating how repeated sampling "grows" a population
# population: The population to sample from (originally for string quartets/piano data)
# popSample: include the result of the last function to "grow" a population
# getObs: number of observations to add to the sample (or start with)
# yMax: the max y value - auto updated for samples with individual counts exceeding this value
growSample=function(population,popSample=NULL,getObs=1,yMax=10)
{
  #sample=NULL  # start out empty
  
  for (index in 1:getObs)    # add in as many observations as is desired
  {
    nextNote=getNote(population)
    if (is.null(popSample))
      popSample=nextNote
    else popSample=c(popSample,nextNote)
  }
  
  binValues=min(population):max(population) # establish bins for each note in the required range
  # figure out the greatest number of counts that will be plotted
  maxSize=max(hist(popSample,xlim=range(population),breaks=binValues)$counts)  
  if (yMax<maxSize)  # and if assiged value max is less than what is needed
    yMax=maxSize     # adjust to actual needs
  
  
  # now make the histogram
  hist(popSample,xlim=globalRange,breaks=binValues,ylim=c(0,yMax),
       ylab="Number of occurances",xlab="Pitch (in semi-tones from middle C)")
  popSample  # and return the population plotted (useful needed for next call if "growing")
}

# pull "num" notes from each part and compare the average difference
compareN=function(v1,v2,numNotes=1,verbose=F,groups="violin")
{
  v1Dat=sample(v1,numNotes)  # get mean of N note for first violin
  v2Dat=sample(v2,numNotes)  # get mean of N note for second violin
  dif=mean(v1Dat)-mean(v2Dat)
  if (groups=="violin")
  {
    groupA="Violin 1"
    groupB="Violin 2"
  }
  else
  {
    groupA="Boys "
    groupB="Girls"      
  }
  
  if (verbose)
  {
    cat (groupA,":",v1Dat, paste(" (",mean(v1Dat),")\n",sep=""))
    cat (groupB,":",v2Dat,paste(" (",mean(v2Dat),")\n",sep="")) 
  }
  dif
}

# pull "num" notes from each part and compare the average difference
plotComparisons=function(v1,v2,num)
{
  v1Dat=sample(v1,num)  # get N notes for first violin
  v2Dat=sample(v2,num)  # get Ns note for second violin
  bothDat=cbind (v1Dat,v2Dat)
  names=c("V 1","V 2")
  basicPlot(bothDat,col=c("blue","red"),labels=names)
}


# convenience function to run a given number of simulations comparing average pitch difference
# v1,v2: violin parts 1 and 2 
# numNotes: The number of pitches from each part to compare
# numComparisons: number of times to compare pitch heights

sampleDifferences=function(v1,v2,numComparisons=100,numNotes=10,showPlot=T,minRange=NULL)
{
  results=NULL
  for (index in 1:numComparisons)
  {
    dif=(compareN (v1,v2,numNotes))
    #cat ("Pulling ",numNotes, " notes and found difference of ",dif,"\n")
    results=c(results,dif)
  }
  
  if (showPlot)
  {
    xMin=min(results)-1  # ensure range is just beyond what is encountered
    xMax=max(results)+1
    if (!(is.null(minRange)))
    {
      #cat ("checking range, starting with ",xMin,xMax)
      xMin=min(xMin,minRange[1])  # if min range low value is smaller, go with that
      xMax=max(xMax,minRange[2])  # if min range max value is higher, go with that
      #cat ("after check ",xMin,xMax)
    }
    binValues=xMin:xMax
    binCols=rep("white",length(binValues))
    binCols[binValues<0]="slategray4"
    hist(results,main=paste("Sampling",numNotes,"note(s)",numComparisons,"times"),xlim=c(xMin,xMax),
         xlab="Pitch height difference (semi-tones)",ylab="Number of occurances",breaks=binValues,col=binCols)
    abline(v=0,lty=2,col="red")
  }
  results
}

compareOutcomes=function(dat)
{
  v1Lower=length(dat[dat<0])
  v1Higher=length(dat[dat>0])
  v1Same=length(dat[dat==0])
  cat ("violin 1 Higher:",v1Higher/length(dat),"")
  cat ("Lower:",v1Lower/length(dat),", ")
  cat ("Equal:",v1Same/length(dat))
  cat ("---Avg difference:",mean(dat)," semi-tones\n")
}


# plot distribution of violin parts, sampling numNotes and running the sample for numComparisons
# xlim: auto scales x axis to range of distribution by default, or takes assigned value
visualizeVoices=function(v1,v2,numComparisons=100,numNotes=10,title="Violin pitch height",xlim="auto",verbose=F)
{
  #par(mfrow=c(1,1))
  #sampleDifferences(v1,v2,numComparisons,numNotes,showPlot=F)
  #sampleSize=1000
  
  results1=NULL
  results2=NULL
  for (index in 1:numComparisons)
  {
    sample1=sample(v1,numNotes)
    sample2=sample(v2,numNotes)
    results1=c(results1,mean(sample1))
    results2=c(results2,mean(sample2))
    if (verbose)
      cat ("Run ",index, ", sample1:",mean(sample1),", sample 2:",mean(sample2),"\n")
  }
  
  sample1Max=max(hist(results1,plot=F)$counts)
  sample2Max=max(hist(results1,plot=F)$counts)
  yMax=max(sample1Max,sample2Max)
  if (xlim[1]=="auto")  # check on definition of x lims
  {
    xmin=min(results1,results2)  # if "auto" then use
    xmax=max(results1,results2)  # dynamically calculated values
  }
  else
  {
    xmin=min(xlim)    # otherwise use specified values 
    xmax=max(xlim)    # (even if they are bad for this plot
  }
  if (verbose)
  {
    cat ("sample1Max is",sample1Max,"sample2Max is",sample2Max,"yMax is",yMax,"\n")
    cat ("xmin=",xmin,"xmax=",xmax,"\n")
  }
  
  hist1=hist(results1,xlim=c(xmin*.8,xmax*1.2),ylim=c(0,yMax*1.3),col=rgb(0,0,1,.5),main=title,xlab="Pitch Height (semi-tones from middle C)",ylab="Number of observations")
  par(new=T)
  hist2=hist(results2,xlim=c(xmin*.8,xmax*1.2),ylim=c(0,yMax*1.3),col=rgb(1,0,0,.5),main="",xlab="",ylab="",axes=F)
  legend(xmin*.8,yMax*1.2,legend=c("minor","Major"),fill=c(minCol,majCol),bty="n",horiz=T)
  cat ("breaks 1=",hist1$breaks ,"\n")
  cat ("breaks 2=",hist2$breaks ,"\n")
  
  #legend(-20,bMax,legend=c("Violin 1","Violin 2"),fill=c("blue","red"),bty="n")
  #par(new=T)
  #hist(sample(v2,sampleSize),xlim=c(-8,40),ylim=c(0,yMax),col="red",main="",xlab="Pitch Height (semi-tones from middle C)",ylab="Number of notes")
}

# runs simple t test on a sample of sampleSize from groups 1 and 2
testGroups=function(group1,group2,sampleSize=100,type="Violin")
{
  vSample1=sample(group1,sampleSize)
  vSample2=sample(group2,sampleSize)
  result=t.test(vSample1,vSample2)
  cat ("Mean of", sampleSize, "notes from",type,"1:",mean (vSample1),"\n")
  cat ("Mean of", sampleSize, "notes from",type,"2:",mean (vSample2),"\n")
  cat ("t =",result$statistic,", df =",result$parameter,",  p value =",result$p.value)
  #result
}


viewSummary=function(g1,g2,colScheme="violin",datType="pitch")
{
  if (colScheme=="violin")
  {
    col1=v1Col
    col2=v2Col
    label1="Violin 1"
    label2="Violin 2"
    title="Violin voices"
  }
  else
  {
    col2=majCol
    col1=minCol
    
    label2="Major"
    label1="minor"
    title="Bach WTC and Chopin Preludes"
  }
  yLabel="Average pitch height\n(distance from middle C)"
  
  title="Average pitch height"
  if (datType!="pitch")
  {
    yLabel="Average attack rate\n(i.e. note attacks per-second)"
    title="Average attack rate"
  } 
  ret=basicPlot(cbind(g1,g2),ylab=yLabel,labels=c(label1,label2),col=c(col1,col2),main=title)
}

viewDistributions=function(g1,g2,overlayed=T,colScheme="violin",type="pitch")
{
  lowestBin=min(floor(c(g1,g2)))-1
  highestBin=max(floor(c(g1,g2)))+1
  binValues=lowestBin:highestBin
  
  hist1=hist(g1,breaks=binValues,plot=F)
  hist2=hist(g2,breaks=binValues,plot=F)
  yMax=max(hist1$counts,hist2$counts)*1.2
  #cat("yMax is",yMax,", and range is",lowestBin,highestBin,", binValues=",binValues)
  if (colScheme=="violin")
  {
    col1=v1Col
    col2=v2Col
    label1="Violin 1"
    label2="Violin 2"
    title="Violin voices"
  }
  else
  {
    col1=majCol
    col2=minCol
    label1="Major"
    label2="minor"
    title="Bach WTC and Chopin Preludes"
  }
  
  if (type=="pitch")
    xlabel="Pitch height (semi-tones from middle C)"
    else xlabel=type
  
  if (overlayed)
  {
    par(mfrow=c(1,1),par(las=1))
    hist(g1,xlim=c(lowestBin,highestBin),ylim=c(0,yMax),col=col1,main=title,xlab=xlabel,ylab="Total number of measures",breaks=binValues)
    par(new=T)
    hist(g2,xlim=c(lowestBin,highestBin),ylim=c(0,yMax),col=col2,main="",xlab=" ",ylab=" ",axes=F,breaks=binValues)
    legend(lowestBin,yMax,legend=c(label2,label1),fill=c(col2,col1),bty="n",horiz=T)
  }
    else
    {
      par(mfrow=c(1,2),par(las=1))
      par(mar=c(5.1,4.1,4,0))  # trim margins on the right
      hist(g2,xlim=c(lowestBin,highestBin),ylim=c(0,yMax),col=col2,main="",xlab="",ylab="Total number of measures",breaks=binValues)
      legend(lowestBin,yMax,legend=c(label2),fill=c(col2),bty="n")
      par(xpd=NA)
      text (highestBin,yMax*1.1,title,cex=1.5,pos=3)
      par(xpd=F)  # but turn this back off
      hist(g1,xlim=c(lowestBin,highestBin),ylim=c(0,yMax),col=col1,main="",xlab="",ylab=" ",breaks=binValues,yaxt="n")
      par(mar=c(5.1,0,4,2.1))  # trim margins on the left
      legend(lowestBin,yMax,legend=c(label1),fill=c(col1),bty="n")
      par(mar=(c(5,4,4,2)+.1))  # reset to "default" value
      par(xpd=NA)
      text (mean(lowestBin,highestBin),-yMax/3.5,xlabel)
      par(xpd=F)  # but turn this back off
    }
  #hist1
}
# --- PLOTTING


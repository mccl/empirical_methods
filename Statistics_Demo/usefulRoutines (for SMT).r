# prior to first use, get the following package
# car gplots gdata gmodels gtools
# install.packages(c("gdata", "gplots", "gmodels", "gtools", "car"))

# summarizes a list of N vectors in a format suitable for basicPlot (when autoCalculate=F)
# returns a data frame with N rows and 3 columns.  Each row contains the mean, ciBelow, and ciAbove for each vector in datList
# datList: a list of n vectors representing groups  to be summarized
# confInt: the confidence interval to be used for calculating error bars
# rowNames="": if defined, these names are used for the row names of the data frame returned
summarizeVecs=function(datList,confInt,rowNames="")
{
  retVec=NULL
  for (index in 1:length(datList))
  {
    dat=datList[index][[1]]   # get a vector
    vecMean=mean(dat)
    ciBelow=ci(dat,confInt)[2]
    ciAbove=ci(dat,confInt)[3]
    aRow=cbind(vecMean,ciBelow,ciAbove)
    retVec=rbind(retVec,aRow)
  }
  if (rowNames[1]!="")                     # if rowNames defined
      rownames(retVec)=rowNames         # then use them
      else rownames(retVec)=paste("row",1:length(datList),sep="")
  retVec
}
#test95=summarizeVectors(a,.95,rowNames=c("lessonsN","lessonsY"))
#test68=summarizeVectors(a,.68,rowNames=c("lessonsN","lessonsY"))


#load the required packages.  Perhaps not all of these are needed - try to reduce dependency on this as much as possible
library(gdata)
library(gplots)
library(gmodels)
library(gtools)


# handy function to explore correlations between two variables in a data set
# dat: the data set
# xVar: the variable within dat to plot on the x axis
# yVar: the variable within dat to plot on the y axis
# corp: optional parameter to restrict to a particular corpus
# pitchChroma: optional parameter to restrict to a particular chroma
# fitLowess: Use a lowess fit instead of linear? (defaults to linear)
# autoScale=F: sets graph limits prior to extracting the corpus of interest (to enforce uniform scales regardless of subset)
# jitterX=0: used to manually add jitter to x values.  Specified value sets degree of jitter (.2 seems to work well).  Note: non-jittered values are used for regression/correlation values
# jitterY=0: same as jitterX.
genCorPlot=function(dat,xVar,yVar,corp="all",pitchChroma="all",fitLowess=F,autoScale=F,jitterX=0,jitterY=0)
{
  # first establish x and y ranges based on the ENTIRE data set
  yMax=max(dat[[yVar]])       # peg axes to max/min of global
  yMin=min(dat[[yVar]])       # values, in order to make 
  xMax=max(dat[[xVar]])       # graphs on same scale regardless
  xMin=min(dat[[xVar]])       # of selected corpora
  
  # check on restrictions to data set limiting to particular corpus/chroma
  if (corp!="all")           
    dat=subset(dat,corpus==corp)
  if (pitchChroma!="all")    
    dat=subset(dat,chroma==pitchChroma)
  
  if (!autoScale)               # if autoscale disabled, then instead
  {
    yMax=max(dat[[yVar]])       # peg axes to max/min of used 
    yMin=min(dat[[yVar]])       # values 
    xMax=max(dat[[xVar]])       # Note: graphs will then not necessarily be on the same scale
    xMin=min(dat[[xVar]])       
  }
  # Extract actual x and y values from DESIRED RANGE of data set
  xValues=dat[[xVar]]
  yValues=dat[[yVar]]
  
  # extract the r value and p value from the cor.test method
  corTest=cor.test(xValues, yValues)
 	pVal=round(as.numeric(as.character(corTest[3])),4)
 	corVal=round(as.numeric(as.character(corTest[4])),4)
 	
  # create a string with this info to use as the graph "title"   
  txt=paste("Corpus: ",corp, "\n", "Correlation: ",corVal," (p=", pVal,")",sep="")
  
  xLabel=translateVariable(xVar)    # get pretty label for x axis based on variable name
  yLabel=translateVariable (yVar)     # get pretty label for y axis based on variable name
  
  xJitter=runif(length(xValues),(-1*jitterX), (jitterX) )  # manually add a jitter amount (within the range of +/- jitterX)
  yJitter=runif(length(yValues),(-1*jitterY), (jitterY) )  # manually add a jitter amount (within the range of +/- jitterY)
  yMin=yMin-min(jitterY)   # adjust jitter amounts plot to make sure points aren't "lost"
  yMax=yMax+max(jitterY)   #
  xMin=xMin-min(jitterX)   #
  xMax=xMax+max(jitterX)   # for both axes . . 
  
  plot((xValues+xJitter),(yValues+yJitter), xlab=xLabel,ylab=yLabel,main=txt,bty="l",ylim=c(yMin,yMax), xlim=c(xMin,xMax))  # make the plot

  # add in desired regression line (note - this is not affected by jittering)
  if (fitLowess)
    lines(lowess(xValues,yValues))    # either Lowess
    else abline(lm(yValues~xValues))  # or linear
}


# translates variable to a descriptive string (for labeling axes)
# if variable name is not found, it returns the variable name
translateVariable=function(varName)
{
  switch (varName, 
          "articRate"="Articulation Rate (notes-per-second)",
          "pitchHeight"="Pitch Height",
          "adjTempo"="Tempo (adjusted)",
          "chroma"="Pitch Chroma",
          "mm"="Measure number",
          "trainingBlocks"="Number of Training Blocks",
          "lessonsYrs"="Years of musical lessons",
          "blockScore"="Score on Final Evaluation",
          "tapEffect"="Effect of Tapping",
          "beatStdv23"="Standard deviation of beat size in mm 2 and 3",
          "beatStdv234"="Standard deviation of beat size in mm 2-4",
          "m234"="Standard deviation of beat size in mm 2, 3, and 4",
          "m23"="Standard deviation of beat size in mm 2 and 3",
          "m1"="Standard deviation of beat size in synchronization mm 1",
          "m2"="Standard deviation of beat size in synchronization mm 2",
 varName)
}

# old function for calculating standard deviation
stdv=function(x) {  ( (sum((x-mean(x))^2) / (length(x)-1))  )^.5}


# -------------------- Functions to enable plotting -------------------------------
# the basicPlot function I wrote - extracted from the original file
# we should start to just build a new series of routines and gradually separate this from my accumulated mess of files!
basicPlot=function(df,labels, cols, angles, densityValue=15, ylim,space,ylab=NULL,xlab=NULL,axes=T,labelSize=1,leftSpace=8,topSpace=4,errorBars="ci",offset=0,autoCalculate=T,main=NULL)
{
  par(mar=c(5,leftSpace,topSpace,4)-1)
  	
	if (invalid(cols))
		cols="gray"
		
	if(invalid(angles))
	{
		angles=90;
		densityValue=100
	}	
		
  if (autoCalculate)
  {
    if (invalid(labels))               # if labels not defined
		  labels=colnames(df)              # then default to using colum names as labels
      
  	vals=apply(df,2,mean)
  	
  	if (errorBars=="se")
  	{
  		lowCiVals=apply(df,2,seBelow)
  		highCiVals=apply(df,2,seAbove)
  				
  	}
  		else
  		{						
  			lowCiVals=apply(df,2,ciBelow)    
  			highCiVals=apply(df,2,ciAbove)
  		}
  }	
    else  #  if not autocalculating, assume that 
    {
      vals=df[,1]              # first column of data frame is the main value to plot
      lowCiVals=df[,2]          # second column is the lower bound of the conf int
      highCiVals=df[,3]         # third column is the upper bound of the conf int
      
      if (invalid(labels))      # if labels not defined
		    labels=rownames(df)     # default ot using row names
    }
	
	pos=barplot2(vals, 		# ylim=c(0,100),ylab="rating", 
		names.arg=labels,
		col=cols,
		angle=angles, density=densityValue,
		ylim=ylim,
		ci.l=lowCiVals+offset,
		ci.u=highCiVals+offset,
		plot.ci=TRUE,
		space=space,
		ylab=ylab,
		xlab=xlab,
		axes=axes,
		cex.axis=labelSize,
		cex.names=labelSize,
		offset=offset,
    main=main,
		)
	return (pos)
}

# convenience function returning a vector of confidence intervals below the given vector
ciBelow=function(vec)
{
  a=ci(vec)[2]
	a
}


# convenience function returning a vector a vector of confidence intervals below the given vector
ciAbove=function(vec)
{
	ci(vec)[3]
}

# convenience function returning a vector of confidence intervals (standard error) below the given vector
seBelow=function(vec)
{
  ci(vec,.68)[2]
}

# convenience function returning a vector of confidence intervals (standard error) above the given vector
seAbove=function(vec)
{
  ci(vec,.68)[3]
}

# convenience function to writes text vertically
vtext=function(x=0,y=0,txt,cex=1)
{
  par(srt=90)
	text(x=x,y=y,txt,cex=cex)
	par(srt=0)
}

# File I/O
# saves file to default location, adds ".txt" extention
saveData2=function(data,name,definedPath="",echo=T)
{
  basePath="Data"
	if (definedPath!="")
		basePath=paste(basePath,"/",definedPath,sep="")
	fullName=paste(basePath,"/",name,".txt",sep="")
	write.table(data,fullName,col.names=TRUE,eol="\n",sep="\t",quote=FALSE,row.names=FALSE)
	if (echo)
		cat ("File written as ", fullName,"\n")
}

# easy way to open file
# assumes .txt extention and standard storage location
getData2=function(name,definedPath="",resetLevels=T)
{
	basePath="Data"
	if (definedPath!="")
		basePath=paste(basePath,"/",definedPath,sep="")
	fileName =paste(basePath,"/",name,".txt",sep="")
	data=read.table(fileName,header=T,sep="\t", quote="")
	if (resetLevels)
		data=fixLevels(data)
	data
}

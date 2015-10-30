# ACTUAL DEMO (be sure to load functions/data first)
# note - control+L clears command window
# start by sampling a single note from each instrument

dataPath="~/Documents/Junk/SMT Demo for Dan (Oct 27)/"  # set this to wherever the data are stored
source(paste(dataPath,"Integrated demo for SMT (supporting functions).r",sep=""))


  # note - code written so minor must come first here
par(mfrow=c(1,1))
viewSummary(minorAll,majorAll,colScheme="piano",datType="pitch")
viewSummary(minorT,majorT,colScheme="piano",datType="timing")

par(mfrow=c(1,2))


  # note - confusingly major needs to come first here
viewDistributions(majorAll,minorAll,colScheme="piano")  # shows "all" the data
viewDistributions(majorT,minorT,colScheme="piano",type="Attack rate (note attacks per-second)")  # shows "all" the data

# Violin voices
viewDistributions(h1,h2,overlayed=F)  # view Haydn voices separately
viewDistributions(h1,h2,overlayed=T)  # and overlayed
viewDistributions(m1,m2,overlayed=T)
viewDistributions(b1,b2,overlayed=T)


# (record these for tabulation)
compareN(b1,b2,numNotes=1,verbose=T,groups="violin")

# play with different numbers and see what happens
compareN(b1,b2,numNotes=5,verbose=T,groups="violin")

# comparing pitches
compareN(b1,b2,numNotes=10,verbose=T,groups="violin")

# What exactly "is" a sample?
ourSample=NULL
ourSample=growSample(h1,ourSample)  # histogram  (getObs=1)
ourSample=growSample(h1,ourSample,getObs=1000)

# Now try look at histogram of trying one note 10 times
compareOutcomes(sampleDifferences(m1,m2,numNotes=1,numComparisons=10,showPlot=T))

# Now try 5 notes 10 times 
compareOutcomes(sampleDifferences(m1,m2,numNotes=5,numComparisons=10,showPlot=T))

# Now try 5 notes 1000 times 
compareOutcomes(sampleDifferences(m1,m2,numNotes=5,numComparisons=1000,showPlot=T))

# Now try 500 notes 1000 times 
compareOutcomes(sampleDifferences(m1,m2,numNotes=500,numComparisons=1000,showPlot=T))

# OTHER THINGS (Time dependent)
#  Chi-square info
colnames(essensLt)=c("lt","to")
# remove non-primary scale degrees (just for simplification)
ltPrimary=subset(lt,to=="1" | to=="2" | to=="3" | to=="4" | to=="5"|to=="6"|to=="7")

# what does this "look like"?

ltSummary=count(ltPrimary)  # get a summary

colMix=some(colors(),7)  # get array of cols

# view as barplot
barplot(ltSummary$freq,ylab="Number of instances",xlab="Subsequent Scale Degree",main="Leading tone motion",names.arg=ltSummary$to,col=colMix)

# or as a pie
pie(ltSummary$freq,clockwise=T,col=colMix)

# now do the "real test"
observedValues=ltSummary$freq
meanOutcome=mean(observedValues)
expectedValues=rep(meanOutcome,length(observedValues))
valueComparison=data.frame(observedValues,expectedValues)
chisq.test(valueComparison)


# Expliciting assessing sample size


# a different look at Frontiers Data
par(mfrow=c(1,1))
visualizeVoices(minorAll,majorAll,numNotes=100,numComparisons=1000,title="Bach WTC and Chopin Preludes")

# (optional - if time)
# just Chopin
visualizeVoices(minorC,majorC,numNotes=50,numComparisons=1000,title="Chopin Preludes")
# just Bach
visualizeVoices(minorB,majorB,numNotes=50,numComparisons=1000,title="Bach WTC")



par(mfrow=c(2,2))
mozartA=sampleDifferences(m1,m2,numComparisons=10000,numNotes=1,showPlot=T,minRange=c(-30,40))
mozartB=sampleDifferences(m1,m2,numComparisons=10000,numNotes=5,showPlot=T,minRange=c(-30,40))
mozartC=sampleDifferences(m1,m2,numComparisons=10000,numNotes=20,showPlot=T,minRange=c(-30,40))
mozartD=sampleDifferences(m1,m2,numComparisons=10000,numNotes=100,showPlot=T,minRange=c(-30,40))

compareOutcomes(mozartA)
compareOutcomes(mozartB)
compareOutcomes(mozartC)
compareOutcomes(mozartD)

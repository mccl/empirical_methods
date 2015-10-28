# ACTUAL DEMO (be sure to load functions/data first)
# note - control+L clears command window
# start by sampling a single note from each instrument

dataPath="~/Dropbox/Statz/R/Data/smt2015/"  # set this to wherever the data are stored
source(paste(dataPath,"Integrated demo for SMT (supporting functions).r",sep=""))


  # note - code written so minor must come first here
viewSummary(minorAll,majorAll,colScheme="piano",datType="pitch")
viewSummary(minorT,majorT,colScheme="piano",datType="timing")

  # note - confusingly major needs to come first here
viewDistributions(majorAll,minorAll,colScheme="piano")  # shows "all" the data
viewDistributions(majorT,minorT,colScheme="piano")  # shows "all" the data

# a different look at Frontiers Data
visualizeVoices(minorAll,majorAll,numNotes=100,numComparisons=1000,title="Bach WTC and Chopin Preludes")

# (optional - if time)
# just Chopin
visualizeVoices(minorC,majorC,numNotes=50,numComparisons=1000,title="Chopin Preludes")
# just Bach
visualizeVoices(minorB,majorB,numNotes=50,numComparisons=1000,title="Bach WTC")

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


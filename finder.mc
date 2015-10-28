##### Find basic ("hammer blow") medial caesuras. 
##### D.Shanahan, L. Van Handel, J.Albrecht, and M. Schutz
##### Autumn, 2015


#### Step 1: First get rid of any lines with solfege syllables,
#### (only rests or measures in them). Then, put those lines on their preceding
#### lines (to get measure #'s). Print the file name, followed by 
#### the first data token (the measure number).
#### IMPORTANT: Use this on the Metpos cleaned files.
rests(){
	grep -v [demafsilt] $file | grep -v :.*! | grep -v == | context -n 2 | grep -v ^r | grep ^= > $file.$$
	grep -H ^=.*r $file.$$ | awk '{print $1}' | sed 's/^.*\///g' | sed 's/\.krn.*://g'
	rm $file.$$
}

#### Not surprisingly, this algorithm is SUPER greedy.

#### Step 2: OK, let's just look for rests on strong beats.
#### First, get rid of any data records that aren't measures and 
#### that end with 3-6. Then, search in the same way as Step 1.
strong(){

	grep -v ^[^=].*[3-6] $file | grep -v [demafsilt] | grep -v :.*! | grep -v ==
		context -n 2 | grep -v ^r | grep ^= > $file.$$
	grep -H ^=.*r $file.$$ | awk '{print $1}' | sed 's/^.*\///g' | sed 's/\.krn.*://g'
	rm $file.$$
}

#### Step 3: Let's look for a major chord with re or te in the bass
#### that's a decently long duration. The 'majorpatt' looks for a
#### tonicization of the dominant (also works for minor mode modulations
#### to the minor dominant). The 'minorpatt' looks for a tonicization
#### of the relative major. The '-e' option outputs the relevant data
#### for examination. The 'hcpatt' looks for a strong hc followed by 
#### a rest. It should be noted that hcpatt works for either major
#### or minor mode, as the hc has 'so' in the bass followed by a 
#### chord with 'so' in it (either third of the relative major or
#### root of the dominant).

applied_chord(){

	echo "echo $file" > get_applied.$$
	pattern -f majorpatt -y $file >> get_applied.$$
	pattern -f hcpatt -y $file >> get_applied.$$
	pattern -f minorpatt -y $file >> get_applied.$$
	chmod a+x get_applied.$$
	get_applied.$$ | sed 's/.*\///' | sed 's/\.krn.*//g'
	rm get_applied.$$

}


#### Step 4: Winnow it down by formal section. Find total # of ms.
#### then divide by 3 and only take those measures. After that,
#### search for patterns involving re, sol, or te in the lowest voice,
#### followed by at least 1 rest in the lowest voice, follwed by =.

formal_proportion(){

	echo "echo $file" > formal.$$
	measures=`grep ^= $file | grep -v == | tail -1 | awk '{print $1}' | sed 's/=//g'`
	measures=$((measures / 3))
	yank -o ^= -r 0-`echo $measures` $file #> new.$$
#	sed 's/r //g' new.$$ > new2.$$
#	pattern -f majpatt -y new2.$$ >> formal.$$
#	pattern -f minpatt -y new2.$$ >> formal.$$
#	pattern -f halfpatt -y new2.$$ >> formal.$$
#	chmod a+x formal.$$
#	formal.$$ | sed 's/.*\///' | sed 's/\.krn.*//g'
	rm *.$$
}


#### Woah nelly, that's a lot. Let's make it less greedy..
#### Let's talk about type 1 vs. type 2 errors. (Mike)
harmony(){
	pattern -f mc_pattern $file
}

######Let's make it more specific.

while getopts farsh\? name
do
	for file in $2
		do
			case $name in
			f)    formal_proportion $1;;
			a)    applied_chord $1;;
			r)    rests $1;;
			s)    strong $1;;
			h)    harmony $1;;
			\?)   echo "you did me wrong, dude."
			esac
		done
	done


#OUTTAKES:
#awk '{if (NF<3 || $0 ~ /^=/) print $0}'

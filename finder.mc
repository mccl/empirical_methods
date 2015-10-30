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

	grep -v ^[^=].*[3-6] $file | grep -v [demafsilt] | grep -v :.*! | grep -v == |
		context -n 2 | grep -v ^r | grep ^= > $file.$$
	grep -H ^=.*r $file.$$ | awk '{print $1}' | sed 's/^.*\///g' | sed 's/\.krn.*://g'
	rm $file.$$
}

#### Step 3: Let's do the same thing, but restrict our looking to the first 50%
#### of the movement. This essentially first gets total # of measures, and stores that
#### in a variable, divides by two, and then yanks those measures

formal_proportion(){

	measures=`grep ^= $file | grep -v == | tail -1 | awk '{print $1}' | sed 's/=//g'`
	measures=$((measures / 2))
	yank -o ^= -r 0-`echo $measures` $file > new.$$
	grep -v ^[^=].*[3-6] new.$$ | grep -v [demafsilt] | grep -v :.*! | grep -v == |
		context -n 2 | grep -v ^r | grep ^= > $file.$$
	grep -H ^=.*r $file.$$ | awk '{print $1}' | sed 's/^.*\///g' | sed 's/\.krn.*://g'
	rm new.$$ $file.$$
}

#### Step 4: Ok, now let's look for the stereotypical cadential pattern BEFORE the
#### medial caesura, followed by the MC, followed by a barline, followed by a member of
#### the tonicized harmony. This will require the pattern command. The 'majorpatt' 
#### looks for a re in the lowest part of the chord (this allows for just hammer
#### blows with no full chord; also works for minor mode modulations
#### to the minor dominant), followed by only rests, followed
#### by a barline, followed by a sonority with so anywhere in the sonority.
#### The 'minorpatt' looks for a tonicization of the relative major, followed by
#### a chord with me in it. The '-e' option 
#### outputs the relevant data for examination. The 'hcpatt' looks for a strong hc followed by 
#### a rest, followed by a chord with so. It should be noted that hcpatt works for either major
#### or minor mode, as the hc has 'so' in the bass followed by a 
#### chord with 'so' in it (either third of the relative major or
#### root of the dominant). It's important to stress that, as before, only the
#### first half of the piece is selected, the cadence must appear either on
#### the downbeat or halfway through a measure, and the tonicized chord member
#### is searched for on the downbeat following the barline.

cadence(){

	measures=`grep ^= $file | grep -v == | tail -1 | awk '{print $1}' | sed 's/=//g'`
	measures=$((measures / 2))
	yank -o ^= -r 0-`echo $measures` $file > new.$$
	echo "echo $file" > get_cadence.$$
	pattern -f majorpatt -y new.$$ >> get_cadence.$$
	pattern -f hcpatt -y new.$$ >> get_cadence.$$
	pattern -f minorpatt -y new.$$ >> get_cadence.$$
	chmod a+x get_cadence.$$
	echo $file | sed 's/^.*\///g' | sed 's/\.krn.*//g' > result.$$
	get_cadence.$$ | grep ^= | awk '{print $1}' >> result.$$
	tr '\n' ' ' < result.$$ > format.$$
	awk '{if (NF > 1) print $0}' format.$$
	rm get_cadence.$$ new.$$ result.$$ format.$$

}

#### Step 4b: Same as above, but show the results.

provide_details(){

	measures=`grep ^= $file | grep -v == | tail -1 | awk '{print $1}' | sed 's/=//g'`
	measures=$((measures / 2))
	yank -o ^= -r 0-`echo $measures` $file > new.$$
	echo "echo $file" > get_cadence.$$
	pattern -f majorpatt -y new.$$ >> get_cadence.$$
	pattern -f hcpatt -y new.$$ >> get_cadence.$$
	pattern -f minorpatt -y new.$$ >> get_cadence.$$
	chmod a+x get_cadence.$$
	get_cadence.$$ | sed 's/^.*\///g' | sed 's/\.krn.*//g'
	rm get_cadence.$$ new.$$

}

#### Step 5: Just look for hammerblows. This involves first taking the first half of the piece,
#### then re-timebas-ing and metpos-ing the work, removing all empty lines, and all metric 
#### positions that are not at least 1 or 2, finding the quality and inversion of each sonority,
#### and removing everything in inversion (M.C. are usually preceding by root position). Finally,
#### select only major chords, single notes, rests, and measure #s, print the first column (root
#### of the chord, rest, or measure #), context it with 4 items, find only those sequences that
#### end with rests, and if any of the chord roots match, print all chord roots that are re, so, or te.

hammerblow(){

	measures=`grep ^= $file | grep -v == | tail -1 | awk '{print $1}' | sed 's/=//g'`
	measures=$((measures / 2))
	yank -o ^= -r 0-`echo $measures` $file > new.$$
	echo $file | sed 's/^.*\///g' | sed 's/\.krn.*//g' > printout.$$
	grep -v ^[^=].*[3-7]$ new.$$ | 
	sonority -at | sonority -ai | solfa -x | grep -v ^[^=].*[1-3X]$ | rid -GLId | 
	awk '{print $1, $(NF-1)}' | egrep '(maj|note|rest|=)' | awk '{print $1}' | context -n 4 | 
	grep r$ | awk '{if ($1 == $2 || $1 == $3) print $0}' | egrep '(re|so|te)' >> printout.$$
	tr '\n' ' ' < printout.$$ | grep =
	rm new.$$ printout.$$

}

#### Step 5b: Just print measure number this thing shows up in.

measure_hammerblow(){

	measures=`grep ^= $file | grep -v == | tail -1 | awk '{print $1}' | sed 's/=//g'`
	measures=$((measures / 2))
	yank -o ^= -r 0-`echo $measures` $file > new.$$
	echo $file | sed 's/^.*\///g' | sed 's/\.krn.*//g' > printout.$$
	grep -v ^[^=].*[3-7]$ new.$$ | 
	sonority -at | sonority -ai | solfa -x | grep -v ^[^=].*[1-3X]$ | rid -GLId | 
	awk '{print $1, $(NF-1)}' | egrep '(maj|note|rest|=)' | awk '{print $1}' | context -n 4 | 
	grep r$ | awk '{if ($1 == $2 || $1 == $3) print $0}' | egrep '(re|so|te)' | sed 's/[^=0-9]*//g' >> printout.$$
	tr '\n' ' ' < printout.$$ | grep =
	rm printout.$$ new.$$
	
}

while getopts frschpm\? name
do
	for file in $2
		do
			case $name in
			f)    formal_proportion $1;;
			r)    rests $1;;
			s)    strong $1;;
			c)    cadence $1;;
			h)    hammerblow $1;;
			p)    provide_details $1;;
			m)    measure_hammerblow $1;;
			\?)   echo "you did me wrong, dude."
			esac
		done
	done


#OUTTAKES:
#awk '{if (NF<3 || $0 ~ /^=/) print $0}'

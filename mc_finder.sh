##### Find basic ("hammer blow") medial caesuras. 
##### D.Shanahan, L. Van Handel, J.Albrecht, and M. Schutz
##### Autumn, 2015


####Step 1: Find all rests in lower three voices.
rests(){

grep 'r	r	r	r' $file | grep -v 'r[iae]' | awk 'NF == 5'

}


####Step 2: OK, let's just look for rests in three lower voices.
lowerthree(){

grep '^r	r	r' $file | grep -v 'r[iae]' | awk 'NF == 5'

}

####Woah nelly, that's a lot. Let's make it less greedy..
#####Let's talk about type 1 vs. type 2 errors. (Mike)
harmony(){
	pattern -f mc_pattern $file
}

######Let's make it more specific.

while getopts rlh\? name
do
	for file in $2/*.clean
		do
			case $name in
			r)    rests $1;;
			l)    lowerthree $1;;
			h)    harmony $1;;
			\?)   echo "you did me wrong, dude."
			esac
		done
	done


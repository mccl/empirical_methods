## This script cleans up either string quartets or piano sonata movements.
## It's like the other, except it retains duration data for looking at long
## sonorities.

extract -i '**kern' $1 | rid -GLd | sed 's/[^A-G.a-g0-9=	*#krn:-]*//g' | solfa | rid -I | sed 's/[kn]//g' | 
sed 's/	/ /g'













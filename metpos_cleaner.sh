## This script cleans up either string quartets or piano sonata movements.
## First, it takes only kern data (eliminating *dyn spines or any others).
## Then, it dittos all of the values, so that each sonority is filled out.
## Then, it timebases and metposes, so that the metric strength of each
## attack is recorded. Once that info is recorded, we no longer need 
## durations, so the pitches are interpreted by explicit key as solfege
## syllables, and then everything but those solfege syllables and the 
## metpos data is eliminated. Finally, all spines are collapsed into one
## sonority per attack, and any data records that contain only null tokens
## and metpos data are eliminated.

## Newly updated 10/17: It turns out that the double barlines/repeats
## between large formal sections were throwing off the metpos when they 
## broke a measure in half. To eliminate that effect, the double barlines
## without measure numbers need to be eliminated. This new command is
## added: "grep -v :.*!" to fix this.
## NOTE: By doing this, formal section breaks (esp. after exposition)
## are eliminated and can't be used to determine M.C. Use the Rhythm
## cleaned files to look at formal sections.

extract -i '**kern' $1 | ditto | grep -v ^=:\|! | timebase -t 32 | metpos | solfa -x | rid -GLId | sed 's/	/ /g' | egrep -v '\. '+[1-6]













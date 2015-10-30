for file in $1
do
	
	extract -i '**kern,**timebase' $file | timebase -t 32 | metpos | solfa -x | rid -GLId | head -1 | awk '{print NF}'
done



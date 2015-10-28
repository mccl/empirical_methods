#####kern syntax
#######Use grep
###This grabs titles
grep 'OTL' */*.krn


####This sees what meters are most common:
grep -h '\*M' */*/*.krn | sortcount -p


#############REQUIRES KEY CONTEXT
############# What needs to be encoded and how explicitly.


####What's the most common pitch in the folksongs?
solfa -x */*.krn | rid -GLId | grep -v '=' | sortcount -p

####or with deg:
deg -a */*/*.krn | rid -GLId | grep -v '=' |  sortcount -p

####and with context:

deg -a */*/*.krn | rid -GLId | grep -v '=' | context -n 2 | sortcount -p


####How often does leading tone go to 1 in folksongs:
deg -a */*/*.krn | rid -GLId | grep -v '=' | context -n '2' | grep '^7 ' | sortcount -p

####mint and then hint on another corpus

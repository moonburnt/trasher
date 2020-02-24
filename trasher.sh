#!/bin/bash

scriptname=`basename "$0"`

#setting our work directory
workdir="`dirname "$0"`"
cd $workdir

#First of all - lets match pre-requirements - set up variables for trash directory and check if it exists on our drive at all
#WARNING - currently it assumes that only one trash folder located in $HOME/.local/share/Trash/ can exist FOR ALL drives. If you will try to trash files from other drive - they will be moved into that directory on the drive with $HOME on it.
trashdir="$HOME/.local/share/Trash/"
trashfiles=$trashdir"/files"
trashinfo=$trashdir"/info"

if [ -d $trashdir ] ; then
	echo "Found trash directory on" $trashdir", proceed"
else
	echo "Couldnt find the trash directory, abort"
	exit 1
fi

#Now - lets find if our input isnt empty
if (("$#" == 0)); then
	echo "Input is empty. Usage:" $scriptname "files to trash"
	exit 1
fi

#making it loop till the end of received input
for trashed in "$@"; do
	#checking if there are files, dirs or symlinks that match input's pattern. If no - skipping
	if [ -f $trashed ] || [ -d $trashed ] || [ -L $trashed ]; then
		echo "Found" $trashed "in current directory, proceed"
	else
		echo "Couldnt find" $trashed "in current directory, skipping"
		continue
	fi

	#checking if file with such name already exists in trash bin, in order to avoid accident overwrite
	if [ -f $trashfiles"/"$trashed ] || [ -d $trashfiles"/"$trashed ] || [ -L $trashfiles"/"$trashed ]; then
		echo $trashed "already exists in" $trashdir", trying to find filename replacement"
		x="1"
		while true; do
			x=$((x+1))
			tmask=$(echo $trashed | sed "s/\./&$x./")
			if ! [ -f $trashfiles"/"$tmask ] || [ -d $trashfiles"/"$tmask ] || [ -L $trashfiles"/"$tmask ]; then
				echo $tmask "doesnt exist in trash directory, proceed"
				break
				fi
		done
	else
		tmask=$trashed
	fi

	#making the .trashinfo file, that will contain info regarding our file's original location and deletion date
	#urlencode it, coz thats necessary for trashinfo in non-us locale. The first sed deals with jq's attempts to add empty line at the end of every urlencoded input. The last sed is required to avoid urlencoding slashes
	urlenpath=$(realpath -s $trashed | jq -s -R -r @uri | sed 's/%0A$//' | sed 's/%2F/\//g')
	deltime=$(date +%FT%T)
	#based on data we just got - lets create the actual .trashinfo file and move it to where it belongs
	echo -e "[Trash Info]\nPath="$urlenpath"\nDeletionDate="$deltime > $trashinfo"/"$tmask".trashinfo"

	#finally, we can move our file into trash
	mv $trashed $trashfiles"/"$tmask
	echo "Successfully trashed" $trashed "into" $trashdir "under the name of" $tmask
	done

#todo: different trashdirs for different partitions

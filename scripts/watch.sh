#!/bin/bash

scripts="$(realpath "$(dirname $0)")"
cd ~/binary/


while true
do
	(cd binary-master; git pull)
	for rev in $(cd binary-master; git log --oneline --first-parent 4853c7b467409468ac9029558c8ed3caa4a4be6c..HEAD | cut -d\  -f1 | tac)
	do
		if ! [ -e "$rev.log" -o  -e "$rev.log.broken" -o -d "binary-tmp-$rev" ]
		then
			echo "Benchmarking $rev..."
			$scripts/run-speed.sh "$rev" >/dev/null
                        git add $rev.log*
                        git commit -m "Log for $rev"
                        git push
			break
		fi
	done
	sleep 60 || break
done

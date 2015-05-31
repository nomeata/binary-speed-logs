#!/bin/bash

function say {
	echo
	echo "$@"
	echo
}

function run {
	echo "$@"
	"$@"
}

rev="$1"
if [ -z "$rev" ]
then
  echo "$0 <rev>"
fi

set -e


cd ~/binary/

cd binary-master
git pull
cd ..


if [ -e "binary-tmp-$rev" ]
then
	echo "binary-tmp-$rev already exists"
	exit 1
fi

#logfile="$rev-$(date --iso=minutes).log"
logfile="$rev.log"
exec > >(sed -e "s/binary-tmp-$rev/binary-tmp-REV/g" | tee "$logfile".tmp)
exec 2>&1

set -o errtrace

function failure {
	test -f "$logfile".tmp || cd ..
	say "Failure..."
	run mv "$logfile".tmp "$logfile".broken
	run rm -rf "binary-tmp-$rev"
}
trap failure ERR

say "Cloning"

run git clone --recursive --reference binary-master git://github.com/kolmodin/binary.git "binary-tmp-$rev"
cd "binary-tmp-$rev"
run git checkout "$rev"

say "Identifying"

run git log -n 1

say "Code stats"

run ohcount src/

say "Building"

run cabal configure  --enable-benchmarks
run cabal build

say "Benchmarking"

run cabal bench
say "Cleaning up"

run cd ..

run rm -rf "binary-tmp-$rev"
run mv "$logfile".tmp "$logfile"

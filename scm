#!/bin/sh

#------------------------------------------------------------------------------------------------
# constants
#------------------------------------------------------------------------------------------------

RED='\033[0;31m'
NC='\033[0m'


#------------------------------------------------------------------------------------------------
# working modes
#------------------------------------------------------------------------------------------------

# Clones a repository to the workdir
clone() {
	echo -e "I ${RED}love${NC} Stack Overflow"
	git clone --single-branch --depth 1 -b $2 $1 /work || exit $?
	git --no-pager log -1 --pretty="{\"author\": \"%an\", \"ref\":\"%H\", \"message\":\"%B\"}"
}

# Compares the head revision of a branch.
compare() {
	# get all the refs from the remote repository
	refs=$(git ls-remote $1)
	ret=$?
	if [ $ret -ne 0 ]
	then
		echo "failed to fetch remote repository"
		exit $ret
	fi

	# find the ref of the given branch
	branch_ref=$(echo "$refs" | grep "refs/heads/$2" | cut -f1)
	if [ -z $branch_ref ]
	then
		echo "branch not found"
		exit 2
	fi

	# check if something has changed
	if [[ "$branch_ref" = "$3" ]]
	then
		echo "no changes detected"
		exit 1
	else
		echo "$branch_ref"
		exit 0
	fi
}

# Gets the head revision of give repository and branch.
head() {
	# get all the refs from the remote repository
	refs=$(git ls-remote $1)
	ret=$?
	if [ $ret -ne 0 ]
	then
		echo "failed to fetch remote repository"
		exit $ret
	fi

	# find the ref of the given branch
	branch_ref=$(echo "$refs" | grep "refs/heads/$2" | cut -f1)
	if [ -z $branch_ref ]
	then
		echo "branch not found"
		exit 1
	fi

	echo "$branch_ref"
}


#------------------------------------------------------------------------------------------------
# application entry
#------------------------------------------------------------------------------------------------

case "$1" in
	clone)
		clone $2 $3
	;;

	head)
		head $2 $3 $4
	;;

	# invalid command was supplied
	*)
		echo "invalid command"
		exit 80
	;;
esac
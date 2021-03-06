#!/bin/sh

#------------------------------------------------------------------------------------------------
# constants
#------------------------------------------------------------------------------------------------

RED='\033[0;31m'
NC='\033[0m'
WORKDIR='work'

#------------------------------------------------------------------------------------------------
# helper functions
#------------------------------------------------------------------------------------------------

# Escapes all relevant chars.
function escape_chars {
    sed -r 's/\\/'\\\\\\\\'/g' | \
    sed -r 's/"/'\\\\\"'/g' | \
    sed -r 's/\t/'\\\\t'/g' | \
    sed -r 's/\r/'\\\\r'/g' | \
    sed -r ':a;N;$!ba;s/\n/\\n/g'
}


#------------------------------------------------------------------------------------------------
# working modes
#------------------------------------------------------------------------------------------------

# Clones a repository to the workdir
clone() {
	echo -e "I ${RED}love${NC} Stack Overflow"
	mkdir $WORKDIR
	yes | git clone --single-branch --depth 1 -b $2 $1 $WORKDIR || exit $?
	cd $WORKDIR

	author=$(git log -n1 --pretty=format:'%aN' | escape_chars)
	ref=$(git log -n1 --pretty=format:%H | escape_chars)
	message=$(git log -n1 --pretty=format:%B | escape_chars)
	echo "{\"author\":\"$author\",\"ref\":\"$ref\",\"message\":\"$message\"}"
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

# ssh configuration for git
export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /tmp/id_rsa"

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

#!/bin/bash
release_gen_path=$(git rev-parse --show-toplevel)

echo "$git_credentials" > ~/.git-credentials
DEFAULT_TAG="v1.0.0"
ORIGIN="Dulce-Work-Schedule"
echo "Checking repos..."
if [ ! -d "2018.1-Dulce_App" ]; then
	echo "Cloning repo..."
	git clone https://github.com/$ORIGIN/2018.1-Dulce_App.git
fi

if [ ! -d "2018.1-Dulce_API" ]; then
	git clone https://github.com/$ORIGIN/2018.1-Dulce_API.git
fi

for f in $(ls -d */ | cut -f1 -d'/'); 
do
	cd $f
	echo "Adding official remote for $f..."
	git remote add official https://github.com/fga-gpp-mds/$f.git
	git config credential.helper store
	echo "git rebase..."
	git pull --rebase official master
	echo "Getting last git tag..."
	LOG_DIFF=""
	version=$(git describe --tags --abbrev=0)
	if [ "$?" -eq 0 ]
	then
		IFS='.' read -ra CURRENT_TAG <<< "${version}"
		CURRENT_TAG_LEN=$(expr ${#CURRENT_TAG[@]} - 1)
		NEW_TAG=""
		for (( i=0; i<${CURRENT_TAG_LEN}; i++ ));
		do
		  NEW_TAG="${NEW_TAG}${CURRENT_TAG[$i]}."
		done
		echo "Increment patch version..."
		NEW_TAG="${NEW_TAG}$(expr ${CURRENT_TAG[${CURRENT_TAG_LEN}]} + 1)"
		echo ${NEW_TAG}
		# Can replace this for one python scrapping script. Make release notes from milestone
		echo "Getting commit messages..."
		LOG_DIFF="${version}..HEAD"
	else
		echo "No version found..."
		echo "Setting DEFAULT_TAG value..."
		NEW_TAG="$DEFAULT_TAG"
		echo ${NEW_TAG}
		# Can replace this for one python scrapping script. Make release notes from milestone
		echo "Getting commit messages..."
	fi
	git log $LOG_DIFF --oneline | grep -v "@" | grep "#" | grep -v "Merge" | tr -s '[:space:]' | cut -c 9- > tag_message.txt
	echo "Creating git tag..."
	git tag -a $NEW_TAG -F tag_message.txt
	git push origin $NEW_TAG
	echo "Removing tag_message file..."
	rm tag_message.txt
	# git show $NEW_TAG
	cd $release_gen_path
	# echo "Removing folder $f..."
	# rm -rf $f
done

#!/bin/bash

if [ -z $CRON_JOB_DAY ];
then
	echo "This is not a cron job right?"
else
	if [ ! $(date +%u) != "$CRON_JOB_DAY" ];
	then
		echo -e "This task will run only at day '$CRON_JOB_DAY'.\n(Day count starts on 1 |Monday|)"
		exit 0;
	fi
fi

git_tag_gen_path=$(git rev-parse --show-toplevel)

echo "$git_credentials" > ~/.git-credentials;
git config credential.helper store;
DEFAULT_TAG="v1.0.0";
if [ -z $ORIGIN ];
then
	ORIGIN="Dulce-Work-Schedule";
fi
repos=($(echo $(cat repos.txt)))
for f in ${repos[@]}; 
do
	echo "Checking repo...";
	if [ ! -d "$f" ]; then
		echo "Cloning repo..."
		git clone https://github.com/$ORIGIN/$f.git || echo "Failed to clone repository..." && exit 1
	fi
	cd $f && \
	git config credential.helper store && \
	echo "git rebase..." && \
	git pull --rebase origin master && \
	echo "Getting last git tag..." && \
	LOG_DIFF="" && \
	CURRENT_TAG=$(git describe --tags --abbrev=0)
	if [ "$?" -eq 0 ];
	then
		last_commit=$(git log -n 1 --oneline HEAD  | cut -f 1 -d' ') && \
		tag_commit=$(git rev-list -n 1 ${CURRENT_TAG} --oneline | cut -f 1 -d' ') && \
		if [ $last_commit == $tag_commit ]
		then
			echo "Tag ${CURRENT_TAG} have the last commit $last_commit..."
			continue
		else
			echo "Current tag: ${CURRENT_TAG}" && \
			IFS='.' read -ra CURRENT_TAG_ARRAY <<< "${CURRENT_TAG}" && \
			CURRENT_TAG_ARRAY_LEN=$(expr ${#CURRENT_TAG_ARRAY[@]} - 1) && \
			NEW_TAG="" && \
			for (( i=0; i<${CURRENT_TAG_ARRAY_LEN}; i++ ));
			do
			  NEW_TAG="${NEW_TAG}${CURRENT_TAG_ARRAY[$i]}."
			done
			echo "Increment patch version..." && \
			NEW_TAG="${NEW_TAG}$(expr ${CURRENT_TAG_ARRAY[${CURRENT_TAG_ARRAY_LEN}]} + 1)" && \
			echo ${NEW_TAG} && \
			LOG_DIFF="${CURRENT_TAG}..HEAD"
		fi
	else
		echo "No version found..." && \
		echo "Setting DEFAULT_TAG value..." && \
		NEW_TAG="$DEFAULT_TAG" && \
		echo ${NEW_TAG}
	fi
	echo "Getting commit messages..." && \
	git log $LOG_DIFF --oneline | grep -v "@" | grep "#" | grep -v "Merge" | tr -s '[:space:]' | cut -c 9- > tag_message.txt && \
	echo "Creating git tag..." && \
	git tag -a $NEW_TAG -F tag_message.txt && \
	git push origin $NEW_TAG && \
	echo "Removing tag_message file..." && \
	rm tag_message.txt && \
	cd $git_tag_gen_path
done
exit 0
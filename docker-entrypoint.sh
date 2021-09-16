#!/bin/sh

get_last_commit_hash() {
	LAST_COMMIT=$(git rev-parse --verify HEAD)
	if [ -n "$DRONE_COMMIT" ]; then
		LAST_COMMIT=$DRONE_COMMIT
	fi

	echo $LAST_COMMIT
}

get_parent_tag() {
	git tag -l | sort -V | tail -n 2 | head -n 1
}

get_before_last_commit() {
	line_searched=$(git log --pretty=format:'%h %d' | cat -n | grep $1 | awk '{ print $1 }')
	minus_one=$((line_searched - 1))

	git log --pretty=format:'%h' | head -n $minus_one | tail -n 1
}

get_tag_number() {
	git tag -l | wc -l
}


echo "$DRONE_NETRC_FILE" > $HOME/.netrc
git fetch --tags

tag_nb=$(get_tag_number)

if [ $tag_nb -le 1 ]; then
	last_commit=$(get_last_commit_hash)

	git_diff_tree_cmd="git diff-tree --no-commit-id --name-only -r --root ${last_commit}"
elif [ $tag_nb -gt 1 ]; then
	log_line_tmp_nb=$(git --no-pager log --pretty=format:'%h' | wc -l)
	log_line_nb=$((log_line_tmp_nb + 1))

	if [ $log_line_nb -eq 2 -a $tag_nb -eq 2 ]; then
		last_commit=$(get_last_commit_hash)

		git_diff_tree_cmd="git diff-tree --no-commit-id --name-only -r ${last_commit}"
	elif [ $tag_nb -eq 2 -a $log_line_nb -gt 2 ]; then
		last_commit=$(get_last_commit_hash)
		parent_tag=$(get_parent_tag)
		before_last_commit=$(get_before_last_commit $parent_tag)


		git_diff_tree_cmd="git diff-tree --no-commit-id --name-only -r ${before_last_commit}~ ${last_commit}"
	else
		last_commit=$(get_last_commit_hash)
		parent_tag=$(get_parent_tag)

		if [ -z "$last_commit" -a -z "$parent_tag" ]; then
			echo "error: could not get the last commit and / or parent commit"
			exit 1
		fi

		git_diff_tree_cmd="git diff-tree --no-commit-id --name-only -r ${parent_tag}~ ${last_commit}"
	fi
fi

if [ $(eval ${git_diff_tree_cmd} | grep '.proto$' | wc -l) -eq 0 ]; then
	echo "no proto file changed"
	exit 1
fi

#!/bin/bash
# get the current branch name of a git repo
git rev-parse --abbrev-ref HEAD

# Example use:
# git push -u origin $(current_branch_name)
# END

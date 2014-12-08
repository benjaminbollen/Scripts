#!/bin/bash

# Credit and forked from github.com/Fraser999/Scripts

read -p "Enter your GitHub username: " User
read -p "Enter the topic name for clone: " Clone

echo ""
git clone git@github.com:$User/MaidSafe MaidSafe-$Clone
echo "==============================================================================="

echo -e "Configuring super-project\n-------------------------"
cd MaidSafe-$Clone
git remote add upstream git@github.com:maidsafe/MaidSafe
#git remote set-url --push upstream disable_push
git fetch upstream

# Create local tracking branches 'master' and 'next' if these exist in 'origin/', checkout to 'next'
# and merge 'upstream/next'.
CurrentWorkingBranch=$(git rev-parse --abbrev-ref HEAD)
if [ `git branch --list -r origin/master` -a $CurrentWorkingBranch != master ] ; then
  git branch -t -f master origin/master
fi
if [ `git branch --list -r origin/next` -a $CurrentWorkingBranch != next ] ; then
  git branch -t -f next origin/next
  git checkout next
  git merge upstream/next
fi

# Display info on remotes, branches and current status of 'next'.
echo ""
git remote -v
echo ""
git branch -vva
echo ""
git status
echo "==============================================================================="

echo -e "Initialising submodules\n-----------------------"
git submodule update --init
echo "==============================================================================="

for i in `grep path .gitmodules | sed 's/.*= //'` ; do
  Submodule=$(git -C $i config --get remote.origin.url | sed 's#.*/##')
  echo -e "Configuring $Submodule\n------------`echo "$Submodule" | tr [:print:] -`"
  git -C $i remote rename origin upstream
#  git -C $i remote set-url --push upstream disable_push

  git -C $i remote add origin `git -C $i config --get remote.upstream.url | sed 's/github.com:maidsafe/github.com:'$User'/'`
  git -C $i fetch origin

  # Create local tracking branches 'master' and 'next' if these exist in 'origin/', checkout to 'next'
  # and merge 'upstream/next'.
  CurrentWorkingBranch=$(git -C $i rev-parse --abbrev-ref HEAD)
  if [ `git -C $i branch --list -r origin/master` -a $CurrentWorkingBranch != master ] ; then
    git -C $i branch -t -f master origin/master
  fi
  if [ `git -C $i branch --list -r origin/next` -a $CurrentWorkingBranch != next ] ; then
    git -C $i branch -t -f next origin/next
    git -C $i checkout next
    git -C $i merge upstream/next
  fi
  
  git -C $i checkout next
  
  # Display info on remotes, branches and current status of 'next'.
  echo ""
  git -C $i remote -v
  echo ""
  git -C $i branch -vva
  echo ""
  git -C $i status
  echo "==============================================================================="
done

#!/usr/bin/env bash

pom_path="./"
pom_name="pom.xml"
git_path_output="../"
ssh_prefix="ssh://git@gitlab.cloudvector.fr:10022"
git_repository_path="micro-service/rx"

usage() {
  echo -e "$0 <options>"
  echo ""
  echo -e "\t--pom-path=<path>\t\t\t\tpom path"
  echo -e "\t--pom-name=<path>\t\t\t\tpom name if differente of \"pom.xml\""
  echo -e "\t--git-output=<path>\t\t\t\toutput directory with ../ (link to parent)"
  echo ""
  echo -e "\t--git-repository-path=<ssh://git@url:port>\tremote repository url + protocol"
  echo -e "\t--ssh-prefix=<projetct_remote_path>\t\tremote project path"
  echo ""
  echo -e "\t--pull\t\t\t\t\t\tpull git repository"
  echo -e "\t--clone\t\t\t\t\t\tclone git repository"
}

if [[ " $@ " == *" --help "* || " $@ " == *" -h "* ]]; then
  usage
  exit 0
fi

if [[ " $@ " =~ --ssh-prefix=([^' ']+) ]]; then
  echo "+ set ssh prefix"
  ssh_prefix=${BASH_REMATCH[1]}
fi

if [[ " $@ " =~ --git-repository-path=([^' ']+) ]]; then
  echo "+ set git repository path"
  git_repository_path=${BASH_REMATCH[1]}
fi

if [[ " $@ " =~ --pom-path=([^' ']+) ]]; then
  echo "+ set pom path"
  pom_path=${BASH_REMATCH[1]}
fi

if [[ " $@ " =~ --pom-name=([^' ']+) ]]; then
  echo "+ set pom name"
  pom_name=${BASH_REMATCH[1]}
fi

if [[ " $@ " =~ --git-output=([^' ']+) ]]; then
  echo "+ set git output"
  # todo check if pom path parent exist !
  git_path_output="../${BASH_REMATCH[1]}"
fi

modules=$(grep -oP '.*\K(?<=>).*(?=<\/module>)' pom.xml)
modules=${modules//..\//}

cmd() {
  for item in $modules; do
    echo "-> git $1 on $item"
    # check if item exist before action
    cd $git_path_output/$item
    git $1
  done
}

clone() {
  cd $git_path_output
  for item in $modules; do
    echo "-> git clone on $item"
    git clone ${ssh_prefix}/${git_repository_path}/${item}.git
  done
}

if [[ " $@ " == *" --clone "* ]]; then
  clone
fi

if [[ " $@ " == *" --fetch "* ]]; then
  cmd fetch
fi

if [[ " $@ " == *" --pull "* ]]; then
  cmd pull
fi

# grep -oP '.*\K(?<=>).*(?=<\/)' pom.xml

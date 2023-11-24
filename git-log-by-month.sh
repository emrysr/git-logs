#!/usr/bin/env bash
#
# author: emrys
# 2023-10-20
#
# Split git log commits into a file per month for a given user
# usage: ./git-log-by-month.sh [-n <name>][-y <year>][-r pwd][-o output][-d][-h]"
#  -n, --name STRING       Specify the name"
#  -y, --year STRING       Specify the year"
#  -o, --out STRING        Specify the output"
#  -r, --repo STRING       Specify the repository"
#  -v, --version           Display version information"
#  -d, --dry-run           Perform a dry run (no actual changes)"
#  -h, -?, --help          Display this help message"

VERSION=0.0.4

YEAR=$(date +"%Y")
NAME=$USER
OUT=/tmp
PWD=$(pwd)

name=""
year=""
out=""
repo=""
version=false
dry_run=false
help_requested=false

inputs() {
  if [ -n "$year" ]; then
    echo "Year = $year"
  else
    if [ -z "${year}" ]; then
      echo "Which year?: [${YEAR}]"
      read year
    fi
    if [ -z "${year}" ]; then
      year=$YEAR
    fi
  fi

  if [ -n "$name" ]; then
    echo "Name = $name"
  else
    if [ -z "${name}" ]; then
      echo "Enter Your Name: [${NAME}]"
      read name
    fi
    if [ -z "${name}" ]; then
      name=$NAME
    fi
  fi

  if [ -n "$repo" ]; then
    echo "Repository = $repo"
  else
    if [ -z "${repo}" ]; then
      echo "Repository Directory: [${PWD}]"
      read repo
    fi
    if [ -z "${repo}" ]; then
      repo=$PWD
    fi
  fi

  if [ -n "$out" ]; then
    echo "Output = $out"
  else
    if [ -z "${out}" ]; then
      echo "Output Directory: [${OUT}]"
      read out
    fi
    if [ -z "${out}" ]; then
      out=$OUT
    fi
  fi
}
separator() {
  echo "------------------------------------------"
}
description() {
  separator
  echo "   All git logs by month for given user"
  separator
}
greet() {
  echo "hit [Enter] for defaults..."
}
invalid() {
  echo "Unknown option: $1" >&2
  help
}
version() {
  echo "v$VERSION"
}
help() {
  echo "help:"
  description
  echo "Usage: ./git-log-by-month.sh [OPTIONS]"
  echo "Options:"
  echo "  -n, --name STRING       Specify the name"
  echo "  -y, --year STRING       Specify the year"
  echo "  -o, --out STRING        Specify the output"
  echo "  -r, --repo STRING       Specify the repository"
  echo "  -v, --version           Display version information"
  echo "  -d, --dry-run           Perform a dry run (no actual changes)"
  echo "  -h, -?, --help          Display this help message"
}
printvars() {
  echo " DRY RUN: variables used..."
  separator
  echo "  year: ${year}"
  echo "  name: ${name}"
  echo "  repository: ${repo}"
  echo "  out: ${out}"
  echo ""
}
debug() {
  echo "dry run"
  separator
  version
  inputs
  printvars

  echo "Example line that would be produced from $repo:"
  git -C "${repo}" log \
    --author="$name" \
    --no-merges \
    --date-order \
    --reverse \
    --abbrev-commit \
    --date=local \
    --date=short \
    --pretty='format:%h %ad %s <%an>' \
    --branches | head -n 1
  separator

  exit 1
}
function header {
  begin="Commits for "
  case $1 in
    1) month='January ' ;;
    2) month='February ' ;;
    3) month='March ' ;;
    4) month='April ' ;;
    5) month='May ' ;;
    6) month='June ' ;;
    7) month='July ' ;;
    8) month='August ' ;;
    9) month='September ' ;;
    10) month='October ' ;;
    11) month='November ' ;;
    12) month='December ' ;;
  esac

  echo "$begin$month$year - ($origin_url)"
}



# RUN THE SCRIPT

if [[ $# -lt 1 ]]; then
  greet
fi

# take inputs from user or script arguments or use defaults
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -n|--name)
      name="$2"
      shift 2
      ;;
    -y|--year)
      year="$2"
      shift 2
      ;;
    -o|--out)
      out="$2"
      shift 2
      ;;
    -r|--repo)
      repo="$2"
      shift 2
      ;;
    -v|--version)
      version=true
      shift
      ;;
    -d|--dry-run)
      dry_run=true
      shift
      ;;
    -h|-?|--help)
      help_requested=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      help_requested=true
      shift
      ;;
  esac
done

# Check if help is requested
if [ "$help_requested" = true ]; then
  help
  exit 0
fi

# Check if dry run is requested
if [ "$dry_run" = true ]; then
  debug
  exit 0
fi

# Check if help is requested
if [ "$version" = true ]; then
  version
  exit 0
fi

# show welcome message and any parsed inputs
greet
# ask user for missing inputs
inputs

# ALL SCRIPT INPUT VARIABLE SET BEYOND THIS POINT

# get git repo source - used in the output file header
origin_url=$(git -C "${repo}" remote get-url origin)

# get git repo name - used to name the output subdirectory
origin=$(basename "$origin_url")

# run the git log command for every month
mkdir -p "$out/$origin"
for month in {1..12}; do
  git -C "${repo}" log \
    --since="$year-$month-01" \
    --until="$year-$month-31" \
    --author="$name" \
    --no-merges \
    --date-order \
    --reverse \
    --abbrev-commit \
    --date=local \
    --date=short \
    --pretty='format:%h %ad %s <%an>' \
    --branches > gitlog-"$year"-"$month"

  echo "$(header "$month")" | cat - gitlog-"$year"-"$month" > "$out/$origin/gitlog-$myear-$onth.txt"

done

echo "Saved 12 files to ${out}/${origin}/"
separator

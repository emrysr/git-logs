# Pretty git logs

Bash script output files from git logs by users and month.

Run with `--dry-run` to see what inputs are parsed.

Splits git log commits into a file per month for a given user


## output of `--help`
```sh
  usage: ./git-log-by-month.sh [-n <name>][-y <year>][-r pwd][-o output][-d][-h]"
   -n, --name STRING       Specify the name"
   -y, --year STRING       Specify the year"
   -o, --out STRING        Specify the output"
   -r, --repo STRING       Specify the repository"
   -v, --version           Display version information"
   -d, --dry-run           Perform a dry run (no actual changes)"
   -h, -?, --help          Display this help message"
```

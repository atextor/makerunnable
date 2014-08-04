#!/bin/bash
# makerunnable - version 0.1
# Andreas Textor <textor.andreas@googlemail.com>

message="No Java Runtime was found. Please visit http://java.com/ to download it."
tempdir=/dev/shm

function usage() {
	cat <<- EOF
	Usage: $0 [-h | --help] [-o outfile] [-t tempdir] jarfile
	Converts an executable jar file into a shellscript that has the jar file
	embedded and that checks for a Java runtime environment, then executes
	the jar file.
	Options:
	    -h --help  - Display this help
	    -o outfile - Set the name of the script file to generate.
	                 If - is set as name, stdout is used as output.
	                 Default: Name of the jar with .sh file extension.
	    -t tempdir - Set the directory in which the jar file is extracted
	                 when the generated script is run. This can be overridden
	                 using the -t switch on the script itself.
	                 Default: $tempdir
	    -n name    - Set the name of the application. This is displayed when
	                 the generated script is started with -h or --help.
	                 Default: Empty
	    -m message - Set the message that is displayed when no Java Runtime
	                 is found. Default: $message
	EOF
	exit
}

[ "$1" = "-h" -o "$1" = "--help" -o $# -eq 0 ] && usage

while [ $# -gt 0 ]; do
	case "$1" in
	-h|--help) usage;;
	-o) shift; output="$1";;
	-t) shift; tempdir="$1";;
	-n) shift; name="$1";;
	-m) shift; message="$1";;
	*) [ -e "$1" ] && input="$1" || usage;;
	esac
	shift
done

[ ! -e "$input" ] && usage
[ -z "$output" ] && output="${input%.*}.sh"

IFS='\n' read -r -d '' script <<- EOF
	#!/bin/bash
	if [ "\$1" = "-h" -o "\$1" = "--help" ]; then
		echo "$name"
		echo "Options:"
		echo "-h --help  - Display this help"
		echo "-t tempdir - Set temporary directory for the extraction of temporary"
		echo "             files. Default: $tempdir"
		exit
	fi
	which java 2>&1 >/dev/null || (echo "$message"; exit 1)
	[ "\$1" = "-t" ] && tempdir="\$2" || tempdir="$tempdir"
	file=\$(mktemp --tmpdir=\$tempdir)
	tail -n +16 "\$0" | base64 -d > "\$file"
	java -jar "\$file"
	exit
EOF

if [ "$output" = "-" ]; then
	echo -n "$script"
	base64 "$input"
else
	echo -n "$script" > "$output"
	base64 "$input" >> "$output"
fi

chmod a+x "$output"


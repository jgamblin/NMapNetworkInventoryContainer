#!/bin/bash
##########################################
# 2015 Mike Piekarski
# mike [-at-] automagine [-dot-] com
# Automagine, LLC
# --
# Greppable NMAP to CSV parser
# --
# A simple way to convert one or more gnmap files into a csv
# --
# Distribute, reuse, do whatever you want with this code.
###########################################
#
# Display usage info if someone passes --help, -h or runs with 0 args.
if [[ ${1} == "--help" || ${1} == "-h" || -z ${1} ]]; then
echo -e "Automagine GNMAP to CSV Parser Script.\n"
echo "Usage for $(basename ${0}):"
echo -e "\n\t${0} /path/to/file.gnmap /other/path/to/*.gnmap"
exit 0
fi
#
# Echo out the CSV Header
echo '"IP","Hostname","Port","Protocol","Version"'
#
# Loop through each service starting @ the Ports: section for each host
# There's some pretty dirty assembling of the extended service detail instead
# of struggling with a proper / pefectly fitting Regex for input field separator.
gawk '{
for( X=4; X<NF; X++) {
if ( $X ~ /[0-9]{1,}\/open\// ) {
#
# Check and see if it ends with / or /,
if ( $X !~ /[\/,]$/ ) {
if ( $(X+1) ~ /[\/,]$/ ) {
$X=$X" "$(X+1)
#
# Keep looping through next fields until one ending
# with / or /, is found.
} else if ( $(X+2) ~ /[\/,]$/ ) {
$X=$X" "$(X+1)" "$(X+2)
} else if ( $(X+3) ~ /[\/,]$/ ) {
$X=$X" "$(X+1)" "$(X+2)" "$(X+3)
} else if ( $(X+4) ~ /[\/,]$/ ) {
$X=$X" "$(X+1)" "$(X+2)" "$(X+3)" "$(X+4)
} else if ( $(X+5) ~ /[\/,]$/ ) {
$X=$X" "$(X+1)" "$(X+2)" "$(X+3)" "$(X+4)" "$(X+5)
} else if ( $(X+6) ~ /[\/,]$/ ) {
$X=$X" "$(X+1)" "$(X+2)" "$(X+3)" "$(X+4)" "$(X+5)" "$(X+6)
}
} {
#
# Split up the parts of the NMAP Service shorthand (ex 80/open/tcp//http//Microsoft IIS httpd 8.0/ )
# - Populates the Array P with each section separated by a / character
split($X, P, "/")
#
# Remove Parens from hostnames
gsub(/[\(\)]/,"", $3)
#
# Remove Comma from Service Detail
gsub(/,/,"",$X)
#
# Reassemble all of the data we chopped up and format the print for a clean CSV
#  - Quote everything
#  - Comma separated
#  - Newline terminated
printf("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n", $2, $3, P[1], P[5], P[7])
}
}
}
}' $@ | sort -n | uniq

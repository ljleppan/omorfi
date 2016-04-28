#!/bin/bash
source omorfi-locate.sh
args=$@

function print_version() {
    echo "omorfi-analyse 0.2"
    echo "Copyright (c) 2014 Tommi A Pirinen"
    echo "Licence GPLv3: GNU GPL version 3 <http://gnu.org/licenses/gpl.html>"
    echo "This is free software: you are free to change and redistribute it."
    echo "There is NO WARRANTY, to the extent permitted by law."

}

function print_usage() {
    echo "Usage: $0 [OPTION] [FILENAME...]"
}

function print_help() {
    echo "Analyses running text using omorfi automata and hfst tools"
    echo
    echo "  -h, --help      Print this help dialog"
    echo "  -V, --version   Print version info"
    echo "  -v, --verbose   Print verbosely while processing"
    echo
    echo "If no FILENAMEs are given, input is read from standard input."
    echo "This program uses hfst-apertium-proc and, if found"
    echo "apertium-destxt, otherwise sed"
}


cleanup=cat
function check_cleaner() {
    if type -p apertium-destxt > /dev/null ; then
        cleanup=$(type -p apertium-destxt)
    elif type -p sed > /dev/null ; then
        sedexpr='s/[]@<>^$/\\{}[]/\\\0/g'
        cleanup="sed -e ${sedexpr}"
    fi
    if test x$1 = xverbose ; then
        echo cleaning with $cleanup
    fi
}

function analyse() {
    cat $@ | $cleanup | sed -e 's/\.\[\]//g'| hfst-proc -x "$omorfifile"
}

if test x$1 == x-h -o x$1 == x--help ; then
    print_usage
    print_help
    exit 0
elif test x$1 == x-V -o x$1 == x--version ; then
    print_version
    exit 0
elif test x$1 == x-v -o x$1 == x--verbose ; then
    verbose=verbose
    shift 1
elif test ! -r $1 ; then
    echo "Cannot read from $1"
    print_usage
    exit 1
fi
omorfifile=$(find_omorfi "analyse")
if test -z $omorfifile ; then
    print_usage
    find_help analyse
    exit 1
fi
if test x$1 = xverbose ; then
    echo Using $omorfifile for analysis
fi
check_cleaner $verbose
analyse $@

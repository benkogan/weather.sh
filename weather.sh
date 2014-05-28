#!/usr/bin/env bash

# By Ben Kogan (http://benkogan.com)

VERSION="0.0.1"

## output usage
usage () {
    echo "usage: weather [-chV] [-CF]"
}

## get zipcode
zipcode () {
    echo $(curl --silent "http://ipinfo.io/" | grep -E '(postal|})' \
        | sed -e 's/"postal": "//' -e 's/}//' -e 's/"//' | tr -d '\n  ')
}

## get weather
getweather () {
    local zip=$(zipcode)
    local unit="F"
    local ctail=""

    if [[ "$1" == "-C" ]]; then
        unit="C"
        ctail="&u=c"
    fi

    local weather=$(curl --silent                                        \
        "http://xml.weather.yahoo.com/forecastrss?p=$zip$ctail"          \
        | grep -E "(Current Conditions:|$unit<BR)"                       \
        | sed -e "s/Current Conditions://" -e "s/<br \/>//" -e "s/<b>//" \
        -e "s/<\/b>//" -e "s/$unit<BR \/>/º$unit/" -e                    \
        "s/<description>//" -e "s/<\/description>//"                     \
        | tr -d "\n")

    if [[ "$weather" == "" ]]; then
        echo "Cannot fetch weather"
        exit 1
    else
        echo "$weather"
    fi
}

## use caching
cached () {
    ## time boundaries
    local modold=180 # 3 minutes
    local modnew=5   # 5 seconds
    local currtime=$(date +%s)

    ## temp unit
    local unit="F"
    [[ "$1" == "-C" ]] && unit="C"

    ## cache location setup
    local dir="weather.sh-cache"
    local file="$dir/weather-$VERSION-$unit.log"

    ## go to tmp dir
    cd $([ ! -z $TMPDIR ] && echo $TMPDIR || echo /tmp)

    ## if cache dir doesn't exist, make it
    if [[ ! -d "$dir" ]]; then
        mkdir "$dir"
        error=$?
        if [ ! "$error" -eq 0 ]; then
            echo "mkdir $dir failed"
            exit $error
        fi
    fi

    ## if cache file doesn't exist, make it
    set -o noclobber
    { > $file ; } &> /dev/null
    set +C

    ## set up diff as sec from now since file last modified
    local mod=$(stat -f%m "$file")
    let local diff=($currtime - $mod)

    ## load cached weather
    if [[ $diff -lt $modold && $diff -gt $modnew ]]; then
        local w=$(<$file)
        echo "$w"
        exit $?
    fi

    local w=$(getweather "${@}")
    echo "$w"
    echo "$w" > "$file"
}

## main
weather () {
    local arg="$1"
    shift

    case "${arg}" in

        ## flags
        -V|--version)
            echo "${VERSION}"
            return 0
            ;;

        -h|--help)
            usage
            return 0
            ;;

        -C|--celsius)
            getweather
            return 0
            ;;

        -F|--fahrenheit)
            getweather
            return 0
            ;;

        -c|--cached)
            cached "${@}"
            return 0
            ;;

    esac
    getweather
}

## export or run
if [[ ${BASH_SOURCE[0]} != $0 ]]; then
    export -f weather
else
    weather "${@}"
    exit $?
fi


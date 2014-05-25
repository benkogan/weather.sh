#!/usr/bin/env bash

# By Ben Kogan (http://benkogan.com)
# Usage:
#       weather [-ctv]
#
# [-t]  for tmux -- uses cache file
# [-c]  check in Celcius; default is Fahrenheit

cachedir="$HOME/scripts/.cache"
cache="$HOME/scripts/.cache/weather.log"
time=$(date +%s)
modold=210 # 3 minutes 30 seconds
modmid=180 # 3 minutes
modnew=5   # 5 seconds

# TODO: change ping interval to 1 min or respond to wifi signal?
# TODO: respond to curl failure

# tmux
if [[ "$1" == "-t" ]]; then

    # If .cache dir doesn't exist, make it
    if [[ ! -d "$cachedir" ]]; then
        mkdir "$cachedir"
        touch "$cache"
        error=$?
        if [ ! "$error" -eq 0 ]; then
            echo "mkdir $cachedir failed"
            exit $error
        fi
    fi

    cachemod=$(stat -f%m "$cache") # Mod time of cache in sec since the epoch
    let diff=($time - $cachemod)   # Seconds from now since file was modified

    echo "$diff"

    # First case:  on tmux startup; assumes this is the case if cache file
    #              hasn't been used for longer than modold
    # Second case: cache is newly created; should thus be empty
    if [[ $diff -gt $modold || $diff -lt $modnew ]]; then
        # TODO: maybe this is a bad idea? delays loading twice as long
        echo "loading"

    # Load cached version
    elif [[ $diff -lt $modmid ]]; then
        echo "cache test"
        read weather < $cache
        echo "$weather"
        exit $?
    fi # If diff is between modmid and modold, continues
fi

# Get zipcode
zipcode=$(curl --silent "http://ipinfo.io/" | grep -E '(postal|})' \
    | sed -e 's/"postal": "//' -e 's/}//' -e 's/"//' | tr -d '\n  ')

# Get weather
if [[ "$2" == "-c" || "$1" == "-c" ]]; then
    weather=$(curl --silent \
        "http://xml.weather.yahoo.com/forecastrss?p=$zipcode&u=c" \
        | grep -E '(Current Conditions:|C<BR)' \
        | sed -e 's/Current Conditions://' -e 's/<br \/>//' -e 's/<b>//' \
        -e 's/<\/b>//' -e 's/C<BR \/>/ºC/' -e 's/<description>//' \
        -e 's/<\/description>//' | tr -d '\n')
else
    weather=$(curl --silent \
        "http://xml.weather.yahoo.com/forecastrss?p=$zipcode" \
        | grep -E '(Current Conditions:|F<BR)' \
        | sed -e 's/Current Conditions://' -e 's/<br \/>//' -e 's/<b>//' \
        -e 's/<\/b>//' -e 's/F<BR \/>/°F/' -e 's/<description>//' \
        -e 's/<\/description>//' | tr -d '\n')
fi
echo "$weather"

# tmux: add weather to cache file
if [ "$1" == "-t" ]; then
    echo "$weather" > "$cache"
fi


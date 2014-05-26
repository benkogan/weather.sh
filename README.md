weather.sh
==========

Echo current temperature and weather from Yahoo Weather.

install
-------

[bpkg](https://github.com/bpkg/bpkg)

```sh
$ bpkg install -g benkogan/weather.sh
```

source:

```sh
$ git clone https://github.com/benkogan/weather.sh.git
$ make install -C weather/
```

usage
-----

```
usage: weather [-chtV]

[-c|--celsius]  check in Celcius; default is Fahrenheit
[-h|--help   ]  help and usage
[-t|--tmux   ]  for tmux -- uses cache file
[-V|--verison]  version
```

example
-------

```sh
$ weather -c
Mostly Cloudy, 20 ºC
```

license
-------

MIT


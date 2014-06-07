weather.sh
==========

Echo current temperature and weather from Yahoo Weather.

Install
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

Usage
-----

```
Usage: weather [-chV] [-CF]

Options:

  -c, --cached          use a cache
  -h, --help            output help and usage
  -V, --verison         output program version

  -C, --celsius         check in Celcius
  -F, --fahrenheit      check in Fahrenheit (default behavior)
```

If provided no arguments, weather.sh will check in Fahrenheit. The `-F` flag exists for the sake of symmetry.

The cached option creates a cache file to store the current weather. Within the time boundaries of modnew and modold (set within the script), `weather.sh` will load from the cache instead of from Yahoo Weather. This can be useful in various situations. For example, weather.sh can be used to display the weather in your [tmux][t] status bar (I like to do so using [tmuxline.vim][tl]). By default, tmux's status interval is 15 seconds, and so weather.sh will attempt to update at an unnecessarily-frequent rate. Instead of setting a slow status interval to avoid such waste, enable caching with `-c`!

[t]: http://tmux.sourceforge.net/
[tl]:  https://github.com/edkolev/tmuxline.vim

Example
-------

```sh
$ weather -C
Mostly Cloudy, 20 ºC
```

License
-------

MIT

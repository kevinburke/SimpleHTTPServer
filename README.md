# SimpleHTTPServer

This is a straight port of Python's SimpleHTTPServer for Go.

### Caveats

Note Go exposes directories like `.git` by default. Be sure those
directories aren't present before starting the server. For more see
[golang/go#20759](https://github.com/golang/go/issues/20759).

### Usage

```
$ SimpleHTTPServer 3427
Listening on port [::]:6001
```

That will serve all of the files in the working directory.

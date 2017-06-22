# SimpleHTTPServer

This is a straight port of Python's SimpleHTTPServer for Go.

### Caveats

Note Go exposes directories like `.git` by default. Be sure those
directories aren't present before starting the server. For more see
[golang/go#20759](https://github.com/golang/go/issues/20759).

### Usage

```
$ SimpleHTTPServer 3427
Listening on port [::]:3427
```

That will serve all of the files in the working directory.

### Installation

If you have Go, run

```
go get github.com/kevinburke/SimpleHTTPServer
```

which should install SimpleHTTPServer into your `$GOPATH/bin` directory.

Find your target operating system (darwin, windows, linux) and desired bin
directory, and modify the command below as appropriate:

    curl --silent --location https://github.com/kevinburke/SimpleHTTPServer/releases/download/0.2/SimpleHTTPServer-linux-amd64 > /usr/local/bin/SimpleHTTPServer && chmod 755 /usr/local/bin/SimpleHTTPServer

On Travis, you may want to create `$HOME/bin` and write to that, since
/usr/local/bin isn't writable with their container-based infrastructure.

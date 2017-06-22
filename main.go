// SimpleHTTPServer is a direct port of the Python SimpleHTTPServer
// implementation.
package main

import (
	"flag"
	"fmt"
	"net"
	"net/http"
	"os"
	"strconv"

	"github.com/kevinburke/handlers"
)

const Version = "0.3"

func init() {
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, `usage: SimpleHTTPServer [port]

Start a simple HTTP server that serves the contents of the current directory. 
The default listening port is 8000.
`)
		flag.PrintDefaults()
	}
}

func main() {
	flag.Parse()
	var port string
	envPort := os.Getenv("PORT")
	switch {
	case flag.NArg() == 1:
		port = flag.Arg(0)
		_, err := strconv.Atoi(port)
		if err != nil {
			fmt.Fprintf(os.Stderr, "error parsing %q as port: %v\n", port, err)
			os.Exit(2)
		}
	case envPort != "":
		port = envPort
		_, err := strconv.Atoi(port)
		if err != nil {
			fmt.Fprintf(os.Stderr, "error parsing %q as port: %v\n", port, err)
			os.Exit(2)
		}
	default:
		port = "8000"
	}
	ln, err := net.Listen("tcp", ":"+port)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error listening on port %q: %v\n", port, err)
		os.Exit(2)
	}
	fmt.Fprintf(os.Stderr, "Listening on port %s\n", ln.Addr())
	mux := http.FileServer(http.Dir("."))
	mux = handlers.Server(mux, "SimpleHTTPServer/"+Version)
	mux = handlers.Duration(mux)
	mux = handlers.Log(mux)
	http.Serve(ln, mux)
}

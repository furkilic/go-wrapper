# go-wrapper
The easiest way to integrate Go into your project!


## Documentation

The Go Wrapper is an easy way to ensure a user has
everything necessary to build his GO Application.

_Why might this be necessary?_ Go to date has been very stable for users, is
available on most systems or is easy to procure: but with many of the recent
changes in Go it will be easier for users to have a fully encapsulated build
setup provided by the project. With the Go Wrapper this is very easy to do
and it's a great idea borrowed from Maven and Gradle.

Normally you instruct users to install a specific version of Go, put
it on the PATH and then run the `go` command like the following:

```bash
go build 
```

But now, with a Go Wrapper setup, you can instruct users to run wrapper
scripts:

```bash
./gow build
```

or on Windows

```bash
gow.cmd build
```

A normal Go build will be executed with the one important change that if the
user doesn't have the necessary version of Go specified in
`.go/wrapper/go-wrapper.properties` or the latest version will be downloaded for the user
first, installed and then used.

Subsequent uses of `gow`/`gow.cmd` use the previously downloaded, specific
version as needed.

## Installation

One-line installation in your project directory

```bash
curl -L0 https://github.com/furkilic/go-wrapper/releases/latest/download/go-wrapper.tar.gz | tar -xvz -f -
```
> _For PowerShell_ you'll need to encapsulate the one-line between `cmd /c "..."` 

## Supported Systems

The wrapper should work on various operating systems including

* Linux (numerous versions, tested on Ubuntu and CentOS)
* OSX / macOS
* Windows (various newer versions)
* Solaris (10 and 11)

For all those *nix operating systems, various shells should work including

* sh
* bash
* dash
* zsh

In terms of Go versions itself, the wrapper should work with any Go
version and it defaults to the latest release


## Changes

Please check out the [changelog](./CHANGELOG.md) for more information about our
releases.

## Verbose Mode

The wrapper supports a verbose mode in which it outputs further information. It
is activated by setting the `GOW_VERBOSE` environment variable to `true`.

By default it is off.

## Using a Different Version of Go

You can change its version by setting the `distributionUrl` in
`.go/wrapper/go-wrapper.properties`, e.g.

```bash
distributionUrl=https://dl.google.com/go/go1.13.10.linux-amd64.tar.gz
```
```bash
distributionUrl=https://dl.google.com/go/go1.13.10.windows-amd64.zip
```
> :warning: **Be very careful here to download the correct url for windows and linux** 

## Using Basic Authentication for Distribution Download

To download Go from a location that requires Basic Authentication you have 2
options:

1. Set the environment variables `GOW_USERNAME` and `GOW_PASSWORD`

    or

2. add user and password to the distributionUrl like that:
`distributionUrl=https://username:password@<yourserver>go1.13.10.linux-amd64.tar.gz`


## Using a local installation

If you already have a local installation and your `GOROOT` environment variable points 
to it, Go Wrapper will use it.

## FAQ

#### Should i use `gow` or `gow.cmd`

Only on Windows and the `Command Prompt` or `PowerShell` use `./gow.cmd`

For all other options (_Windows with `GitBash` or `Cygwin`, Linux, MacOs.._) use `./gow`

#### Nothing is happening when I put an older `distributionUrl` in `.go/wrapper/go-wrapper.properties`

First of all ensure that  the `distributionUrl` matches the OS your are working on.

Ensure that there is not an already avalaible `GOROOT` in your Environment Variables

In case there is a previous Installation with `gow`, manually delete `.go/wrapper/tmp` and `.go/wrapper/go`
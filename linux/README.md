# Linux Packages

## Debian Package

How to build:

1. install requirements: `apt install debhelper`
2. `./build.sh`
  - this will download the latest portmaster-start
  - results will be in parent dir
3. copy to dist directory with versioned file name

Note: The resulting debian package is currently no
t being signed. We are still in the process of figuring out the best and most trusted way to do this.

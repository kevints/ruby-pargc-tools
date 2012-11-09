ruby-pargc-tools
================

Support tools for CS194 Parallel Ruby GC

Dependencies
------------

All these scripts expect to run on Linux and were tested on Ubuntu
12.04. You must have `rvm`, `perf`, `dot`, and `gprof2dot.py` on your
`PATH`.  For more useful output install debug symbols as well.

To install dependencies on Ubuntu 12.04 you can run
`scripts/install-ubuntu-12.04.sh` or follow the manual
instructions below.

### perf

On Ubuntu 12.04 you can install `perf` with

    sudo apt-get install linux-tools-common linux-tools-`uname -r | sed 's/-generic//'`

To enable better samples on Linux use

    sudo sysctl -w kernel.kptr_restrict=0

To make these settings persistent add the following lines to
`/etc/sysctl.conf`.

    kernel.kptr_restrict = 0

### rvm

The profiling scripts use [RVM](https://rvm.io) to apply
and remove patches. To install RVM see the [install
documentation](https://rvm.io/rvm/install/) or use

    curl -L https://get.rvm.io | bash -s stable

### GraphViz

On Ubuntu 12.04 use

    sudo apt-get install graphviz

### gprof2dot.py

To install gprof2dot.py follow the instructions on their [download
page](http://code.google.com/p/jrfonseca/wiki/Gprof2Dot#Download)
or use

    mkdir -p ~/bin && \
    curl -o ~/bin/gprof2dot.py http://gprof2dot.jrfonseca.googlecode.com/git/gprof2dot.py && \
    chmod +x ~/bin/gprof2dot.py

### ccache

ccache makes compile speeds tolerable. To install it on Ubuntu 12.04 use

    sudo apt-get install ccache

### debug symbols

To install debug symbols on Ubuntu 12.04 use

    sudo apt-get install libc6-dbg


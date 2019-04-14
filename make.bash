#!/bin/bash

clean() {
    echo "cleaning..."
    dune clean
}

build() {
    echo "building..."
    dune build bin/main.exe
}

run() {
    echo "running..."
    dune exec bin/main.exe -- $@
}

$@

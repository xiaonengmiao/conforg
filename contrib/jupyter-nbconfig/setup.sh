#!/bin/sh

nbconfig_dir="$HOME/.jupyter/nbconfig"
mkdir -p $nbconfig_dir
cp notebook.json $nbconfig_dir

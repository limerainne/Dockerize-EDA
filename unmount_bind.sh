#!/bin/bash

for d in $(ls package)
do
    echo package/$d;
    sudo umount package/$d;
    rmdir package/$d;
done

rmdir package


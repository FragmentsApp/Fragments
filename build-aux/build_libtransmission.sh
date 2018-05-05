#!/bin/bash

cd submodules

echo "Generate libtransmission build files..."
cmake -Blibtransmission -Htransmission -DINSTALL_LIB=ON -DENABLE_DAEMON=OFF -DENABLE_UTILS=OFF -DENABLE_TESTS=OFF -DENABLE_GTK=OFF -DENABLE_QT=OFF -DINSTALL_DOC=OFF

echo "Build libtransmission..."
cd libtransmission
make
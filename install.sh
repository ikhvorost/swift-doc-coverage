#!/bin/bash

git clone https://github.com/ikhvorost/swift-doc-coverage.git
cd swift-doc-coverage
sudo make install

rm -rf ../swift-doc-coverage

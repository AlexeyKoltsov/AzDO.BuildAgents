#! /bin/bash

wget -O azcopy.tar.gz https://aka.ms/downloadazcopy-v10-linux &&\
tar -xvf azcopy.tar.gz -C /usr/local/sbin/ --strip-components 1 &&\
rm azcopy.tar.gz

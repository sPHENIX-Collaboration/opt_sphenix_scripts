#! /bin/bash

# put python 3.6 into the path as python and python3
unset PYTHONPATH

export PATH=/cvmfs/sphenix.sdcc.bnl.gov/gcc-12.1.0/opt/sphenix/core/bin_python-3.6:$PATH

if [[ -z "$PYTHONPATH" ]]
then
  export PYTHONPATH=${ROOTSYS}/lib
  pythonversion=`python3 --version | awk '{print $2}' | awk -F. '{print $1"."$2}'`
  if [[ -d ${OPT_SPHENIX}/lib/python${pythonversion}/site-packages ]]
  then
    export PYTHONPATH=${OPT_SPHENIX}/lib/python${pythonversion}/site-packages:${PYTHONPATH}
  fi
  if [[ -d ${OFFLINE_MAIN}/lib/python${pythonversion}/site-packages ]]
  then
    export PYTHONPATH=${OFFLINE_MAIN}/lib/python${pythonversion}/site-packages:${PYTHONPATH}
  fi
  if [[ -d ${OPT_SPHENIX}/lib64/python${pythonversion}/site-packages ]]
  then
    export PYTHONPATH=${OPT_SPHENIX}/lib64/python${pythonversion}/site-packages:${PYTHONPATH}
  fi
  if [[ -d ${OFFLINE_MAIN}/lib64/python${pythonversion}/site-packages ]]
  then
    export PYTHONPATH=${OFFLINE_MAIN}/lib64/python${pythonversion}/site-packages:${PYTHONPATH}
  fi
# last not least add ./ to run shrek which is installed in the local dir
  export PYTHONPATH=.:${PYTHONPATH}
fi

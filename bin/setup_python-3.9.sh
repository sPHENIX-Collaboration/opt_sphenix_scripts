#! /bin/bash

# put python 3.6 into the path as python
unset PYTHONPATH

export PATH=/cvmfs/sphenix.sdcc.bnl.gov/alma9.2-gcc-14.2.0/opt/sphenix/core/bin_python-3.9:$PATH

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

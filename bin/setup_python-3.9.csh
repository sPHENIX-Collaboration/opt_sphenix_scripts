#! /bin/csh -f -x

# put python 3.9 into the path as python
unsetenv PYTHONPATH

set path = (/cvmfs/sphenix.sdcc.bnl.gov/alma9.2-gcc-14.2.0/opt/sphenix/core/bin_python-3.9 $path)

if (! $?PYTHONPATH) then
  setenv PYTHONPATH ${ROOTSYS}/lib
  set pythonversion = `python3 --version | awk '{print $2}' | awk -F. '{print $1"."$2}'`
  if (-d ${OPT_SPHENIX}/lib/python${pythonversion}/site-packages) then
    setenv PYTHONPATH ${OPT_SPHENIX}/lib/python${pythonversion}/site-packages:${PYTHONPATH}
  endif
  if (-d ${OFFLINE_MAIN}/lib/python${pythonversion}/site-packages) then
    setenv PYTHONPATH ${OFFLINE_MAIN}/lib/python${pythonversion}/site-packages:${PYTHONPATH}
  endif
  if (-d ${OPT_SPHENIX}/lib64/python${pythonversion}/site-packages) then
    setenv PYTHONPATH ${OPT_SPHENIX}/lib64/python${pythonversion}/site-packages:${PYTHONPATH}
  endif
  if (-d ${OFFLINE_MAIN}/lib64/python${pythonversion}/site-packages) then
    setenv PYTHONPATH ${OFFLINE_MAIN}/lib64/python${pythonversion}/site-packages:${PYTHONPATH}
  endif
# last not least add ./ to run shrek which is installed in the local dir
 setenv PYTHONPATH .:${PYTHONPATH}
 unset pythonversion
endif

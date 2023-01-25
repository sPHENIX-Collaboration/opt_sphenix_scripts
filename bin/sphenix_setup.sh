#! /bin/bash

# tell our perl scripts which adjust the opt areas
# according to the cvmfs volume name
# the next line is used by the cvmfs distributions scripts - NEVER CHANGE IT
# to leave this alone: DO_NOT_CHANGE_OPT_SPHENIX

# A general purpose login script for sPHENIX.  The allowed arguments
# are '-a', '-n' and '-h'
# -a indicates that the script should append to the PATH
# and LD_LIBRARY_PATH rather than replace them, and a trailing
# argument used to indicate the version of the installed software to
# use.  
# -n forces the unset of all relevant variables so you can switch from a
# previously initialized setup (different build or PHENIX).
# For instance, "new" (also the default value) will point you to
# software in /cvmfs/sphenix.sdcc.bnl.gov/gcc-8.3/release/release_new/new
# You can be specific if you need to be:
# Specifying "ana.230" will point you to software in
# /cvmfs/sphenix.sdcc.bnl.gov/gcc-8.3/release/release_ana/ana.230
# -h just prints help (as does any other -<letter> flag)

# Usage: source sphenix_setup.sh [-a] [-n] [-h] [version]

# set corefile size to 0 so we do not fill our disks with core files
# use "ulimit -c unlimited" to undo this.
ulimit -c 0

opt_a=0
opt_n=0
opt_v="new"
opt_b="none"

this_script=$BASH_SOURCE
#
# Absolute path to this script, everything is relative to this path
#
this_script=`readlink -f $this_script`

unset force_base

for arg in "$@"
do
    case "$arg" in
    -a)
	opt_a=1
	;;
    -n)
        opt_n=1
	;;
    -b*)
        opt_b=$arg
        # strip the -b from the base installation area
        force_base=`echo $opt_b | awk '{print substr($0,3)}'`
        ;;
    -*)
        echo "usage source sphenix_setup.csh [-a] [-b[base dir]] [-n] [-h] [version]"
        echo "-a: append path and LD_LIBRARY_PATH to existing ones"
        echo "-b: override base directory for installation (default script dir), no space between -b and directory"
        echo "-n: overwrite all environment variables, needed for switching builds"
        echo "version: build version (new, ana, pro, play,... - also with version number e.g. ana.407)"
        exit 0
	;;
    *)
        opt_v=$arg
	;;
    esac
done

# unset compiler settings from gcc 8.3 in case they were set
# they wreak havoc if you leave them when using another compiler
unset FC
unset CC
unset CXX
unset COMPILER_PATH

# if -n unset all relevant environment variables
# also from phenix setup script so we can switch
if [ $opt_n != 0 ]
 then
  unset ${!CERN*}
  unset CALIBRATIONROOT
  unset CONFIG_SITE
  unset CVSROOT
  unset ${!G4*}
  unset GSEARCHPATH
  unset LHAPATH
  unset LHAPDF_DATA_PATH
  unset ODBCINI
  unset OFFLINE_MAIN
  unset ONLINE_MAIN
  unset ${!OPT_*}
  unset PARASOFT
  unset PERL5LIB
  unset PGHOST
  unset PG_PHENIX_DBNAME
  unset PYTHIA8
  unset PYTHONPATH
  unset ROOTSYS
  unset SARTRE_DIR
  unset SIMULATION_MAIN
  unset TSEARCHPATH
  unset XERCESCROOT
  unset XPLOAD_CONFIG
  unset XPLOAD_CONFIG_DIR
  unset XPLOAD_DIR
fi

# set afs sysname to replace @sys so links stay functional even if
# the afs sysname changes in the future
if [[ -f /usr/bin/fs ]]
then
  sysname=`/usr/bin/fs sysname | sed "s/^.*'\(.*\)'.*/\1/"`
else
  sysname=x8664_sl7
fi
# turn off opengl direct rendering bc problems for nx
# that problem seems to have been fixed, leave this in here since it
# took a long time to figure this one out
# export LIBGL_ALWAYS_INDIRECT=1

# turn off gtk warning about accessibility bus
export NO_AT_BRIDGE=1

# speed up DCache
export DCACHE_RAHEAD
export DCACHE_RA_BUFFER=2097152

# store previous paths in case we want to prepend them (with -a)
export ORIG_PATH=$PATH

if [ ! -z "$LD_LIBRARY_PATH" ] 
then
    export ORIG_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
else
    unset ORIG_LD_LIBRARY_PATH
fi

if [  ! -z "$MANPATH" ] 
then
    export ORIG_MANPATH=$MANPATH
    unset MANPATH
else
    unset ORIG_MANPATH
fi

# Absolute path of this script
scriptpath=`dirname "$this_script"`
# extract base path (everything before /opt/sphenix or /opt/fun4all)
if [[ $scriptpath == *"/opt/sphenix"* ]]
then
  optsphenixindex=`echo $scriptpath | awk '{print index($0,"/opt/sphenix")}'`
else
  optsphenixindex=`echo $scriptpath | awk '{print index($0,"/opt/fun4all")}'`
fi

optbasepath=`echo $scriptpath | awk '{print substr($0,0,'$optsphenixindex'-1)}'`

# just in case the above screws up, give it the default in rcf
if [ ! -d $optbasepath ]
then
  optbasepath="/opt/sphenix"
fi
if [[ -z "$force_base" && -d $force_base ]]
then
  optbasepath=$force_base
fi

if [[ -z "$OPT_SPHENIX" ]]
then
  if [[ -d ${optbasepath}/opt/sphenix/core ]]
  then
    export OPT_SPHENIX=${optbasepath}/opt/sphenix/core
  fi
  if [[ -d ${optbasepath}/opt/fun4all/core ]]
  then
    export OPT_SPHENIX=${optbasepath}/opt/fun4all/core
  fi
fi

if [[ -z "$OPT_FUN4ALL" ]]
then
  export OPT_FUN4ALL=$OPT_SPHENIX
fi

if [[ -z "$OPT_UTILS" ]]
then
  if [[ -d ${optbasepath}/opt/sphenix/utils ]]
  then
    export OPT_UTILS=${optbasepath}/opt/sphenix/utils
  fi
  if [[ -d ${optbasepath}/opt/fun4all/utils ]]
  then
    export OPT_UTILS=${optbasepath}/opt/fun4all/utils
  fi
fi

# set site wide compiler options (no rpath hardcoding)
if [[ -z "$CONFIG_SITE" ]]
then
  if [[ $opt_v = "debug" && -f ${OPT_SPHENIX}/etc/config_debug.site ]]
  then
    export CONFIG_SITE=${OPT_SPHENIX}/etc/config_debug.site
  else
    if [ -f ${OPT_SPHENIX}/etc/config.site ]
    then
      export CONFIG_SITE=${OPT_SPHENIX}/etc/config.site
    fi
  fi
fi
# Perl
if [ -z "$PERL5LIB" ]
then
   if [ -d ${OPT_SPHENIX}/share/perl5 ]
   then
     export PERL5LIB=${OPT_SPHENIX}/lib64/perl5:${OPT_SPHENIX}/share/perl5
   fi
   if [ -d ${OPT_UTILS}/share/perl5 ] 
   then
     if [ -z "$PERL5LIB" ]
     then
       export PERL5LIB=${OPT_UTILS}/lib64/perl5:${OPT_UTILS}/share/perl5
     else
       export PERL5LIB=${PERL5LIB}:${OPT_UTILS}/lib64/perl5:${OPT_UTILS}/share/perl5
     fi
   fi
fi

if [[ -z "$LHAPATH" && -d ${OPT_SPHENIX}/lhapdf-5.9.1/share/lhapdf/PDFsets ]] 
then
  export LHAPATH=${OPT_SPHENIX}/lhapdf-5.9.1/share/lhapdf/PDFsets
fi

if [ -z "$OFFLINE_MAIN" ]
then
  if [ ! -d ${optbasepath}/release/$opt_v ]
  then
    opt_v="new"
  fi
  export OFFLINE_MAIN=${optbasepath}/release/$opt_v
fi

if [[ $OFFLINE_MAIN = *insure* ]]
then
  export G_SLICE=always-malloc
else
  if [ ! -z "$G_SLICE" ]
  then
    unset G_SLICE
  fi
fi


# Normalize OFFLINE_MAIN 
if [ -d $OFFLINE_MAIN ] 
then
  here=`pwd`
  cd $OFFLINE_MAIN
  export OFFLINE_MAIN=`pwd -P`
  cd $here
fi

# set ONLINE_MAIN to OFFLINE_MAIN if not set to an
# online environment in our counting house
if [ -z "$ONLINE_MAIN" ]
then
  export ONLINE_MAIN=$OFFLINE_MAIN
fi


# set path to calibration files
if [[ -z "$CALIBRATIONROOT" && -d $OFFLINE_MAIN/share/calibrations ]]
then
  export CALIBRATIONROOT=$OFFLINE_MAIN/share/calibrations
fi

# ROOT
if [ -z "$ROOTSYS" ]
then
  if [ -d $OFFLINE_MAIN/root ] 
  then
    export ROOTSYS=$OFFLINE_MAIN/root
  else    
    export ROOTSYS=$OPT_SPHENIX/root
  fi
  here=`pwd`
  cd $ROOTSYS
  export ROOTSYS=`pwd -P`
  cd $here
fi

if [ -f $ROOTSYS/bin/root-config ]
then
  rootlibdir_tmp=`$ROOTSYS/bin/root-config --libdir`
  if [ -d $rootlibdir_tmp ] 
  then
    here=`pwd`
    cd $rootlibdir_tmp
    there=`pwd -P`
    rootlibdir=`echo $there | sed "s/@sys/$sysname/g"`
    cd $here
  fi
  rootbindir_tmp=`$ROOTSYS/bin/root-config --bindir`
  if [ -d $rootbindir_tmp ] 
  then
    here=`pwd`
    cd $rootbindir_tmp
    there=`pwd -P`
    rootbindir=`echo $there | sed "s/@sys/$sysname/g"`
    cd $here
  fi
fi

#LHAPDF 6
if [[ -z $LHAPDF_DATA_PATH ]]
then
  if [[ -d ${OFFLINE_MAIN}/share/LHAPDF ]]
  then
    export LHAPDF_DATA_PATH=${OFFLINE_MAIN}/share/LHAPDF
  else
    if [[ -d ${OPT_SPHENIX}/LHAPDF/share/LHAPDF ]]
    then
      export LHAPDF_DATA_PATH=${OPT_SPHENIX}/LHAPDF/share/LHAPDF
    fi
  fi
fi

if [[ -z "$PYTHONPATH" ]]
then
  export PYTHONPATH=${ROOTSYS}/lib
  if [[ -d ${OPT_SPHENIX}/pythonpackages/lib/python3.8/site-packages ]]
  then
    export PYTHONPATH=${OPT_SPHENIX}/pythonpackages/lib/python3.8/site-packages:${PYTHONPATH}
  fi
  if [[ -d ${OFFLINE_MAIN}/lib/python3.8/site-packages ]]
  then
    export PYTHONPATH=${OFFLINE_MAIN}/lib/python3.8/site-packages:${PYTHONPATH}
  fi
fi

# Add Geant4
if [ -z "$G4_MAIN" ] 
then
    if [ -d $OFFLINE_MAIN/geant4 ]
    then
      export G4_MAIN=${OFFLINE_MAIN}/geant4
    else
      export G4_MAIN=${OPT_SPHENIX}/geant4
    fi
fi

if [ -d $G4_MAIN ]
then
# normalize G4_MAIN to /opt/sphenix/core/geant4.Version
    here=`pwd`
    cd $G4_MAIN
    export G4_MAIN=`pwd -P`
    cd $here
# this is for later possible use, extract the main version number
    g4basedir=`basename $G4_MAIN`
    g4mainversion=`echo $g4basedir | awk -F. '{print $2}'`
    if [ -f ${G4_MAIN}/bin/geant4.sh ] 
    then
      source ${G4_MAIN}/bin/geant4.sh
    fi
fi

# Xerces is installed with G4 (G4 depends on it)
if [[ -z "$XERCESCROOT" ]]
then
  export XERCESCROOT=${G4_MAIN}
fi

if [[ -z "$XPLOAD_CONFIG_DIR" ]]
then
  export XPLOAD_CONFIG_DIR=${OPT_SPHENIX}/etc
fi


#Pythia8
if [[ -z "$PYTHIA8" && -d $OFFLINE_MAIN/share/Pythia8 ]]
then
  export PYTHIA8=$OFFLINE_MAIN/share/Pythia8
fi

#Sartre
if [[ -z "$SARTRE_DIR" && -d $OFFLINE_MAIN/sartre ]]
then
  export SARTRE_DIR=$OFFLINE_MAIN/sartre
fi

# Set up Insure++, if we have it
if [ -z  "$PARASOFT" ] 
then
  export PARASOFT=/afs/rhic.bnl.gov/app/insure-7.5.5
fi

# Coverity
if [ -z "$COVERITY_ROOT" ]
then
  export COVERITY_ROOT=/afs/rhic.bnl.gov/app/coverity-2021.12
fi

# point to scratch DB
if [ -z "$PGHOST" ]
then
  export PGHOST=sphnxdbmaster
  export PGUSER=phnxrc
fi

# File catalog search path
if [ -z "$GSEARCHPATH" ]
then
  export GSEARCHPATH=.:PG:LUSTRE:XROOTD:MINIO
fi

path=(/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin)
# we need to use the new PATH here, otherwise when switching between
# cvmfs volumes the PATH from the last one creeps in here
manpath=`env PATH=$path /usr/bin/man --path`

ldpath=/usr/local/lib64:/usr/lib64

#loop over all bin dirs and prepend to path
for bindir in ${COVERITY_ROOT}/bin \
              ${PARASOFT}/bin \
              ${G4_MAIN}/bin \
              ${rootbindir} \
              ${OPT_SPHENIX}/bin \
              ${OPT_UTILS}/bin \
              ${ONLINE_MAIN}/bin \
              ${OFFLINE_MAIN}/bin
do
  if [ -d $bindir ]
  then
    path=$bindir:$path
  fi
done

#loop over all lib dirs and prepend to ldpath
for libdir in ${PARASOFT}/lib \
                ${OPT_SPHENIX}/lhapdf-5.9.1/lib \
                ${G4_MAIN}/lib \
                ${G4_MAIN}/lib64 \
                ${rootlibdir} \
                ${OPT_SPHENIX}/lib \
                ${OPT_SPHENIX}/lib64 \
                ${OPT_UTILS}/lib \
                ${OPT_UTILS}/lib64 \
                ${ONLINE_MAIN}/lib \
                ${ONLINE_MAIN}/lib64 \
                ${OFFLINE_MAIN}/lib \
                ${OFFLINE_MAIN}/lib64
do
  if [ -d $libdir ]
  then
    ldpath=$libdir:$ldpath
  fi
done
# loop over all man dirs and prepend to manpath
for mandir in ${ROOTSYS}/man \
              ${OPT_SPHENIX}/man \
              ${OPT_SPHENIX}/share/man \
              ${OPT_UTILS}/man \
              ${OPT_UTILS}/share/man \
              ${OFFLINE_MAIN}/share/man
do
  if [ -d $mandir ]
  then
    manpath=$mandir:$manpath
  fi
done





# finally prepend . to path/ldpath

path=.:$path
ldpath=.:$ldpath

#set paths
PATH=${path}
LD_LIBRARY_PATH=${ldpath}
MANPATH=$manpath

# in case we want to append these paths opt_a=1
if [ $opt_a != 0 ] 
then
    export PATH=${ORIG_PATH}:${PATH}
    if [ ! -z "$ORIG_LD_LIBRARY_PATH" ] 
    then
	export LD_LIBRARY_PATH=$ORIG_LD_LIBRARY_PATH:${LD_LIBRARY_PATH}
    fi
    if [ ! -z "$MANPATH" ]
    then
	export MANPATH=${ORIG_MANPATH}:${MANPATH}
    fi
fi

#replace @sys by afs sysname (to strip duplicate entries with /@sys/ and /x86_64_sl7/)
PATH=`echo $PATH | sed "s/@sys/$sysname/g"`
LD_LIBRARY_PATH=`echo $LD_LIBRARY_PATH | sed "s/@sys/$sysname/g"`
MANPATH=`echo $MANPATH | sed "s/@sys/$sysname/g"`

# strip duplicates in paths
PATH=`echo -n $PATH | awk -v RS=: -v ORS=: '!arr[$0]++'` 
LD_LIBRARY_PATH=`echo -n $LD_LIBRARY_PATH | awk -v RS=: -v ORS=: '!arr[$0]++'`
MANPATH=`echo -n $MANPATH | awk -v RS=: -v ORS=: '!arr[$0]++'`
# the above leaves a colon at the end of the strings, so strip the last character
PATH=`echo -n $PATH | sed 's/.$//'`
LD_LIBRARY_PATH=`echo -n $LD_LIBRARY_PATH | sed 's/.$//'`
MANPATH=`echo -n $MANPATH | sed 's/.$//'`

unset ldpath
unset path
unset manpath

export PATH
export LD_LIBRARY_PATH
export MANPATH
source $OPT_SPHENIX/bin/setup_root6_include_path.sh $OFFLINE_MAIN

# setup gcc 8.301 (copied from /cvmfs/sft.cern.ch/lcg/releases)
if [[ -f ${OPT_SPHENIX}/gcc/8.3.0.1-0a5ad/x86_64-centos7/setup.sh ]]
then
  source ${OPT_SPHENIX}/gcc/8.3.0.1-0a5ad/x86_64-centos7/setup.sh
fi

# check if the s3 read only access is setup, otherwise add it
if [ ! -d $HOME/.mcs3 ] ||  ! grep -q eicS3read "$HOME/.mcs3/config.json" ; then
   mcs3 config host add eicS3 https://dtn01.sdcc.bnl.gov:9000/ eicS3read eicS3read &> /dev/null
fi

# source local setups
if [[ -f /sphenix/user/local_setup_scripts/bin/mc_host_sphenixS3.sh ]]
then
  source /sphenix/user/local_setup_scripts/bin/mc_host_sphenixS3.sh
fi

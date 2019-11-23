#! /bin/bash

# A general purpose login script for sPHENIX.  The allowed arguments
# are '-a' and '-n'
# -a indicates that the script should append to the PATH
# and LD_LIBRARY_PATH rather than replace them, and a trailing
# argument used to indicate the version of the installed software to
# use.  
# -n forces the unset of all relevant variables so you can switch between
# 32 bit and 64 bit setups
# For instance, "new" (also the default value) will point you to
# software in /afs/rhic.bnl.gov/phenix/software/new.  You can be specific if
# you need to be.  Specifying "pro.5" will point you to software in
# /afs/rhic.bnl.gov/phenix/software/pro.5

# Usage: source sphenix_setup.sh [-a] [-n] [-h] [version]

# set corefile size to 0 so we do not fill our disks with core files
# use "ulimit -c unlimited" to undo this.
ulimit -c 0

opt_a=0
opt_n=0
opt_v="new"

for arg in "$@"
do
    case "$arg" in
    -a)
	opt_a=1
	;;
    -n)
        opt_n=1
	;;
    -*)
        echo "usage source sphenix_setup.csh [-a] [-n] [-h] [version]"
        echo "-a: append path and LD_LIBRARY_PATH to existing ones"
        echo "-n: overwrite all environment variables, needed for switching builds"
        echo "version: build version (new, ana, pro, play,... - also with version number e.g. ana.407)"
        exit 0
	;;
    *)
        opt_v=$arg
	;;
    esac
done


# if -n unset all relevant environment variables
# also from phenix setup script so we can switch
if [ $opt_n != 0 ]
 then
  unset ${!CERN*}
  unset CALIBRATIONROOT
  unset CONFIG_SITE
  unset CVSROOT
  unset ${!G4*}
  unset LHAPATH
  unset ODBCINI
  unset OFFLINE_MAIN
  unset ONLINE_MAIN
  unset ${!OPT_*}
  unset PARASOFT
  unset PERL5LIB
  unset PGHOST
  unset PYTHIA8
  unset PYTHONPATH
  unset ROOTSYS
  unset SARTRE_DIR
  unset SIMULATION_MAIN
  unset TSEARCHPATH
  unset XERCESCROOT
fi

# set afs sysname to replace @sys so links stay functional even if
# the afs sysname changes in the future
sysname=`/usr/bin/fs sysname | sed "s/^.*'\(.*\)'.*/\1/"`

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

if [[ -z "$OPT_SPHENIX" && -d /opt/sphenix/core ]]
then
  export OPT_SPHENIX=/opt/sphenix/core
fi

if [[ -z "$OPT_UTILS" && -d /opt/sphenix/utils ]]
then
    export OPT_UTILS=/opt/sphenix/utils
fi

# set site wide compiler options (no rpath hardcoding)
if [[ -z "$CONFIG_SITE" ]]
then
  if [[ $opt_v = "debug" && -f ${OPT_SPHENIX}/etc/config_debug.site ]]
  then
    export CONFIG_SITE=${OPT_SPHENIX}/etc/config_debug.site
  else
    if [ -f ${OPT_SPHENIX}/etc/config_debug.site ]
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
  if [ ! -d /cvmfs/sphenix.sdcc.bnl.gov/x8664_sl7/release/$opt_v ]
  then
    opt_v="new"
  fi
  export OFFLINE_MAIN=/cvmfs/sphenix.sdcc.bnl.gov/x8664_sl7/release/$opt_v
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

if [[ -z "$PYTHONPATH" && -d ${OPT_SPHENIX}/pythonpackages/lib/python3.8/site-packages ]]
then
  export PYTHONPATH=${OPT_SPHENIX}/pythonpackages/lib/python3.8/site-packages:${ROOTSYS}/lib
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

    if [ -d ${G4_MAIN}/bin ]
    then
	path=${G4_MAIN}/bin:$path
    fi
    if [ -d ${G4_MAIN}/lib64 ] 
    then
	ldpath=${G4_MAIN}/lib64:$ldpath
    fi
fi
if [[ -z "$XERCESCROOT" ]]
then
  export XERCESCROOT=${G4_MAIN}
fi


if [[ -z "$XERCESCROOT" ]]
then
  export XERCESCROOT=${G4_MAIN}
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
  export PARASOFT=/afs/rhic.bnl.gov/app/insure-7.5.3
fi

# Coverity
if [ -z "$COVERITY_ROOT" ]
then
  export COVERITY_ROOT=/afs/rhic.bnl.gov/app/coverity-2019.03
fi

if [ -z "$PGHOST" ]
then
  export PGHOST=phnxdbrcf2
  export PGUSER=phnxrc
  export PG_PHENIX_DBNAME=Phenix_phnxdbrcf2_C
fi

path=(/usr/lib64/qt-3.3/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin)
manpath=`/usr/bin/man --path`

ldpath=/usr/local/lib64:/usr/lib64

#loop over all bin dirs and prepend to path
for bindir in $COVERITY_ROOT/bin \
              ${PARASOFT}/bin \
              $G4_MAIN/bin \
              $rootbindir \
              $OPT_SPHENIX/bin \
              $OPT_UTILS/bin \
              $ONLINE_MAIN/bin \
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
                ${G4_MAIN}/lib64 \
                ${rootlibdir} \
                $OPT_SPHENIX/lib \
                $OPT_UTILS/lib \
                ${ONLINE_MAIN}/lib \
                ${OFFLINE_MAIN}/lib
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

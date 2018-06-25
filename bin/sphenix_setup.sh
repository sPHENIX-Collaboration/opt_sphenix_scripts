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
  unset PYTHIA8
  unset ROOTSYS
  unset SIMULATION_MAIN
  unset TSEARCHPATH
fi

# set afs sysname to replace @sys so links stay functional even if
# the afs sysname changes in the future
sysname=`/usr/bin/fs sysname | sed "s/^.*'\(.*\)'.*/\1/"`

# turn off opengl direct rendering bc problems for nx
export LIBGL_ALWAYS_INDIRECT=1

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

# initialize path
path=(/usr/lib64/qt-3.3/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin)

if [[ -z "$OPT_SPHENIX" && -d /opt/sphenix/core ]]
then
  export OPT_SPHENIX=/opt/sphenix/core
fi

if [[ -z "$OPT_UTILS" && -d /opt/sphenix/utils ]]
then
    export OPT_UTILS=/opt/sphenix/utils
fi

# set site wide compiler options (no rpath hardcoding)
if [[ -z "$CONFIG_SITE" && -f ${OPT_SPHENIX}/etc/config.site ]]
then
  export CONFIG_SITE=${OPT_SPHENIX}/etc/config.site
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

if [[ -z "$XERCESCROOT" && -d /opt/sphenix/core ]]
then
  export XERCESCROOT=/opt/sphenix/core
fi

if [[ -z "$LHAPATH" && -d ${OPT_SPHENIX}/lhapdf-5.9.1/share/lhapdf/PDFsets ]] 
then
  export LHAPATH=${OPT_SPHENIX}/lhapdf-5.9.1/share/lhapdf/PDFsets
fi

if [ -z "$OFFLINE_MAIN" ]
then
  if [ ! -d /afs/rhic.bnl.gov/sphenix/new/../$opt_v ]
  then
    opt_v="new"
  fi
  export OFFLINE_MAIN=/afs/rhic.bnl.gov/sphenix/new/../$opt_v/
fi
# Normalize OFFLINE_MAIN 
if [ -d $OFFLINE_MAIN ] 
then
  here=`pwd`
  cd $OFFLINE_MAIN
  there=`pwd`
  export OFFLINE_MAIN=`echo $there | sed "s/@sys/$sysname/g"`
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
fi

#Pythia8
if [[ -z PYTHIA8 && -d $OFFLINE_MAIN/share/Pythia8 ]]
then
  export PYTHIA8=$OFFLINE_MAIN/share/Pythia8
fi

if [ -z "$PGHOST" ]
then
  export PGHOST=phnxdbrcf7
  export PGUSER=phnxrc
#  export PG_PHENIX_DBNAME=Phenix_phnxdbrcf7_C
fi

# Initialize PATH and LD_LIBRARY_PATH to original system 
# path and MANPATH

manpath=`/usr/bin/man --path`

if [ -d $OPT_SPHENIX/bin ] 
then
  path=($OPT_SPHENIX/bin:$path)
fi

if [ -d $OPT_SPHENIX/lib ] 
then
  ldpath=${OPT_SPHENIX}/lib:${ldpath}
fi

if [ -d $OPT_UTILS/bin ]
then
  path=($OPT_UTILS/bin:$path)
fi
if [ -d $OPT_UTILS/lib ] 
then
  ldpath=${OPT_UTILS}/lib:${ldpath}
fi


if [ -d ${OPT_SPHENIX}/man ]
then
    manpath=${manpath}:${OPT_SPHENIX}/man
fi

if [ -d ${OPT_SPHENIX}/share/man ] 
then
    manpath=${OPT_SPHENIX}/share/man:$manpath
fi

#LHAPDF
if [ -d ${OPT_SPHENIX}/lhapdf-5.9.1/lib ] 
then
  ldpath=${OPT_SPHENIX}/lhapdf-5.9.1/lib:${ldpath}
fi

for d in ${ONLINE_MAIN}/bin $OFFLINE_MAIN/bin $ROOTSYS/bin
do
  if [ -d $d ]
  then
    path=$d:$path
  fi
done

if [ -f $ROOTSYS/bin/root-config ]
then
  rootlibdir_tmp=`$ROOTSYS/bin/root-config --libdir`
  if [ -d $rootlibdir_tmp ] 
  then
    here=`pwd`
    cd $rootlibdir_tmp
    there=`pwd`
    rootlibdir=`echo $there | sed "s/@sys/$sysname/g"`
    cd $here
  fi
fi

for d in ${ONLINE_MAIN}/lib ${OFFLINE_MAIN}/lib ${rootlibdir}
do
  if [ -d $d ]
  then
   ldpath=${d}:${ldpath}
  fi
done

# Set up Insure++, if we have it
if [ -z  $PARASOFT ] 
then
  export PARASOFT=/afs/rhic.bnl.gov/app/insure-7.5.0
fi

if [ -d $PARASOFT/bin ] 
then
  path=$path:${PARASOFT}/bin
  ldpath=${ldpath}:${PARASOFT}/lib
fi

# set up coverity
if [ -d /afs/rhic.bnl.gov/app/coverity-8.7.1/bin ]
then
  path=$path:/afs/rhic.bnl.gov/app/coverity-8.7.1/bin
fi

# Add Geant4
if [ -z $G4_MAIN ] 
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
# normalize G4_MAIN to /opt/phenix/geant4.Version
    here=`pwd`
    cd $G4_MAIN
    there=`pwd`
    export G4_MAIN=`echo $there | sed "s/@sys/$sysname/g"`
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

# add . to paths
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
    if [ ! -z $ORIG_LD_LIBRARY_PATH ] 
    then
	export LD_LIBRARY_PATH=$ORIG_LD_LIBRARY_PATH:${LD_LIBRARY_PATH}
    fi
    if [ ! -z $MANPATH ]
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

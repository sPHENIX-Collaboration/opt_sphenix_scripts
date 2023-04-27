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
  unset NOPAYLOADCLIENT_CONF
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
if [[ $scriptpath == *"/online/Debian"* ]]
then
  optsphenixindex=`echo $scriptpath | awk '{print index($0,"/online/Debian")}'`
fi

optbasepath=`echo $scriptpath | awk '{print substr($0,0,'$optsphenixindex'-1)}'`

# just in case the above screws up, give it the default in rcf
if [ ! -d $optbasepath ]
then
  optbasepath="/online/Debian"
fi
if [[ -z "$force_base" && -d $force_base ]]
then
  optbasepath=$force_base
fi

if [[ -z "$OPT_SPHENIX" ]]
then
  if [[ -d ${optbasepath}/online/Debian ]]
  then
    export OPT_SPHENIX=${optbasepath}/online/Debian
  fi
fi

# set site wide compiler options (no rpath hardcoding)
if [[ -z "$CONFIG_SITE" ]]
then
  if [[ $opt_v = "debug"* && -f ${OPT_SPHENIX}/etc/config_debug.site ]]
  then
    export CONFIG_SITE=${OPT_SPHENIX}/etc/config_debug.site
  else
    if [ -f ${OPT_SPHENIX}/etc/config.site ]
    then
      export CONFIG_SITE=${OPT_SPHENIX}/etc/config.site
    fi
  fi
fi

if [ -z "$ONLINE_MAIN" ]
then
  export ONLINE_MAIN=${optbasepath}/current
fi


if [ -d $ONLINE_MAIN ] 
then
  here=`pwd`
  cd $ONLINE_MAIN
  export ONLINE_MAIN=`pwd -P`
  cd $here
fi


# ROOT
if [ -z "$ROOTSYS" ]
then
  if [ -d $OPT_SPHENIX/root ] 
  then
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

path=(/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin)
# we need to use the new PATH here, otherwise when switching between
# cvmfs volumes the PATH from the last one creeps in here
manpath=`env PATH=$path /usr/bin/man --path`

ldpath=/usr/local/lib64:/usr/lib64

#loop over all bin dirs and prepend to path
for bindir in ${ONLINE_MAIN}/bin \
              ${OPT_SPHENIX}/bin \
              ${rootbindir}
do
  if [ -d $bindir ]
  then
    path=$bindir:$path
  fi
done

#loop over all lib dirs and prepend to ldpath
for libdir in   ${ONLINE_MAIN}/lib \
                ${ONLINE_MAIN}/lib64 \
                ${OPT_SPHENIX}/lib \
                ${OPT_SPHENIX}/lib64 \
                ${rootlibdir}
do
  if [ -d $libdir ]
  then
    ldpath=$libdir:$ldpath
  fi
done
# loop over all man dirs and prepend to manpath
for mandir in ${ONLINE_MAIN}/share/man \
              ${OPT_SPHENIX}/man \
              ${OPT_SPHENIX}/share/man \
              ${ROOTSYS}/man
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
#source $OPT_SPHENIX/bin/setup_root6_include_path.sh $ONLINE_MAIN

if [[ -f ${OPT_SPHENIX}/gcc/8.3.0.1-0a5ad/x86_64-centos7/setup.sh ]]
then
  source ${OPT_SPHENIX}/gcc/8.3.0.1-0a5ad/x86_64-centos7/setup.sh
fi

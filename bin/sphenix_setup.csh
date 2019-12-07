#! /bin/csh -f -x

# A general purpose login script for sPHENIX.  The allowed arguments
# are '-a', '-b[basedir]' and '-n'
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

# Usage: source phenix_setup.csh [-a] [-b[basedir]] [-n] [-h] [version]

# use "limit coredumpsize unlimited" to undo this.
limit coredumpsize 0

# find out if we are sourced or not, sadly the extraction of the
# name and full path of this script depend on this
# just for additional complications the cron job just passes /bin/tcsh
# and so far I have not found a way to get to the location of this script
# in a cron job. For cron jobs we need to set the 
# -b[basedir]
set sourced=($_)
if ("$0" == "-tcsh") then
set this_script=$sourced[2]
else
set this_script="$0"
endif

#
# Absolute path to this script, everything is relative to this path
#
set this_script=`readlink -f $this_script`

set opt_a = 0
set opt_n = 0
set opt_v = "new"
set opt_b = "none"

foreach arg ($*)
    switch ($arg)
    case "-a":
	set opt_a = 1
	breaksw
    case "-n":
        set opt_n = 1
	breaksw
    case "-b*":
        set opt_b =  $arg
	breaksw
    case "-*":
        echo "usage source sphenix_setup.csh [-a] [-b[base dir]] [-n] [-h] [version]"
        echo "-a: append path and LD_LIBRARY_PATH to existing ones"
        echo "-b: override base directory for installation (default script dir), no space between -b and directory"
        echo "-n: overwrite all environment variables, needed for switching builds"
        echo "version: build version (new, ana, pro, play,... - also with version number e.g. ana.407)"
        exit(0)
	breaksw
    case "*":
        set opt_v = $arg
	breaksw
    endsw
end
# strip the -b from the base installation area
set force_base=`echo $opt_b | awk '{print substr($0,3)}'`

# STARs environment contains an alias for pwd which
# throws a monkey wrench into pwd -P
unalias pwd

# if -n unset all relevant environment variables
# also from phenix setup script so we can switch
if ($opt_n) then
  unsetenv CERN*
  unsetenv CALIBRATIONROOT
  unsetenv CONFIG_SITE
  unsetenv COVERITY_ROOT
  unsetenv CVSROOT
  unsetenv G4*
  unsetenv LHAPATH
  unsetenv MANPATH
  unsetenv ODBCINI
  unsetenv OFFLINE_MAIN
  unsetenv ONLINE_MAIN
  unsetenv OPT_*
  unsetenv PARASOFT
  unsetenv PERL5LIB
  unsetenv PGHOST
  unsetenv PYTHIA8
  unsetenv PYTHONPATH
  unsetenv ROOTSYS
  unsetenv SARTRE_DIR
  unsetenv SIMULATION_MAIN
  unsetenv TSEARCHPATH
  unsetenv XERCESCROOT
endif

# we do not use afs anymore, I leave this in place in case
# we need to use it in the future
# set afs sysname to replace @sys so links stay functional even if
# the afs sysname changes in the future
set sysname=`/usr/bin/fs sysname | sed "s/^.*'\(.*\)'.*/\1/"`

# turn off opengl direct rendering bc problems for nx
# that problem seems to have been fixed, leave this in here since it
# took a long time to figure this one out
#setenv LIBGL_ALWAYS_INDIRECT 1

# turn off gtk warning about accessibility bus
setenv NO_AT_BRIDGE 1

# speed up DCache
setenv DCACHE_RAHEAD
setenv DCACHE_RA_BUFFER 2097152


# Make copies of PATH, LD_LIBRARY_PATH and MANPATH as they were
setenv ORIG_PATH ${PATH}
if ($?LD_LIBRARY_PATH) then
    setenv ORIG_LD_LIBRARY_PATH ${LD_LIBRARY_PATH}
else
    unsetenv ORIG_LD_LIBRARY_PATH
endif
if ($?MANPATH) then
    setenv ORIG_MANPATH ${MANPATH}
    unsetenv MANPATH
else
    unsetenv ORIG_MANPATH
endif

# Absolute path of this script
set scriptpath=`dirname "$this_script"`
# extract base path (everything before /opt/sphenix)
set optsphenixindex=`echo $scriptpath | awk '{print index($0,"/opt/sphenix")}'`
set optbasepath=`echo $scriptpath | awk '{print substr($0,0,'$optsphenixindex'-1)}'`

# just in case the above screws up, give it the default in rcf
# empty string defaults to /opt/sphenix
if ("$optbasepath" != "") then
  if (! -d $optbasepath) then
    set optbasepath=""
  endif
endif
if (-d $force_base) then
  set optbasepath=$force_base
endif

if (! $?OPT_SPHENIX) then
  setenv OPT_SPHENIX ${optbasepath}/opt/sphenix/core
endif

if (! $?OPT_UTILS) then
  setenv OPT_UTILS ${optbasepath}/opt/sphenix/utils
endif

# set site wide compiler options (no rpath hardcoding)
if (! $?CONFIG_SITE) then
  if ($opt_v =~ "debug" ) then
    if (-f ${OPT_SPHENIX}/etc/config_debug.site) then
      setenv CONFIG_SITE ${OPT_SPHENIX}/etc/config_debug.site
    endif
  else
    if (-f ${OPT_SPHENIX}/etc/config.site) then
      setenv CONFIG_SITE ${OPT_SPHENIX}/etc/config.site
    endif
  endif
endif
# Perl
if (! $?PERL5LIB) then
   if (-d ${OPT_SPHENIX}/share/perl5) then
     setenv PERL5LIB ${OPT_SPHENIX}/lib64/perl5:${OPT_SPHENIX}/share/perl5
   endif
   if (-d ${OPT_UTILS}/share/perl5) then
     if (! $?PERL5LIB) then
       setenv PERL5LIB ${OPT_UTILS}/lib64/perl5:${OPT_UTILS}/share/perl5
     else
       setenv PERL5LIB ${PERL5LIB}:${OPT_UTILS}/lib64/perl5:${OPT_UTILS}/share/perl5
     endif
   endif
endif

if (! $?LHAPATH) then
  setenv LHAPATH ${OPT_SPHENIX}/lhapdf-5.9.1/share/lhapdf/PDFsets
endif

# OFFLINE
if (! $?OFFLINE_MAIN) then
  if (! -d ${optbasepath}/release/$opt_v) then
    set opt_v = "new"
  endif
  setenv OFFLINE_MAIN ${optbasepath}/release/$opt_v
endif

if ($OFFLINE_MAIN =~ *"insure"* ) then
  setenv G_SLICE always-malloc
else
  if ($?G_SLICE) then
    unsetenv G_SLICE
  endif
endif

# Normalize OFFLINE_MAIN 
if (-d $OFFLINE_MAIN) then
  set here=`pwd`
  cd $OFFLINE_MAIN
  set there=`pwd -P`
  setenv OFFLINE_MAIN `echo $there | sed "s/@sys/$sysname/g"`
  cd $here
endif

# set path to calibration files
if (! $?CALIBRATIONROOT) then
  setenv CALIBRATIONROOT $OFFLINE_MAIN/share/calibrations
endif

if (! $?ONLINE_MAIN) then
  setenv ONLINE_MAIN $OFFLINE_MAIN
endif

# ROOT
if (! $?ROOTSYS) then
    if (-d $OFFLINE_MAIN/root) then
      setenv ROOTSYS $OFFLINE_MAIN/root
    else    
      setenv ROOTSYS $OPT_SPHENIX/root
    endif    
    set here=`pwd`
    cd $ROOTSYS
    set there=`pwd -P`
    setenv ROOTSYS `echo $there | sed "s/@sys/$sysname/g"`
    cd $here
endif

#find root lib and bin dir
if (-f $ROOTSYS/bin/root-config) then
  set rootlibdir_tmp = `$ROOTSYS/bin/root-config --libdir`
  if (-d $rootlibdir_tmp) then
    set here=`pwd`
    cd $rootlibdir_tmp
    set there=`pwd -P`
    set rootlibdir = `echo $there | sed "s/@sys/$sysname/g"`
    cd $here
  endif
  set rootbindir_tmp = `$ROOTSYS/bin/root-config --bindir`
  if (-d $rootbindir_tmp) then
    set here=`pwd`
    cd $rootbindir_tmp
    set there=`pwd -P`
    set rootbindir = `echo $there | sed "s/@sys/$sysname/g"`
    cd $here
  endif
endif

#add our python packages and path to ROOT.py
if (! $?PYTHONPATH) then
  setenv PYTHONPATH ${OPT_SPHENIX}/pythonpackages/lib/python3.8/site-packages:${ROOTSYS}/lib
endif

# Add Geant4
if (! $?G4_MAIN) then
    if (-d $OFFLINE_MAIN/geant4) then
      setenv G4_MAIN ${OFFLINE_MAIN}/geant4
    else
      setenv G4_MAIN ${OPT_SPHENIX}/geant4
    endif
endif

if (-d $G4_MAIN) then
# normalize G4_MAIN to ${optbasepath}/opt/sphenix/core/geant4.Version
    set here=`pwd`
    cd $G4_MAIN
    set there=`pwd -P`
    setenv G4_MAIN `echo $there | sed "s/@sys/$sysname/g"`
    cd $here
# this is for later possible use, extract the main version number
    set g4basedir = `basename $G4_MAIN`
    set g4mainversion = `echo $g4basedir | awk -F. '{print $2}'`
    if (-f ${G4_MAIN}/geant4.csh) then
         source ${G4_MAIN}/geant4.csh >& /dev/null
    else
        if (-f ${G4_MAIN}/bin/geant4.csh) then
            set here=`pwd`
            cd $G4_MAIN/bin
            source geant4.csh  >& /dev/null
            cd $here
        endif
    endif

endif
if (! $?XERCESCROOT) then
  setenv XERCESCROOT $G4_MAIN
endif

if (! $?XERCESCROOT) then
  setenv XERCESCROOT $G4_MAIN
endif

#Pythia8
if (! $?PYTHIA8) then
  if (-d $OFFLINE_MAIN/share/Pythia8) then
    setenv PYTHIA8 $OFFLINE_MAIN/share/Pythia8
  endif
endif

#Sartre
if (! $?SARTRE_DIR) then
  if (-d $OFFLINE_MAIN/sartre) then
    setenv SARTRE_DIR $OFFLINE_MAIN/sartre
  endif
endif

# Set up Insure++, if we have it
if (! $?PARASOFT) then
  setenv PARASOFT /afs/rhic.bnl.gov/app/insure-7.5.3
endif

# Coverity
if (! $?COVERITY_ROOT) then
  setenv COVERITY_ROOT /afs/rhic.bnl.gov/app/coverity-2019.03
endif

#database servers, not used right now
if (! $?PGHOST) then
  setenv PGHOST phnxdbrcf2
  setenv PGUSER phnxrc
  setenv PG_PHENIX_DBNAME Phenix_phnxdbrcf2_C
endif

# set initial paths, all following get prepended
set path = (/usr/local/bin /usr/bin /usr/local/sbin /usr/sbin)
set manpath = `/usr/bin/man --path`

set ldpath = /usr/local/lib64:/usr/lib64

# loop over all bin dirs and prepend to path
foreach bindir (${COVERITY_ROOT}/bin \
                ${PARASOFT}/bin \
                ${G4_MAIN}/bin \
                $rootbindir \
                ${OPT_SPHENIX}/bin \
                ${OPT_UTILS}/bin \
                ${ONLINE_MAIN}/bin \
                ${OFFLINE_MAIN}/bin)
  if (-d $bindir) then
    set path = ($bindir $path)
  endif
end

#loop over all libdirs and prepend to ldpath
foreach libdir (${PARASOFT}/lib \
                ${OPT_SPHENIX}/lhapdf-5.9.1/lib \
                ${G4_MAIN}/lib64 \
                ${rootlibdir} \
                ${OPT_SPHENIX}/lib \
                ${OPT_UTILS}/lib \
                ${ONLINE_MAIN}/lib \
                ${OFFLINE_MAIN}/lib)
  if (-d $libdir) then
    set ldpath = ${libdir}:${ldpath}
  endif
end
# loop over all man dirs and prepend to manpath
foreach mandir (${ROOTSYS}/man \
                ${OPT_SPHENIX}/man \
                ${OPT_SPHENIX}/share/man \
                ${OPT_UTILS}/man \
                ${OPT_UTILS}/share/man \
                ${OFFLINE_MAIN}/share/man)
  if (-d $mandir) then
    set manpath = ${mandir}:${manpath}
  endif
end

# finally prepend . to path/ldpath

set path = (. $path)
set ldpath=.:${ldpath}

# Set some actual environment vars
if ($opt_a) then
    setenv PATH ${ORIG_PATH}:${PATH}
    if (! $?LD_LIBRARY_PATH) then
	setenv LD_LIBRARY_PATH ${ldpath}
    else
	setenv LD_LIBRARY_PATH ${ORIG_LD_LIBRARY_PATH}:${ldpath}
    endif
    if (! $?MANPATH) then
	setenv MANPATH ${manpath}
    else
	setenv MANPATH ${ORIG_MANPATH}:${manpath}
    endif
else
    setenv LD_LIBRARY_PATH ${ldpath}
    setenv MANPATH ${manpath}
endif

#replace @sys by afs sysname (to strip duplicate entries with /@sys/ and /x86_64_sl7/)
setenv PATH  `echo $PATH | sed "s/@sys/$sysname/g"`
setenv LD_LIBRARY_PATH `echo $LD_LIBRARY_PATH | sed "s/@sys/$sysname/g"`
setenv MANPATH  `echo $MANPATH | sed "s/@sys/$sysname/g"`

# strip duplicates in paths
setenv PATH `echo -n $PATH | awk -v RS=: -v ORS=: '! arr[$0]++'` 
setenv LD_LIBRARY_PATH `echo -n $LD_LIBRARY_PATH | awk -v RS=: -v ORS=: '! arr[$0]++'`
setenv MANPATH `echo -n $MANPATH | awk -v RS=: -v ORS=: '! arr[$0]++'`
# the above leaves a colon at the end of the strings, so strip the last character
setenv PATH `echo -n $PATH | sed 's/.$//'`
setenv LD_LIBRARY_PATH `echo -n $LD_LIBRARY_PATH | sed 's/.$//'`
setenv MANPATH `echo -n $MANPATH | sed 's/.$//'`

#set ROOT_INCLUDE_PATH for root6
source $OPT_SPHENIX/bin/setup_root6_include_path.csh $OFFLINE_MAIN

# setup gcc 8.301 (copied from /cvmfs/sft.cern.ch/lcg/releases)

if (-f  ${OPT_SPHENIX}/gcc/8.3.0.1-0a5ad/x86_64-centos7/setup.csh) then
  source ${OPT_SPHENIX}/gcc/8.3.0.1-0a5ad/x86_64-centos7/setup.csh
endif

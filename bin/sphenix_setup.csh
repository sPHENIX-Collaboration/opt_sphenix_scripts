#! /bin/csh -f -x

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

# Usage: source phenix_setup.csh [-a] [-n] [-h] [version]

# use "limit coredumpsize unlimited" to undo this.
limit coredumpsize 0

set opt_a = 0
set opt_b = 0
set opt_n = 0
set opt_v = "ana"

foreach arg ($*)
    switch ($arg)
    case "-a":
	set opt_a = 1
	breaksw
    case "-b*":
	set opt_b = 1
	breaksw
    case "-n":
        set opt_n = 1
	breaksw
    case "-*":
        echo "usage source sphenix_setup.csh [-a] [-n] [-h] [version]"
        echo "-a: append path and LD_LIBRARY_PATH to existing ones"
        echo "-n: overwrite all environment variables, needed for switching builds"
        echo "version: build version (new, ana, pro, play,... - also with version number e.g. ana.230)"
        exit(0)
	breaksw
    case "*":
        set opt_v = $arg
	breaksw
    endsw
end

# STARs environment contains an alias for pwd which
# throws a monkey wrench into pwd -P
unalias pwd

# unset compiler settings from gcc 8.3 in case they were set
# they wreak havoc if you leave them when using another compiler
unsetenv FC
unsetenv CC
unsetenv CXX
unsetenv COMPILER_PATH

# if -n unset all relevant environment variables
# also from phenix setup script so we can switch
if ($opt_n) then
  unsetenv CERN*
  unsetenv CALIBRATIONROOT
  unsetenv CONFIG_SITE
  unsetenv CPLUS_INCLUDE_PATH
  unsetenv CVSROOT
  unsetenv G4*
  unsetenv GSEARCHPATH
  unsetenv LHAPATH
  unsetenv LHAPDF_DATA_PATH
  unsetenv MANPATH
  unsetenv NOPAYLOADCLIENT_CONF
  unsetenv ODBCINI
  unsetenv OFFLINE_MAIN
  unsetenv ONLINE_MAIN
  unsetenv OPT_*
  unsetenv PARASOFT
  unsetenv PERL5LIB
  unsetenv PGHOST
  unsetenv PGUSER
  unsetenv PG_PHENIX_DBNAME
  unsetenv PYTHIA8
  unsetenv PYTHONPATH
  unsetenv ROOTSYS
  unsetenv SARTRE_DIR
  unsetenv SIMULATION_MAIN
  unsetenv TSEARCHPATH
  unsetenv XERCESCROOT
  unsetenv XPLOAD_CONFIG
  unsetenv XPLOAD_CONFIG_DIR
  unsetenv XPLOAD_DIR
endif

# set our postgres defaults
if (! $?PGHOST) then
  setenv PGHOST sphnxdbmaster.sdcc.bnl.gov
endif
if (! $?PGUSER) then
  setenv PGUSER phnxrc
endif

# set afs sysname to replace @sys so links stay functional even if
# the afs sysname changes in the future
if (-f /usr/bin/fs) then
  set sysname=`/usr/bin/fs sysname | sed "s/^.*'\(.*\)'.*/\1/"`
else
  set sysname=x8664_sl7
endif
# turn off opengl direct rendering bc problems for nx
# that problem seems to have been fixed, leave this in here since it
# took a long time to figure this one out
#setenv LIBGL_ALWAYS_INDIRECT 1

# turn off gtk warning about accessibility bus
setenv NO_AT_BRIDGE 1

# speed up DCache
setenv DCACHE_RAHEAD
setenv DCACHE_RA_BUFFER 2097152


# Make copies of PATH and LD_LIBRARY_PATH as they were
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

set local_cvmfsvolume=/cvmfs/sphenix.sdcc.bnl.gov/almalinux-9.2/gcc-13.1.0

if (! $?OPT_SPHENIX) then
  if (-d ${local_cvmfsvolume}/opt/sphenix/core) then
    setenv OPT_SPHENIX ${local_cvmfsvolume}/opt/sphenix/core
  endif
  if (-d ${local_cvmfsvolume}/opt/fun4all/core) then
    setenv OPT_SPHENIX ${local_cvmfsvolume}/opt/fun4all/core
  endif
endif

#for the eic - set OPT_FUN4ALL to OPT_SPHENIX
if (! $?OPT_FUN4ALL) then
  setenv OPT_FUN4ALL $OPT_SPHENIX
endif

if (! $?OPT_UTILS) then
  if (-d ${local_cvmfsvolume}/opt/sphenix/utils) then
    setenv OPT_UTILS ${local_cvmfsvolume}/opt/sphenix/utils
  endif
  if (-d ${local_cvmfsvolume}/opt/fun4all/utils) then
    setenv OPT_UTILS ${local_cvmfsvolume}/opt/fun4all/utils
  endif
endif

# set site wide compiler options (no rpath hardcoding)
if (! $?CONFIG_SITE) then
  if ($opt_v =~ "debug*" ) then
    if (-f ${OPT_SPHENIX}/etc/config_debug.site) then
      setenv CONFIG_SITE ${OPT_SPHENIX}/etc/config_debug.site
    endif
  else
    if (-f ${OPT_SPHENIX}/etc/config.site) then
      setenv CONFIG_SITE ${OPT_SPHENIX}/etc/config.site
    endif
  endif
endif

#lhapdf 5
if (! $?LHAPATH) then
  setenv LHAPATH ${OPT_SPHENIX}/lhapdf-5.9.1/share/lhapdf/PDFsets
endif

# OFFLINE
if (! $?OFFLINE_MAIN) then
  if (! -d ${local_cvmfsvolume}/release/$opt_v) then
    set opt_v = "new"
  endif
  setenv OFFLINE_MAIN ${local_cvmfsvolume}/release/$opt_v
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
endif

if (-d $ROOTSYS) then
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

#LHAPDF 6
if (! $?LHAPDF_DATA_PATH) then
  if (-d ${OFFLINE_MAIN}/share/LHAPDF) then
    setenv LHAPDF_DATA_PATH ${OFFLINE_MAIN}/share/LHAPDF
  else
    if (-d ${OPT_SPHENIX}/LHAPDF/share/LHAPDF) then
      setenv LHAPDF_DATA_PATH ${OPT_SPHENIX}/LHAPDF/share/LHAPDF
    endif
  endif
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
# normalize G4_MAIN to /opt/phenix/geant4.Version
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

if (! $?XPLOAD_CONFIG_DIR) then
  setenv XPLOAD_CONFIG_DIR ${OPT_SPHENIX}/etc
endif

if (! $?NOPAYLOADCLIENT_CONF) then
  setenv NOPAYLOADCLIENT_CONF ${OPT_SPHENIX}/etc/sPHENIX_newcdb.json
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
  setenv PARASOFT /afs/rhic.bnl.gov/app/insure-7.5.5
endif

# File catalog search path
if (! $?GSEARCHPATH) then
    setenv GSEARCHPATH .:PG:LUSTRE:XROOTD:MINIO
endif

# set initial paths, all following get prepended
set path = (/usr/local/bin /usr/bin /usr/local/sbin /usr/sbin)
set manpath = `/usr/bin/man --path`

set ldpath = /usr/local/lib64:/usr/lib64
if (! $?rootbindir) then
  set rootbindir=noexist
endif

# loop over all bin dirs and prepend to path
foreach bindir (${PARASOFT}/bin \
                ${G4_MAIN}/bin \
                ${rootbindir} \
                ${OPT_SPHENIX}/bin \
                ${OPT_UTILS}/bin \
                ${ONLINE_MAIN}/bin \
                ${OFFLINE_MAIN}/bin)
  if (-d $bindir) then
    set path = ($bindir $path)
  endif
end

if (! $?rootlibdir) then
  set rootlibdir=noexist
endif

#loop over all libdirs and prepend to ldpath
foreach libdir (${PARASOFT}/lib \
                ${OPT_SPHENIX}/lhapdf-5.9.1/lib \
                ${G4_MAIN}/lib64 \
                ${rootlibdir} \
                ${OPT_SPHENIX}/lib \
                ${OPT_SPHENIX}/lib64 \
                ${OPT_UTILS}/lib \
                ${OPT_UTILS}/lib64 \
                ${ONLINE_MAIN}/lib \
                ${ONLINE_MAIN}/lib64 \
                ${OFFLINE_MAIN}/lib \
                ${OFFLINE_MAIN}/lib64)
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
# this does not change anything in cvmfs, just in case we need to go to afs
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

# Perl - we have our own version, so run this after our path is set up
set perlversion=`perl -e'print substr($^V, 1)'`
echo setting perlversion to ${perlversion}

if (! $?PERL5LIB) then
echo setting PERL5LIB
  set perldirs = (${OPT_SPHENIX}/lib64/site_perl/${perlversion} ${OPT_SPHENIX}/lib/site_perl/${perlversion} ${OPT_UTILS}/lib64/site_perl/${perlversion} ${OPT_UTILS}/lib/site_perl/${perlversion})
  foreach perldir ($perldirs)
  echo checking $perldir
    if (-d $perldir) then
      if (! $?PERL5LIB) then
        setenv PERL5LIB $perldir
      else
        setenv PERL5LIB ${PERL5LIB}:${perldir}
      endif
    endif
  end
endif

#set ROOT_INCLUDE_PATH for root6
source ${OPT_SPHENIX}/bin/setup_root6_include_path.csh $OFFLINE_MAIN

if (-f  ${OPT_SPHENIX}/gcc/13.1.0-b3d18/x86_64-el9/setup.csh) then
  source ${OPT_SPHENIX}/gcc/13.1.0-b3d18/x86_64-el9/setup.csh
endif

# we need to execute our python3 in our path to get the version
#add our python packages and path to ROOT.py
if (! $?PYTHONPATH) then
  setenv PYTHONPATH ${ROOTSYS}/lib
  set pythonversion = `python3 --version | awk '{print $2}' | awk -F. '{print $1"."$2}'`
  if (-d ${OPT_SPHENIX}/lib/python${pythonversion}/site-packages) then
    setenv PYTHONPATH ${OPT_SPHENIX}/lib/python${pythonversion}/site-packages:${PYTHONPATH}
  endif
  if (-d ${OFFLINE_MAIN}/lib/python${pythonversion}/site-packages) then
    setenv PYTHONPATH ${OFFLINE_MAIN}/lib/python${pythonversion}/site-packages:${PYTHONPATH}
  endif
# last not least add ./ to run shrek which is installed in the local dir
 setenv PYTHONPATH .:${PYTHONPATH}
 unset pythonversion
endif

# check if the s3 read only access is setup, otherwise add it
#if ( -d $HOME/.mcs3 && { grep -q 'eicS3read' $HOME/.mcs3/config.json } ) then
  #do nothing since already configured
#else
  #add the alias
#  mcs3 config host add eicS3 https://dtn01.sdcc.bnl.gov:9000/ eicS3read eicS3read >& /dev/null
#endif

# source local setups
#if (-f /sphenix/user/local_setup_scripts/bin/mc_host_sphenixS3.csh) then
#  source /sphenix/user/local_setup_scripts/bin/mc_host_sphenixS3.csh
#endif

#if (-f /cvmfs/sphenix.sdcc.bnl.gov/rucio-clients/setup.csh) then
#  source /cvmfs/sphenix.sdcc.bnl.gov/rucio-clients/setup.csh
#endif

#unset local variables
unset local_cvmfsvolume

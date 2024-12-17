#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use Getopt::Long;

my $opt_help = 0;

GetOptions('help' => \$opt_help);

if ($opt_help)
{
    print "usage: get_build_tags.pl <build>\n";
    print "no <build>: print list of builds in DB\n";
    print "parameters:\n";
    print "--help: this text\n";
    exit(0);
}

my $dbh = DBI->connect("dbi:ODBC:phnxbld") || die $DBI::error;
if ($#ARGV < 0)
{
    my $getbuilds = $dbh->prepare("select distinct(build) from buildtags order by build");
    $getbuilds->execute() || die $DBI::error;
    while (my @bld = $getbuilds->fetchrow_array())
    {
	print "$bld[0]\n";
    }
    $getbuilds->finish();
}
else
{
    my $gettags = $dbh->prepare("select  reponame,tag  from buildtags where build = ? order by reponame");
    while ($#ARGV >= 0)
    {
	my $build = $ARGV[0];
	$gettags->execute($build);
	if ($gettags->rows > 0)
	{
	    print "\nBuild: $build\n";
	    while (my @repotags = $gettags->fetchrow_array())
	    {
		print "repository: $repotags[0]  tag: $repotags[1]\n";
	    }
	}
	shift(@ARGV);
    }
    $gettags->finish();
}

$dbh->disconnect;

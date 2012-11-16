#!/usr/bin/perl -w
#
#port.pl
#
#
# The combination of -w and use strict enforces various 
# rules that make the script more resilient and easier to run
# as a CGI script.
#
use strict;

# The CGI web generation stuff
# This helps make it easy to generate active HTML content
# from Perl
#
# We'll use the "standard" procedural interface to CGI
# instead of the OO default interface
use CGI qw(:standard);
# The interface to the database.  The interface is essentially
# the same no matter what the backend database is.  
#
# DBI is the standard database interface for Perl. Other
# examples of such programatic interfaces are ODBC (C/C++) and JDBC (Java).
#
#
# This will also load DBD::Oracle which is the driver for
# Oracle.
use DBI;

#
#
# A module that makes it easy to parse relatively freeform
# date strings into the unix epoch time (seconds since 1970)
#
use Time::ParseDate;

#$ENV{PATH} = "$ENV{PATH}:/home/ahj777/www/repos/port339";

#$ENV{PORTF_DBMS} = "oracle";
#$ENV{PORTF_DBUSER} = "rhf687";
#$ENV{PORTF_DBPASS} = "Yoe53chN";
#$ENV{PORTF_DB}="cs339";

use stock_data_access;
#
# You need to override these for access to your database
#
my $dbuser="rhf687";
my $dbpasswd="Yoe53chN";

my $cookiename="PortSession";
my $portName = param("name");

#
# Get the session input and debug cookies, if any
#
my $inputcookiecontent = cookie($cookiename);

print header();

print "<html>";
print "<head>";
print "<title>MyPortfolios</title>";
print "</head>";

print "<body style=\"height:auto;margin:0\">";

print "<style type=\"text/css\">\n\@import \"port.css\";\n</style>\n";

print "<div style= \"border-bottom:2px ridge black\">" ,
        h2($portName),
        "</div>";


print "<table class=\"table\"> <tbody>";
foreach my $stock("TEXQ", "MMA"){
	print "<tr><td><button onclick()='add_daily.pl'>";
	print "Log $stock daily data";
	print "</button></td></tr>";
}
print "</tbody> </table>";

#my $line;
#open CMD, "get_random_symbol.pl  |" or die "Failed: $!";
#print $line while ($line = <CMD>);
#close CMD;

print end_html;

BEGIN {
  unless ($ENV{BEGIN_BLOCK}) {
    use Cwd;
    $ENV{ORACLE_BASE}="/raid/oracle11g/app/oracle/product/11.2.0.1.0";
    $ENV{ORACLE_HOME}=$ENV{ORACLE_BASE}."/db_1";
    $ENV{ORACLE_SID}="CS339";
    $ENV{LD_LIBRARY_PATH}=$ENV{ORACLE_HOME}."/lib";
    $ENV{PATH} = $ENV{PATH}.":/home/ahj777/www/repos/port339";
    $ENV{PORTF_DBMS} = "oracle";
    $ENV{PORTF_DBUSER} = "rhf687";
    $ENV{PORTF_DBPASS} = "Yoe53chN";
    $ENV{PORTF_DB}="cs339";
    $ENV{BEGIN_BLOCK} = 1; 
    exec 'env',cwd().'/'.$0,@ARGV;
  }
}

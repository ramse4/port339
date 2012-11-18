#!/usr/bin/perl -w
#
#login.pl
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

#
# You need to override these for access to your database
#
my $dbuser="rhf687";
my $dbpasswd="Yoe53chN";

BEGIN {
  $ENV{PORTF_DBMS}="oracle";
  $ENV{PORTF_DB}="cs339";
  $ENV{PORTF_DBUSER}="rhf687";
  $ENV{PORTF_DBPASS}="Yoe53chN";

  unless ($ENV{BEGIN_BLOCK}) {
    use Cwd;
    $ENV{ORACLE_BASE}="/raid/oracle11g/app/oracle/product/11.2.0.1.0";
    $ENV{ORACLE_HOME}=$ENV{ORACLE_BASE}."/db_1";
    $ENV{ORACLE_SID}="CS339";
    $ENV{LD_LIBRARY_PATH}=$ENV{ORACLE_HOME}."/lib";
    $ENV{BEGIN_BLOCK} = 1;
    exec 'env',cwd().'/'.$0,@ARGV;
  }
};

use stock_data_access;

my $cookiename="PortSession";


#
# Get the session input and debug cookies, if any
#
my $inputcookiecontent = cookie($cookiename);

#
# Will be filled in as we process the cookies and paramters
#
my $port = param("port");
my $stock=param("stock");
#
# Get the session input and debug cookies, if any
#
my $inputcookiecontent = cookie($cookiename);
my $user;
my $password;

($user,$password) = split(/\//,$inputcookiecontent);


if (defined($user)){
  print header();
}
else{
  print redirect(-uri=>'login.pl');
}

print "<html>";
print "<head>";
print "<title>$port</title>";
print "</head>";

print "<body style=\"height:auto;margin:0\">";

print "<style type=\"text/css\">\n\@import \"port.css\";\n</style>\n";

print "<div style=\"position:absolute;top:0;
  width:100\%; height:30px; background-color:#eeee00; left:0; z-index:999;\">", 
  "<a href=\"login.pl?logout=1\"><strong>Logout</strong> </a>",
  "</div>";


print "<footer style=\"position:fixed;bottom:0;
  width:100\%; height:30px; background-color:#000000;\">",
  "<a href=\"port.pl?name=$port\"><strong>Return to $port Portfolio</strong> </a>",
  "</footer>";

print end_html;
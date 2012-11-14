#!/usr/bin/perl -w
#
#createPort.pl
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

my $cookiename="PortSession";

my $inputcookiecontent = cookie($cookiename);

print header();

print "<html>";
print "<head>";
print "<META HTTP-EQUIV=Refresh CONTENT=\"5; URL=portfolios.pl\">";
print "<title>Portfolio</title>";
print "</head>";

print "<body style=\"height:auto; margin:0\">";

print "<style type=\"text/css\">\n\@import \"port.css\";\n</style>\n";

print "<div class=\"container\" style=\"background-color:#eeeee0; 
	margin:100px auto; width:300px; padding-left:10px;\">";

print h3("Create Portfolio"), p,
	"<strong>Portfolio Name: </strong>",textfield(-name=>'name'),p,
	"<strong>Initial Cash Amount: </strong>", textfield(-name=>'cash'),
	hidden(-name=>'run',default=>['1']),
	"<center><strong>", submit(-class=>'btn btn-primary', -name=>'Add Portfolio'),p, "</strong></center>";

print "</div>";


print "<footer style=\"position:absolute;bottom:0;
	width:100\%; height:30px; background-color:#000000;\">",
	"<a href=\"portfolios.pl\"><strong>Return to Portfolios</strong> </a>",
	"</footer>";

print end_html;
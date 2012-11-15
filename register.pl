#!/usr/bin/perl -w
#
#register.pl
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

my $run;

if (defined(param("run"))) { 
    $run = param("run") == 1;
 } 
 else {
    $run = 0;
 }

#
# Headers and cookies sent back to client
#
# The page immediately expires so that it will be refetched if the
# client ever needs to update it
#
print header();

print "<html>";
print "<head>";
print "<META HTTP-EQUIV=Refresh CONTENT=\"5; URL=portfolios.pl\">";
print "<title>Portfolio Registration</title>";
print "</head>";

print "<body style=\"height:auto;margin:0\">";

print "<style type=\"text/css\">\n\@import \"port.css\";\n</style>\n";

print "<div class=\"container\" style=\"background-color:#eeeee0; 
	margin:100px auto; width:300px; padding-left:10px;\">";
if(!$run){
	print start_form(-name=>'Register'),
	    h3('Register Account'),
	    "Username: ", textfield(-name=>'name'),p,
	    "Password: ", password_field(-name=>'password'),"<br/>", 
	    hidden(-name=>'run',-default=>['1']), "<center>",
	    submit(-class=>'btn', -name=>'Register'), "</center>",
	    end_form;
	 
	}
else{
	my $name = param("name");
	my $password = param("password");
	print "Registration sucessful!<br />";
}
print "</div>";

print "<footer style=\"position:absolute;bottom:0;
	width:100\%; height:30px; background-color:#000000;\">",
	"<a href=\"login.pl\"><strong>Return to Login</strong> </a>",
	"</footer>";


print end_html;
#!/usr/bin/perl -w
#
#portfolios.pl
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

my $cookiename="PortSession";


#
# Get the session input and debug cookies, if any
#
my $inputcookiecontent = cookie($cookiename);

#
# Will be filled in as we process the cookies and paramters
#
my $outputcookiecontent = undef;
my $deletecookie=0;
my $user = undef;
my $password = undef;
my $logincomplain=0;

if (defined($inputcookiecontent)) { 
  # Has cookie, let's decode it
  ($user,$password) = split(/\//,$inputcookiecontent);
  $outputcookiecontent = $inputcookiecontent;
} else {
  # No cookie, treat as anonymous user
  ($user,$password) = ("anon","anonanon");
}

my @outputcookies;

#
# OK, so now we have user/password
# and we *may* have an output cookie.   If we have a cookie, we'll send it right 
# back to the user.
#
# We force the expiration date on the generated page to be immediate so
# that the browsers won't cache it.
#
if (defined($outputcookiecontent)) { 
  my $cookie=cookie(-name=>$cookiename,
		    -value=>$outputcookiecontent,
		    -expires=>($deletecookie ? '-1h' : '+1h'));
  push @outputcookies, $cookie;
} 


#
# Headers and cookies sent back to client
#
# The page immediately expires so that it will be refetched if the
# client ever needs to update it
#
print header(-expires=>'now', -cookie=>\@outputcookies);

print "<html>";
print "<head>";
print "<title>Portfolios</title>";
print "</head>";

print "<body style=\"height:auto;margin:0\">";

print "<style type=\"text/css\">\n\@import \"port.css\";\n</style>\n";

print "<div style= \"border-bottom:2px ridge black\">" ,
	h2("Portfolios"),
	"</div>";

print "<div class=\"container\" style=\"background-color:#eeeee0; 
	margin:100px auto; width:500px; padding-top:10px; padding-left:10px;\">";

print "<a href=\"createPort.pl\" class=\"btn btn-primary\"> Create Portfolio</a>",p,p;

print "<table class=\"table\"> <tbody>";

foreach my $port("portName", "portName2"){
	print "<tr> <td><a href=\"port.pl?name=$port\"> $port </a> </td> 
		<td><button class=\"btn btn-danger\">Delete Portfolio</button> </td></tr>";
}

print "</tbody> </table>";

print "</div>";

print end_html;
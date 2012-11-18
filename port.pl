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

#
# You need to override these for access to your database
#
my $dbuser="rhf687";
my $dbpasswd="Yoe53chN";

my $cookiename="PortSession";

my $withdraw;
my $deposit;
my $amount;

if (defined(param("withdraw"))) { 
    $withdraw = param("withdraw") == 1;
    $deposit = 0;
    $amount = param("amount1");
} 
else {
    $withdraw = 0;
}
if (defined(param("deposit"))) { 
      $amount = param("amount2"); 
      $deposit = param("deposit") == 1;
} 
else {
      $deposit = 0;
}


my $port = param("name");

#
# Get the session input and debug cookies, if any
#
my $inputcookiecontent = cookie($cookiename);
my $user;
my $password;

($user,$password) = split(/\//,$inputcookiecontent);

my $error;
my @portID = getPortID($user, $port);
my $id= $portID[0];
my @money= getCash($id);

if($withdraw){
  my $cash1 = $money[0];
  if ($cash1 > $amount){
    withdrawCash($id, $amount);
  }
  else{
    $error = "Cannot withdraw more money than in cash account";
  }
}
elsif($deposit){

  depositCash($id, $amount);
}



if (defined($user)){
  if ($deposit or $withdraw){
    print redirect(-uri=>'port.pl?name='.$port);
  }
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


print "<div class=\"container\" style=\"background-color:#eeeee0; 
	margin:100px auto; width:500px; padding:10px;\">";
print "<div style= \"border-bottom:2px ridge black\">",
  h2($port), 
  "</div>";

###prints port market value as a whole
print "Market Value of Portfolio: ",
  "bleh", p;

print "Covariance of stocks: ", 
  "bleh", p;

print "Correlation matrix of stocks: ", 
  "bleh", p;


print "<strong><u>Cash Account:</u> \$"; 
my @money2= getCash($id);
my $cash = $money2[0];
printf "%20.2f", $cash, "</strong>";


print start_form(-name=>"Withdraw"),"<br />",
	 "&nbsp;&nbsp;",
	hidden(-name=>'withdraw',default=>['1']),
  hidden(-name=>'name',default=>['$port']),
  "\$", textfield(-name=>'amount1'),
  submit(-class=>'btn', -name=>'Withdraw'),
	end_form;

print "<strong>OR </strong>";

print start_form(-name=>"Deposit"), "<br/>",
  "&nbsp;&nbsp;",
	hidden(-name=>'deposit',default=>['1']),
  hidden(-name=>'name',default=>['$port']),
  "\$", textfield(-name=>'amount2'),
  submit(-class=>'btn', -name=>'Deposit'),
	end_form;

print hr, "<strong><u>Stocks:</u></strong>", p;

##this is canned...needs stocks to actually be gotten with their info 
print "<table class=\"table\" style=\"background-color:white\"> <tbody>";
#can changed layout of table as you wish also porbably want to print in each stock page as well
print "<th>sym</th><th>name</th><th>market value</th><th># of shares</th>";
foreach my $stock("AAPL", "IBM", "BLEH"){

  print "<tr>";
  print "<td><a href=\"stock.pl?port=$port&stock=$stock\"> $stock </a></td>", p
    "</tr>";
}
print "</tbody> </table>";

#area to place adding stocks functionality
#probably want a form(start_form/end_form/submit btn)
print "Add stock functionality",p;
print "symbol:", textfield(),p;
print "shares:", textfield();




print "</div>";

print "<footer style=\"position:fixed;bottom:0;
  width:100\%; height:30px; background-color:#000000;\">",
  "<a href=\"portfolios.pl\"><strong>Return to Portfolio</strong> </a>",
  "</footer>";

print end_html;

sub getPortID{
	my ($user, $port)=@_;
	my @col;
	eval {@col=ExecStockSQL("COL", "select id from portfolios where owner=? and name=?",
	 $user, $port)};
  if ($@) { 
    die "no";
  } else {
    return @col;
  }

}

sub getCash{
	my($id)=@_;
	my @col;
	eval {@col=ExecStockSQL("COL", "select cash from portfolios where id=?",
	 $id)};
  if ($@) { 
    die "no";
  } else {
    return @col;
  }
}

sub depositCash{
  my($id, $amount) = @_;
  eval{
    ExecStockSQL(undef, "update portfolios set cash=cash+? where id=?", $amount,$id)
  };
  return $@;
}

sub withdrawCash{
  my($id, $amount) = @_;
    eval{
      ExecStockSQL(undef, "update portfolios set cash=(cash-?) where id=?", $amount, $id)
    };
    return $@;
  
}

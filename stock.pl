#!/usr/bin/perl -w

use Data::Dumper;
use Finance::Quote;
use Date::Manip;
use Getopt::Long;
use Time::CTime;
use FileHandle;
use strict;
use CGI qw(:standard);
use DBI;
use Time::ParseDate;
my $dbuser="rhf687";
my $dbpasswd="Yoe53chN";

my $cookiename="PortSession";

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
my $inputcookiecontent = cookie($cookiename);

my $stockName = param("stock");
my $action;
my $run;
if (defined(param("act"))) { 
  $action=param("act");
  if (defined(param("run"))) { 
    $run = param("run") == 1;
  } else {
    $run = 0;  
  }
} else {
  $action="base";
  $run = 0;  
}

print header();
print "<html>";
print "<head>";
print "<title>Portfolios</title>";
print "</head>";
print "<body style=\"height:auto;margin:0\">";

print "<style type=\"text/css\">\n\@import \"port.css\";\n</style>\n";
print "<div class=\"container\" style=\"background-color:#eeeee0; 
        margin:100px auto; width:500px; padding:10px;\">";
print "<div style= \"border-bottom:2px ridge black\">" ,
  h3($stockName),
  "</div>";
if (!$run){
  print "<table class=\"table\"> <tbody>";
  print "<tr><td>";
  print start_form,
        submit (-name=>'addDaily', -value=>'Record Daily Info for '.$stockName),"<br/>",
        hidden(-name=>'run',-default=>['1']), 
        hidden(-name=>'act',-default=>['daily']), 
		hidden(-name=>'name',-default=>[$stockName]),
        end_form;
  print "</td></tr>";
  print "<tr><td>";
  print start_form(-name=>'Shannon'),
      h3('Prediction of ' . $stockName),
         "Initial Cash: ", textfield(-name=>'initialcash'),"<br/>", p,
          "Tradecost: ", textfield(-name=>'tradecost'),"<br/>", 
	    hidden(-name=>'symbol',-default=>['AAPL']),
	    hidden(-name=>'run',-default=>['1']),
	    hidden(-name=>'act',-default=>['shannon']),
            submit(-class=>'btn', -name=>'Submit'), "</center>",
      end_form; 
  print "</td></tr>";
  print "<tr><td>";

  print start_form(-name=>'Plot', -action=>'plot_stock_final.pl'),
      h3('Plot History of ' . $stockName),
        "From Date: ", textfield(-name=>'fromTime'),p,
        "To Date: ", textfield(-name=>'toTime'),"<br/>", 
	  hidden(-name=>'symbol',-default=>[$stockName]),
	  hidden(-name=>'type',-default=>['plot']),
	  #hidden(-name=>'act',-default=>['plot']),
	  #hidden(-name=>'run',-default=>['1']),
	  #hidden(-name=>'act',-default=>['plot']),
            submit(-class=>'btn', -name=>'Plot'), "</center>",
      end_form; 
  print "</td></tr>";
  print "</tbody></table>";
}else{
  if ($action eq "daily"){
	  $run = 0;
	  $action = base;
	  my $error = UpdateDaily($stockName);
	  if ($error){
	  print $error;
    }else{
	  print h4($stockName . "'s daily information has been updated");
	  print "<table class=\"table\"> <tbody>";
	  print "<tr><td>";
	  print start_form,
		   submit (-name=>'backToPort', -value=>'Back'),"<br/>",
		   hidden(-name=>'name',-default=>[$stockName]),
		  end_form;
	  print "</td></tr>";
	  print "</tbody></table>";
    }
  }
  #if ($action eq "plot"){
#	$run = 0;
#	$action = base;
#	PlotHistory($stockName);
  	#print "<a href=\'plot_stock.pl?symbol=$stockName&type=plot\'>Plot</a>";
	
 # }
 if ($action eq "shannon"){
    my $initial = param("initialcash");
    my $tradecost = param("tradecost"); 
    my $stock = param("symbol");
    print h4($stock . "'s future predictions");
    print "<table class=\"table\"> <tbody>";
    print "<tr><td>";

    my @output = `./shannon_ratchet.pl $stock $initial $tradecost`;
    foreach my $out(@output){
	print $out."</br>";
    }
    print "</td></tr>";
    print "<tr><td>";
    print start_form,
      submit (-name=>'backToStock', -value=>'Back'),"<br/>",
       hidden(-name=>'name',-default=>[$stockName]),
        end_form;
    print "</td></tr>";
    print "</tbody></table>";

 }
}
print end_html;

sub UpdateDaily{
  my ($symbol) = @_; 
 $symbol = "CNA";
  my @info=("time", "open", "high", "low", "close","volume");
  my @values = (); 
  my $con=Finance::Quote->new();
  $con->timeout(60);
  my %quotes = $con->fetch("usa",$symbol); 
  if (!defined($quotes{$symbol,"success"})) { 
        print "No Data\n";
   } else {
     foreach my $key (@info) {
        if (defined($quotes{$symbol,$key})) {
                if ($key eq "time"){    
                  my $temptime = $quotes{$symbol, $key};
                  my $time = UnixDate($temptime, "%s");
                  push(@values, $time);
                }else{
                my $temp = $quotes{$symbol,$key};
                push(@values, $temp);
                }   
         }else{
                push(@values, '1');
         }   
     }   
   }   

   for my $index (0 .. $#values){
        #print "$index: ";
        #print "$values[$index]\n";
   }   
   my $sql = "insert into stocksdailyaddon values(\'$symbol\',?,?,?,?,?,?)";
   eval{ExecStockSQL(undef, $sql, @values)};
   return $@; 
}

#sub PlotHistory{
# my $from = param("fromTime");
# my $to = param("toTime");
# my $stock = param("symbol");
# my @results = `./get_data.pl --from='$from' --to='$to' --close --plot $stock`;
# print @results;
#}


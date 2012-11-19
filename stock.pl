#!/usr/bin/perl -w

use Data::Dumper;
use Finance::Quote;
use Date::Manip;
use Getopt::Long;
use Time::ParseDate;
use Time::CTime;
use FileHandle;
use strict;
use CGI qw(:standard);
use DBI;
use Time::ParseDate;

my $cookiename="PortSession";

BEGIN {
  $ENV{PORTF_DBMS}="oracle";
  $ENV{PORTF_DB}="cs339";
  $ENV{PORTF_DBUSER}="djl605";
  $ENV{PORTF_DBPASS}="rufi43TJ";

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

my $stockName = param("name");
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
  print start_form(-name=>'Plot', -action=>'plot_stock.pl'),
            h3('Plot History of ' . $stockName),
            #"From Time: ", textfield(-name=>'fromTime'),p,
            #"To Time: ", password_field(-name=>'toTime'),"<br/>", 
            #hidden(-name=>'fromTime',-default=>["1/1/99"]),
            #hidden(-name=>'toTime',-default=>["12/31/00"]),
			hidden(-name=>'symbol',-default=>[$stockName]),
			hidden(-name=>'type',-default=>['plot']),
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
  if ($action eq "plot"){
	$run = 0;
	$action = base;
	#PlotHistory($stockName);
  	print "<a href=\'plot_stock.pl?symbol=$stockName&type=plot\'>Plot</a>";
	
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

sub PlotHistory{
  
  my $close=1;

  my $notime=0;
  my $open=0;
  my $high=0;
  my $low=0;
   $close=0;
  my $vol=0;
  my $from="1/1/99";
  my $to="12/31/00";
  my $plot=1;

  #&GetOptions( "notime"=>\$notime,
#			   "open" => \$open,
#			   "high" => \$high,
#			   "low" => \$low,
#			   "close" => \$close,
#			   "vol" => \$vol,
#			   "from=s" => \$from,
#			   "to=s" => \$to, "plot" => \$plot);

  if (defined $from) { $from=parsedate($from); }
  if (defined $to) { $to=parsedate($to); }


  my $usage = "usage: get_data.pl [--open] [--high] [--low] [--close] [--vol] [--from=time] [--to=time] [--plot] SYMBOL\n";

  #$#ARGV == 0 or die $usage;

  my $symbol = param("name");
  $close = 1;
  
  my @fields;

  push @fields, "timestamp" if !$notime;
  push @fields, "open" if $open;
  push @fields, "high" if $high;
  push @fields, "low" if $low;
  push @fields, "close" if $close;
  push @fields, "volume" if $vol;

$symbol = "AAPL";
  my $sql;

  $sql = "select " . join(",",@fields) . " from ".GetStockPrefix()."StocksDaily";
  $sql = "select " . join(",",@fields) . " from ".GetStockPrefix()."StocksDaily";
  $sql.= " where symbol = '$symbol'";
  $sql.= " and timestamp >= $from" if $from;
  $sql.= " and timestamp <= $to" if $to;
  $sql.= " order by timestamp";

  my $data = ExecStockSQL("TEXT",$sql);
 print "</body>";
  print "</html>";
  if (!$plot) {
	print $data;
  } else {
	open(DATA,">_plot.in") or die "Cannot open temporary file for plotting\n";
	#print DATA $data;
	close(DATA);
	
	open(GNUPLOT, "|gnuplot") or die "Cannot open gnuplot for plotting\n";
	print GNUPLOT "set term png\n"; 
	print GNUPLOT "set output\n";
	
	#GNUPLOT->autoflush(1);
	print GNUPLOT "set title '$symbol'\nset xlabel 'time'\nset ylabel 'data'\n";
	print GNUPLOT "plot '_plot.in' with linespoints;\n";
	print GNUPLOT "e\n";
	close(GNUPLOT);
  }
}

#!/usr/bin/perl -w
use Data::Dumper;
use Finance::Quote;

use stock_data_access;

$#ARGV>=0 or die "usage: quote.pl  SYMBOL+\n";


@info=("date","time","high","low","close","open","volume");
@columns = ();
@values = ();

@symbols=@ARGV;

$con=Finance::Quote->new();

$con->timeout(60);

%quotes = $con->fetch("usa",@symbols);

foreach $symbol (@ARGV) {
    print $symbol,"\n=========\n";
    if (!defined($quotes{$symbol,"success"})) { 
        print "No Data\n";
    } else {

        foreach my $key (@info) {
            if (defined($quotes{$symbol,$key})) {
		my $temp = $quotes{$symbol,$key};
		push(@columns, $key);
		push(@values, $temp);
	    }
	}
	}
}

for my $index (0 .. $#values){
	print "$columns[$index]\n";
	print "$values[$index]\n";
}

#open CMD, "setup_ora.sh  |" or die "Failed: $!";
#close CMD;

#Integrates stock information
my $union = "select * from stocksdailyaddon union select * from ";
$union .= GetStockPrefix();
$union .= "StocksDaily where symbol='KHI'";
#print ExecStockSQL("TEXT", $union);

my $sql = "insert into stocksdailyaddon ";
$sql .= "(SYMBOL, TIMESTAMP, OPEN, HIGH, LOW, CLOSE, VOLUME) ";
$sql .= "VALUES ('KHI', '1', '2', '3','4','5','6')";
ExecStockSQL("TEXT", $sql);

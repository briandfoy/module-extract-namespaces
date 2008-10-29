use strict;
use warnings;

use PPI;

my $Document = PPI::Document->new( $ARGV[0] );
die PPI::Document->errstr unless $Document;

$Document->prune( "PPI::Token::$_" ) for qw(Pod Comment);

my $package_statements = $Document->find( 
	sub { 
		$_[1]->isa('PPI::Statement::Package') 
			? 
		$_[1]->namespace 
			: 
		0 
		}
	);

my @namespaces = eval {
	map {
		/package \s+ (\w+(::\w+)*) \s* ; /x;
		$1
		} @$package_statements
	};
		
$" = "\n\t";
	
print "Got namespaces\n\t@namespaces\n";




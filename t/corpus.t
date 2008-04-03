use strict;
use warnings;

use File::Spec;

use Test::More 'no_plan';

use_ok( 'Module::Extract::Namespaces' );
can_ok( 'Module::Extract::Namespaces', qw(from_file) );

my %Corpus = (
	'None.pm'           => [],   # Perl code but no package
	'Empty.pm'          => [],   # nothing in the file
	'DifferentLines.pm' => [ 'Foo::Comment', 'Foo::Newline' ],
	'Multiple.pm'       => [ map "Foo::$_", qw(First Second Third) ],
	'Duplicates.pm'     => [ map "Foo::$_", qw(First Second Third First) ],
	);
	
foreach my $file ( sort keys %Corpus )
	{
	my $path = File::Spec->catfile( 'corpus', $file );
	ok( -e $path, "Corpus file [ $path ] exists" );
	
	my $namespaces = [ 
		eval{ Module::Extract::Namespaces->from_file( $path ) } 
		];
		
	is_deeply( $namespaces, $Corpus{$file}, "Works for $file" );
	
	}
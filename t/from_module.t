use strict;
use warnings;

use File::Spec;

use Test::More 'no_plan';

my $class  = 'Module::Extract::Namespaces';
my $method = 'from_module';

use_ok( $class );
can_ok( $class, $method );

my $rc = eval { $class->$method() };
my $at = $@;
ok( ! defined $rc, "Eval returns undef for unimplemented method $method");
like( $at, qr/not yet/, "Croaks for unimplemented method $method" );
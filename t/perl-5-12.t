#!/usr/bin/perl

use strict;
use warnings;

use Module::Extract::Namespaces;
use File::Spec::Functions qw(catfile);

use Test::More 0.96 tests => 3;
use Test::Fatal;

my (@namespaces);
my $file = catfile( 'corpus', 'perl-5-12-package.pm' );

is( exception { @namespaces = Module::Extract::Namespaces->from_file($file) },
  undef, 'Calling ->from_file does not return an exception' );

SKIP: {
  skip "Need Perl 5.12 for this test", 1 if $] < 5.012000;
  is( exception { require $file }, undef, "$file is really a valid file" );
}

if ( not @namespaces and not Module::Extract::Namespaces->error ) {
  fail("No namespaces were returned, but no error was reported");
}
elsif ( @namespaces and not defined $namespaces[0] and not Module::Extract::Namespaces->error ) {
  fail("returned [ undef ] and didn't give an error");
  diag explain {
    namespaces => \@namespaces,
    error      => Module::Extract::Namespaces->error,
  };

}
else {
  if ( not @namespaces and Module::Extract::Namespaces->error ) {
    pass("Can't read the file, but at least it warns us with an error");
  }
  elsif ( @namespaces and defined $namespaces[0] and not Module::Extract::Namespaces->error ) {
    pass("Seems we can extract namespaces from perl 5.14 style modules");
  }
  else {
    fail("None of the predefined failure conditions happened either, but no counter-conditions for success were met either");
    diag explain {
      namespaces => \@namespaces,
      error      => Module::Extract::Namespaces->error,
    };
  }
}


package Module::Extract::Namespaces;
use strict;

use warnings;
no warnings;

use subs qw();
use vars qw($VERSION);

$VERSION = '0.15';

use Carp qw(croak);
use PPI;

=head1 NAME

Module::Extract::Namespaces - extract the package declarations from a module

=head1 SYNOPSIS

	use Module::Extract::Namespaces;

	# in scalar context, extract first package namespace
	my $namespace  = Module::Extract::Namespaces->from_file( $filename );
	if( Module::Extract::Namespaces->error ) { ... }
	
	# in list context, extract all namespaces
	my @namespaces = Module::Extract::Namespaces->from_file( $filename );
	if( Module::Extract::Namespaces->error ) { ... }
	

=head1 DESCRIPTION

This module extracts package declarations from Perl code without running the
code. 

It does not extract:

=over 4

=item * packages declared dynamically (e.g. in C<eval>)

=item * packages created as part of a fully qualified variable name

=back

=head2 Class methods

=over 4

=item from_module( MODULE )

****NOT YET IMPLEMENTED****

Extract the namespaces declared in MODULE. In list context, it returns
all of the namespaces, including possible duplicates. In scalar context
it returns the first declared namespace.

If it cannot find MODULE in @INC, it returns undef in scalar context and
the empty list in list context.

On failure it returns nothing, but you have to check with C<error> to
see if that is really an error or a file with no namespaces in it.

=cut

sub from_module
	{
	croak "from_module not yet implemented!";

=begin comment
	
	my( $class, $module, @dirs ) = @_;

	$class->_clear_error;
	
	my $relative_path = $class->_module_to_file( $module );
	my $absolute_path = $class->_rel2abs( $relative_path );
	
	
	if( wantarray ) { my @a = $class->from_file( $absolute_path ) }
	else            { scalar  $class->from_file( $absolute_path ) }

=end comment

=cut

	}

=item from_file( FILENAME )

Extract the namespaces declared in FILENAME. In list context, it returns
all of the namespaces, including possible duplicates. In scalar context
it returns the first declared namespace.

If FILENAME does not exist, it returns undef in scalar context and
the empty list in list context.

On failure it returns nothing, but you have to check with C<error> to
see if that is really an error or a file with no namespaces in it.

=cut
	
sub from_file
	{
	my( $class, $file ) = @_;

	$class->_clear_error;
	
	unless( -e $file )
		{
		$class->_set_error( "File [$file] does not exist!" );
		return;
		}
	
	my $Document = $class->get_pdom( $file );
	return unless $Document;
	
	my @namespaces = $class->get_namespaces_from_pdom( $Document );
	
	if( wantarray ) { @namespaces }
	else            { $namespaces[0] }
	}

=back

=head2 Subclassable hooks

=over 4

=item $class->pdom_base_class()

Return the base class for the PDOM. This is C<PPI> by default. If you want
to use something else, you'll have to change all the other PDOM methods
to adapt to the different interface.

This is the class name to use with C<require> to load the module that
while handle the parsing.

=cut

sub pdom_base_class { 'PPI' }

=item $class->pdom_document_class()

Return the class name to use to create the PDOM object. This is 
C<PPI::Document>.

=cut


sub pdom_document_class { 'PPI::Document' }

=item get_pdom( FILENAME )

Creates the PDOM from FILENAME. This depends on calls to C<pdom_base_class>
and C<pdom_document_class>.

=cut

sub get_pdom
	{
	my( $class, $file ) = @_;
		
	my $pdom_class = $class->pdom_base_class;
	
	eval "require $pdom_class";

	my $Document = eval {
		my $pdom_document_class = $class->pdom_document_class;

		my $d = $pdom_document_class->new( $file );
		die $pdom_document_class->errstr unless $d;
		
		$class->pdom_preprocess( $d );
		$d;
		};

	if( $@ )
		{
		$class->_set_error( "Could not get PDOM for $file: $@" );
		return;
		}
		
	$Document;
	}

=item $class->pdom_preprocess( PDOM )

Override this method to play with the PDOM before extracting the
package declarations.

By default, it strips Pod and comments from the PDOM.

=cut

sub pdom_preprocess      
	{ 
	my( $class, $Document ) = @_;

	eval {
		$class->pdom_strip_pod( $Document );
		$class->pdom_strip_comments( $Document );
		};
		
	return 1;
	}

=item $class->pdom_strip_pod( PDOM )

Strips Pod documentation from the PDOM.

=cut

sub pdom_strip_pod      { $_[1]->prune('PPI::Token::Pod') }

=item $class->pdom_strip_comments( PDOM )

Strips comments from the PDOM.

=cut

sub pdom_strip_comments { $_[1]->prune('PPI::Token::Comment') }

=item $class->get_namespaces_from_pdom( PDOM )

Extract the namespaces from the PDOM. It returns a list of package
names in the order that it finds them in the PDOM. It does not 
remove duplicates (do that later if you like).

=cut

sub get_namespaces_from_pdom
	{
	my( $class, $Document ) = @_;

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
		
	#print STDERR "Got namespaces @namespaces\n";
	
	@namespaces;
		
	}	

=item $class->error

Return the error from the last call to C<get_modules>.

=cut

BEGIN {
my $Error = '';

sub _set_error   { $Error = $_[1]; }

sub _clear_error { $Error = '' }

sub error        { $Error }
}

=back

=head1 TO DO

* Add caching based on file digest?

=head1 SOURCE AVAILABILITY

This code is in Github:

	git://github.com/briandfoy/module-extract-namespaces.git

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

This module was partially funded by The Perl Foundation (www.perlfoundation.org)
and LogicLAB (www.logiclab.dk), both of whom provided travel assistance to
the 2008 Oslo QA Hackathon where I created this module.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2008-2011, brian d foy, All Rights Reserved.

You may redistribute this under the same terms as Perl itself.

=cut

1;

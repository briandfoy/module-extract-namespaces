# $Id$
package Module::Extract::Namespaces;
use strict;

use warnings;
no warnings;

use subs qw();
use vars qw($VERSION);

$VERSION = '0.11_01';

use Carp qw(croak);
use PPI;

=head1 NAME

Module::Extract::Namespaces - extract the package declarations from a module

=head1 SYNOPSIS

	use Module::Extract::Namespaces;

	# in scalar context, extract first package namespace
	my $namespace  = Module::Extract::Namespaces->from_module( 'Foo::Bar' );

	# in list context, extract all namespaces
	my @namespaces = Module::Extract::Namespaces->from_file( $filename );
	

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

Extract the namespaces declared in MODULE. In list context, it returns
all of the namespaces, including possible duplicates. In scalar context
it returns the first declared namespace.

If it cannot find MODULE in @INC, it returns undef in scalar context and
the empty list in list context.

XXX: On failure? Some files do not have packages

=cut

sub from_module
	{
	croak "from_module not yet implemented!";
	
	my( $class, $module, @dirs ) = @_;
	
	my $relative_path = $class->_module_to_file( $module );
	my $absolute_path = $class->_rel2abs( $relative_path );
	
	
	if( wantarray ) { my @a = $class->from_file( $absolute_path ) }
	else            { scalar  $class->from_file( $absolute_path ) }
	}

=item from_file( FILENAME )

Extract the namespaces declared in FILENAME. In list context, it returns
all of the namespaces, including possible duplicates. In scalar context
it returns the first declared namespace.

If FILENAME does not exist, it returns undef in scalar context and
the empty list in list context.

XXX: On failure? Some files do not have packages

=cut
	
sub from_file
	{
	my( $class, $file ) = @_;

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

		$class->pdom_preprocess( $d );
		$d;
		};

	if( $@ )
		{
		warn( "Could not get PDOM for $file: $@" );
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

=back

=head1 TO DO

* Add caching based on file digest?

=head1 SEE ALSO


=head1 SOURCE AVAILABILITY

This source is part of a SourceForge project which always has the
latest sources in CVS, as well as all of the previous releases.

	http://sourceforge.net/projects/brian-d-foy/

If, for some reason, I disappear from the world, one of the other
members of the project can shepherd this module appropriately.

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

This module was partially funded by The Perl Foundation (www.perlfoundation.org)
and LogicLAB (www.logiclab.dk), both of whom provided travel assistance to
the 2008 Oslo QA Hackathon where I created this module.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2008, brian d foy, All Rights Reserved.

You may redistribute this under the same terms as Perl itself.

=cut

1;

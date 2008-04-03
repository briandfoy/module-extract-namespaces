# $Id: Makefile.PL,v 1.4 2004/07/04 17:04:17 comdog Exp $
use ExtUtils::MakeMaker;

require 5.006;

eval "use Test::Manifest 1.14";

WriteMakefile(
	'NAME'	       => 'Module::Extract::Namespaces',
	'ABSTRACT'     => 'This is what the module does',
	'VERSION_FROM' => 'lib/Namespaces.pm',
	'LICENSE'      => 'perl',
	'AUTHOR'       => 'brian d foy <bdfoy@cpan.org>',
	
	'PREREQ_PM'    => { 
		'Test::More' => '0',
		'PPI'        => '0',
		},

	'PM'           => {
		'lib/Namespaces.pm'         => '$(INST_LIBDIR)/Namespaces.pm',
		},

	'MAN3PODS'     => {
		'lib/Namespaces.pm' => '$(INST_MAN3DIR)/Module::Extract::Namespaces.3',
		},

	clean  => { FILES    => q|Module-Extract-Namespaces-*| },

	);

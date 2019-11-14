package Util::Medley::Roles::Attributes::XML;

use Modern::Perl;
use Moose::Role;
use Util::Medley::XML;

=head1 NAME

Util::Medley::Roles::Attributes::XML

=cut

has Xml => (
	is      => 'ro',
	isa     => 'Util::Medley::XML',
	lazy    => 1,
	default => sub { return Util::Medley::XML->new },
);

1;

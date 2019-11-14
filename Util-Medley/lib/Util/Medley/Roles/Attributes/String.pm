package Util::Medley::Roles::Attributes::String;

use Modern::Perl;
use Moose::Role;
use Util::Medley::String;

=head1 NAME

Util::Medley::Roles::Attributes::String

=cut

has String => (
	is      => 'ro',
	isa     => 'Util::Medley::String',
	lazy    => 1,
	default => sub { return Util::Medley::String->new },
);

1;

package Util::Medley::Roles::Attributes::Spawn;

use Modern::Perl;
use Moose::Role;
use Util::Medley::Spawn;

=head1 NAME

Util::Medley::Roles::Attributes::Spawn

=cut

has Spawn => (
	is      => 'ro',
	isa     => 'Util::Medley::Spawn',
	lazy    => 1,
	default => sub { return Util::Medley::Spawn->new },
);

1;

package Util::Medley::Roles::Attributes::Hash;

use Modern::Perl;
use Moose::Role;
use Util::Medley::Hash;

=head1 NAME

Util::Medley::Roles::Attributes::Hash

=cut

has Hash => (
	is      => 'ro',
	isa     => 'Util::Medley::Hash',
	lazy    => 1,
	default => sub { return Util::Medley::Hash->new },
);

1;

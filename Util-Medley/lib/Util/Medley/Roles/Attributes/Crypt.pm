package Util::Medley::Roles::Attributes::Crypt;

use Modern::Perl;
use Moose::Role;
use Util::Medley::Crypt;

=head1 NAME

Util::Medley::Roles::Attributes::Crypt

=cut

has Crypt => (
	is      => 'ro',
	isa     => 'Util::Medley::Crypt',
	lazy    => 1,
	default => sub { return Util::Medley::Crypt->new },
);

1;

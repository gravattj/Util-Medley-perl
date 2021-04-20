package Util::Medley::Roles::Attributes::Package;

use Modern::Perl;
use Moose::Role;
use Util::Medley::Package;

=head1 NAME

Util::Medley::Roles::Attributes::Package

=cut

has Package => (
	is      => 'ro',
	isa     => 'Util::Medley::Package',
	lazy    => 1,
	default => sub { return Util::Medley::Package->new },
);

1;

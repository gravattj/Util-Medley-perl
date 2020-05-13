package Util::Medley::Roles::Attributes::Hostname;

use Modern::Perl;
use Moose::Role;
use Util::Medley::Hostname;

=head1 NAME

Util::Medley::Roles::Attributes::Hostname

=cut

has Hostname => (
	is      => 'ro',
	isa     => 'Util::Medley::Hostname',
	lazy    => 1,
	default => sub { return Util::Medley::Hostname->new },
);

1;

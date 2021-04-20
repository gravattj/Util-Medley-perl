package Util::Medley::Roles::Attributes::List;

use Modern::Perl;
use Moose::Role;
use Util::Medley::List;

=head1 NAME

Util::Medley::Roles::Attributes::List

=cut

has List => (
	is      => 'ro',
	isa     => 'Util::Medley::List',
	lazy    => 1,
	default => sub { return Util::Medley::List->new },
);

1;

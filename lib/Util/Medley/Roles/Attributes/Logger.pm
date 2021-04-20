package Util::Medley::Roles::Attributes::Logger;

use Modern::Perl;
use Moose::Role;
use Util::Medley::Logger;

=head1 NAME

Util::Medley::Roles::Attributes::Logger

=cut

has Logger => (
	is      => 'ro',
	isa     => 'Util::Medley::Logger',
	lazy    => 1,
	default => sub { return Util::Medley::Logger->new },
);

1;

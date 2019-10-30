package Util::Medley::Roles::Attributes::DateTime;

use Modern::Perl;
use Moose::Role;
use Method::Signatures;
use Util::Medley::DateTime;

=head1 NAME

Util::Medley::Roles::Attributes::DateTime

=cut

has DateTime => (
	is      => 'ro',
	isa     => 'Util::Medley::DateTime',
	lazy    => 1,
	default => sub { return Util::Medley::DateTime->new },
);

1;

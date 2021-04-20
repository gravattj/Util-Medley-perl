package Util::Medley::Roles::Attributes::Number;

use Modern::Perl;
use Moose::Role;
use Util::Medley::Number;

=head1 NAME

Util::Medley::Roles::Attributes::Number

=cut

has Number => (
	is      => 'ro',
	isa     => 'Util::Medley::Number',
	lazy    => 1,
	default => sub { return Util::Medley::Number->new },
);

1;

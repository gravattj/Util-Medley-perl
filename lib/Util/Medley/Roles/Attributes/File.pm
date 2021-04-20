package Util::Medley::Roles::Attributes::File;

use Modern::Perl;
use Moose::Role;
use Util::Medley::File;

=head1 NAME

Util::Medley::Roles::Attributes::File

=cut

has File => (
	is      => 'ro',
	isa     => 'Util::Medley::File',
	lazy    => 1,
	default => sub { return Util::Medley::File->new },
);

1;

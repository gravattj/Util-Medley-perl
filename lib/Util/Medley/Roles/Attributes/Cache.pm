package Util::Medley::Roles::Attributes::Cache;

use Modern::Perl;
use Moose::Role;
use Util::Medley::Cache;

=head1 NAME

Util::Medley::Roles::Attributes::Cache

=cut

has Cache => (
	is      => 'ro',
	isa     => 'Util::Medley::Cache',
	lazy    => 1,
	default => sub { return Util::Medley::Cache->new },
);

1;

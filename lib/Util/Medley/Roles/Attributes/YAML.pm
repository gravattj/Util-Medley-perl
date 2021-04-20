package Util::Medley::Roles::Attributes::YAML;

use Modern::Perl;
use Moose::Role;
use Util::Medley::YAML;

=head1 NAME

Util::Medley::Roles::Attributes::YAML

=cut

has Yaml => (
	is      => 'ro',
	isa     => 'Util::Medley::Yaml',
	lazy    => 1,
	default => sub { return Util::Medley::YAML->new },
);

1;

package Util::Medley::Roles::Attributes::Linux::Yum;

use Modern::Perl;
use Moose::Role;
use Util::Medley::Linux::Yum;

=head1 NAME

Util::Medley::Roles::Attributes::Linux::Yum

=cut

has LinuxYum => (
	is      => 'ro',
	isa     => 'Util::Medley::Linux::Yum',
	lazy    => 1,
	default => sub { return Util::Medley::Linux::Yum->new },
);

1;

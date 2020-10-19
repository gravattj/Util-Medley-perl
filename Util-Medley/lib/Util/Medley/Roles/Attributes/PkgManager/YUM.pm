package Util::Medley::Roles::Attributes::PkgManager::YUM;

use Modern::Perl;
use Moose::Role;
use Util::Medley::PkgManager::YUM;

=head1 NAME

Util::Medley::Roles::Attributes::PkgManager::YUM

=cut

has PkgManagerYum => (
	is      => 'ro',
	isa     => 'Util::Medley::PkgManager::YUM',
	lazy    => 1,
	default => sub { return Util::Medley::PkgManager::YUM->new; }
);

1;

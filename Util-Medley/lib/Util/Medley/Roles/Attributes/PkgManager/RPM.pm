package Util::Medley::Roles::Attributes::PkgManager::RPM;

use Modern::Perl;
use Moose::Role;
use Util::Medley::PkgManager::RPM;

=head1 NAME

Util::Medley::Roles::Attributes::PkgManager::RPM

=cut

has PkgManagerRpm => (
	is      => 'ro',
	isa     => 'Util::Medley::PkgManager::RPM',
	lazy    => 1,
	default => sub { return Util::Medley::PkgManager::RPM->new; }
);

1;

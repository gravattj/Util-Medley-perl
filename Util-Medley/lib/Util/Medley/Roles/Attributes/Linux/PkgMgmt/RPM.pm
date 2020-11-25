package Util::Medley::Roles::Attributes::Linux::PkgMgmt::RPM;

use Modern::Perl;
use Moose::Role;
use Util::Medley::Linux::PkgMgmt::RPM;

=head1 NAME

Util::Medley::Roles::Attributes::Linux::PkgMgmt::RPM

=cut

has LinuxPkgMgmtRpm => (
	is      => 'ro',
	isa     => 'Util::Medley::Linux::PkgMgmt::RPM',
	lazy    => 1,
	default => sub { return Util::Medley::Linux::PkgMgmt::RPM->new; }
);

1;

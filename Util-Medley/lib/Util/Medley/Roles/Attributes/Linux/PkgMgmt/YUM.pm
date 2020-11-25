package Util::Medley::Roles::Attributes::Linux::PkgMgmt::YUM;

use Modern::Perl;
use Moose::Role;
use Util::Medley::Linux::PkgMgmt::YUM;

=head1 NAME

Util::Medley::Roles::Attributes::Linux::PkgMgmt::YUM

=cut

has LinuxPkgMgmtYum => (
	is      => 'ro',
	isa     => 'Util::Medley::Linux::PkgMgmt::YUM',
	lazy    => 1,
	default => sub { return Util::Medley::Linux::PkgMgmt::YUM->new; }
);

1;

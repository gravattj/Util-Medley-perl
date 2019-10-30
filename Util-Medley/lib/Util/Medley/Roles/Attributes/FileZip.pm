package Util::Medley::Roles::Attributes::FileZip;

use Modern::Perl;
use Moose::Role;
use Method::Signatures;
use Util::Medley::FileZip;

=head1 NAME

Util::Medley::Roles::Attributes::FileZip

=cut

has FileZip => (
	is      => 'ro',
	isa     => 'Util::Medley::FileZip',
	lazy    => 1,
	default => sub { return Util::Medley::FileZip->new },
);

1;

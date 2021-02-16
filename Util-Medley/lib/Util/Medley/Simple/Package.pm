package Util::Medley::Simple::Package;

#
# Moose::Exporter exports everything into your namespace.  This
# approach allows for importing individual functions.
#

=head1 NAME

Util::Medley::Simple::Package - an exporter module for Util::Medley::Package

=cut

use Modern::Perl;
use Util::Medley::Package;

use Exporter::Easy (
    OK   => [qw(pkgBasename)],
    TAGS => [
        all => [qw(pkgBasename)],
    ]
);

my $package = Util::Medley::Package->new;
 
sub pkgBasename {
    return $package->basename(@_);    
}        
    
1;

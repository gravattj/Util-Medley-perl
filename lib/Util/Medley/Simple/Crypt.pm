package Util::Medley::Simple::Crypt;

#
# Moose::Exporter exports everything into your namespace.  This
# approach allows for importing individual functions.
#

=head1 NAME

Util::Medley::Simple::Crypt - an exporter module for Util::Medley::Crypt

=cut

use Modern::Perl;
use Util::Medley::Crypt;

use Exporter::Easy (
    OK   => [qw(decryptStr encryptStr)],
    TAGS => [
        all => [qw(decryptStr encryptStr)],
    ]
);

my $crypt = Util::Medley::Crypt->new;
 
sub decryptStr {
    return $crypt->decryptStr(@_);    
}        
     
sub encryptStr {
    return $crypt->encryptStr(@_);    
}        
    
1;

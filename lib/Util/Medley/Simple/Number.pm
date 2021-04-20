package Util::Medley::Simple::Number;

#
# Moose::Exporter exports everything into your namespace.  This
# approach allows for importing individual functions.
#

=head1 NAME

Util::Medley::Simple::Number - an exporter module for Util::Medley::Number

=cut

use Modern::Perl;
use Util::Medley::Number;

use Exporter::Easy (
    OK   => [qw(commify decommify)],
    TAGS => [
        all => [qw(commify decommify)],
    ]
);

my $number = Util::Medley::Number->new;
 
sub commify {
    return $number->commify(@_);    
}        
     
sub decommify {
    return $number->decommify(@_);    
}        
    
1;

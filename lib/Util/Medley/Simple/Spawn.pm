package Util::Medley::Simple::Spawn;

#
# Moose::Exporter exports everything into your namespace.  This
# approach allows for importing individual functions.
#

=head1 NAME

Util::Medley::Simple::Spawn - an exporter module for Util::Medley::Spawn

=cut

use Modern::Perl;
use Util::Medley::Spawn;

use Exporter::Easy (
    OK   => [qw(capture spawn)],
    TAGS => [
        all => [qw(capture spawn)],
    ]
);

my $spawn = Util::Medley::Spawn->new;
 
sub capture {
    return $spawn->capture(@_);    
}        
     
sub spawn {
    return $spawn->spawn(@_);    
}        
    
1;

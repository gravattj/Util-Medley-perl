package Util::Medley::Simple::YAML;

#
# Moose::Exporter exports everything into your namespace.  This
# approach allows for importing individual functions.
#

=head1 NAME

Util::Medley::Simple::YAML - an exporter module for Util::Medley::YAML

=cut

use Modern::Perl;
use Util::Medley::YAML;

use Exporter::Easy (
    OK   => [qw(yamlDecode yamlEncode yamlRead yamlWrite)],
    TAGS => [
        all => [qw(yamlDecode yamlEncode yamlRead yamlWrite)],
    ]
);

my $yaml = Util::Medley::YAML->new;
 
sub yamlDecode {
    return $yaml->decode(@_);    
}        
     
sub yamlEncode {
    return $yaml->encode(@_);    
}        
     
sub yamlRead {
    return $yaml->read(@_);    
}        
     
sub yamlWrite {
    return $yaml->write(@_);    
}        
    
1;

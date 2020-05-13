package Util::Medley::Hostname;

use Modern::Perl;
use Moose;
use namespace::autoclean;
use Kavorka '-all';
use Data::Printer alias => 'pdump';

=head1 NAME

Util::Medley::Hostname - Utilities for dealing with hostnames.

=cut

=head1 SYNOPSIS

  my $util = Util::Medley::Host->new;
  my ($hostname, $domain) = $util->parseHostname('foobar.example.com');
  
=cut

########################################################

=head1 DESCRIPTION

Utility module for slicing and dicing hostnames.

All methods confess on error.

=cut

########################################################

=head1 METHODS

=head2 parseHostname

Parses the specified hostname into hostname and domain (if exists).

=over

=item usage:

  my ($hostname, $domain) = 
      $util->parseHostname('foobar.example.com');
  
  my ($hostname, $domain) = 
      $util->parseHostname(hostname => 'foobar.example.com');
  
=item args:

=over

=item hostname [Str]

Hostname you wish to parse.

=back

=back

=cut

multi method parseHostname (Str :$hostname!) {

    my @a = split(/\./, $hostname);
    my $host = shift @a;
    my $domain = join '.', @a;
    
    return ($host, $domain); 	
}

multi method parseHostname (Str $hostname) {

    return $self->parseHostname(hostname => $hostname);	
}


=head2 isFqdn

Checks if a given hostname is fully qualified.

=over

=item usage:

  my $bool = $util->isFqdn('foobar.example.com');
  
  my $bool = $util->isFqdn(hostname => 'foobar.example.com');
  
=item args:

=over

=item hostname [Str]

Hostname to be checked.

=back

=back

=cut

multi method isFqdn (Str :$hostname!) {

    my ($h, $d) = $self->parseHostname(hostname => $hostname);
    if ($h and $d) {
        return 1;	
    } 
    
    return 0;
}

multi method isFqdn (Str $hostname) {

    return $self->isFqdn(hostname => $hostname); 
}

1;
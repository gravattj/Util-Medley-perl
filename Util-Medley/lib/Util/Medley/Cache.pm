package Util::Medley::Cache;

use Modern::Perl;
use Moose;
use Method::Signatures;
use namespace::autoclean;
use Data::Printer alias => 'pdump';

with 'Util::Medley::Roles::Cache';

=head1 NAME

Base class for use with Util::Medley::Roles::Cache

=cut

=head1 SYNOPSIS

  my $c = Util::Medley::Cache->new;
  
  $c->cacheSet(namespace => 'unittest', 
               cache_key => 'test1', 
               data      => { foo => 'bar' });

  my $data = $c->cacheGet(namespace => 'unittest', 
                          cache_key => 'test1');

  my @keys = $c->cacheGetKeys(namespace => 'unittest');

  $c->cacheDelete(namespace => 'unittest', 
                  cache_key => 'test1');

=cut

########################################################

=head1 DESCRIPTION

See L<Util::Medley::Roles::Cache>

=cut

1;

package Util::Medley::DateTime;

use Modern::Perl;
use Moose;
use namespace::autoclean;
use Method::Signatures;
use Data::Printer alias => 'pdump';
use Time::localtime;

=head1 NAME

Util::Medley::DateTime - Class with various datetime methods.

=cut

=head1 SYNOPSIS

  my $dt = Util::Medley::DateTime->new;
  
  print $dt->localdatetime;
 
=cut

########################################################

=head1 DESCRIPTION

A small datetime library.  This doesn't do any calculations itself, but 
provides some simple methods to call for getting the date/time in a commonly
used format.

=cut

########################################################

=head1 ATTRIBUTES

none

=head1 METHODS

=head2 localdatetime

Returns the local date/time in the format: YYYY-MM-DD HH:MM:SS.  

=cut

method localdatetime ($time = time) {

    my $l = localtime($time);

    my $str = sprintf(
        '%04d-%02d-%02d %02d:%02d:%02d',
        $l->year + 1900,
        $l->mon + 1,
        $l->mday, $l->hour, $l->min, $l->sec
    );

    return $str;
}


1;
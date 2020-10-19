package Util::Medley::PkgManager::RPM;

use Modern::Perl;
use Moose;
use namespace::autoclean;
use Data::Printer alias => 'pdump';
use Kavorka 'method', 'multi';

with
  'Util::Medley::Roles::Attributes::Spawn',
  'Util::Medley::Roles::Attributes::String';

=head1 NAME

Util::Medley::PkgManager::RPM - Class for interacting with RPM

=cut

=head1 SYNOPSIS

  my $rpm = Util::Medley::PkgManager::RPM->new;
  
  #
  # positional  
  #
  $aref = $rpm->queryAll;
  $aref = $rpm->queryList($rpmName);
                        
  #
  # named pair
  #
  $aref = $rpm->queryList(rpmName => $rpmName);

=cut

########################################################

=head1 DESCRIPTION

A simple wrapper library for the Redhat Package Manager.

=cut

########################################################

=head1 ATTRIBUTES

none

=head1 METHODS

=head2 queryAll

Query all installed packages.

Returns: ArrayRef[Str]

=over

=item usage:

 $aref = $yum->queryAll;
 
=item args: None

=back

=back

=cut

method queryAll {

    my @cmd;
    push @cmd, 'rpm';
    push @cmd, '--query';
    push @cmd, '--all';
    
    my ($stdout, $stderr, $exit) = $self->Spawn->capture(cmd => \@cmd, wantArrayRef => 1);
    if ($exit) {
        confess $stderr;    
    } 
    
    return $stdout;
}

=head2 queryList

List files in package.

Returns: ArrayRef[Str]

=over

=item usage:

 $aref = $yum->queryList($rpmName);

 $aref = $yum->queryList(rpmName => $rpmName);
 
=item args:

=over

=item rpmName [Str] (required)

The name of the rpm package to query.

=back

=back

=cut

multi method queryList (Str :$rpmName!) {

    my @cmd;
    push @cmd, 'rpm';
    push @cmd, '--query';
    push @cmd, '--list';
    push @cmd, $rpmName;
    
    my ($stdout, $stderr, $exit) = $self->Spawn->capture(cmd => \@cmd, wantArrayRef => 1);
    if ($exit) {
        confess $stderr;	
    } 
    
    return $stdout;
}

multi method queryList (Str $rpmName!) {

    return $self->queryList(rpmName => $rpmName);	
}

#################################################################3

1;

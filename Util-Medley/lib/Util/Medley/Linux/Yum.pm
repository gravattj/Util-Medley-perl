package Util::Medley::Linux::Yum;

use Modern::Perl;
use Moose;
use namespace::autoclean;
use Data::Printer alias => 'pdump';
use Kavorka 'method', 'multi';

with
  'Util::Medley::Roles::Attributes::Spawn',
  'Util::Medley::Roles::Attributes::String';

=head1 NAME

Util::Medley::Linux::Yum - Class for interacting with YUM

=cut

=head1 SYNOPSIS

  my $yum = Util::Medley::Yum->new;

  #
  # positional  
  #
  say $yum->TODO(TODO);

  #
  # named pair
  #
  say $yum->TODO(TODO=>TODO);
   
=cut

########################################################

=head1 DESCRIPTION

A simple wrapper library for YUM on Linux.  

=cut

########################################################

=head1 ATTRIBUTES

none

=head1 METHODS

=head2 repoList

Generates a list of configured YUM repositories.

Returns: ArrayRef[HashRef]

Example HashRef:

  {
    repoBaseurl   "http://centos3.zswap.net/7.8.2003/updates/x86_64/ (9 more)",
    repoExpire    "21,600 second(s) (last: Tue Oct 13 12:14:28 2020)",
    repoId        "updates/7/x86_64",
    repoMirrors   "http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=updates&infra=vag",
    repoName      "CentOS-7 - Updates",
    repoPkgs      "1,104",
    repoSize      "5.4 G",
    repoStatus    "enabled",
    repoUpdated   "Mon Sep 14 08:18:15 2020"
  }

=over

=item usage:

 $aref = $yum->repoList([$enabled], [$disabled]);

 $aref = $yum->repoList([enabled => 1],
                        [disabled => 0]);
 
=item args:

=over

=item enabled [Bool] (optional)

Flag indicating the returned list should include enabled repos.

Default: 1

=item disabled [Bool] (optional)

Flag indicating the returned list should include disabled repos.

Default: 0

=back

=back

=cut

method repoList (Bool :$enabled = 1,
                 Bool :$disabled = 0) {

	my @cmd = ( 'yum', 'repolist', '-v', 'all' );

	my ( $stdout, $stderr, $exit ) =
	  $self->Spawn->capture( cmd => \@cmd, wantArrayRef => 1 );
	if ($exit) {
		confess $stderr;
	}

	my @repos;
	my $repoHref;

	foreach my $line (@$stdout) {

		next if $self->String->isBlank($line);

		if ( $line =~ /^Repo-\w+\s/ ) {
			my ( $key, $value ) = $self->_repoListParseLine($line);
			if ( $key eq 'repoId' ) {
				if ($repoHref) {
					push @repos, $repoHref;
				}

				$repoHref = {};
			}

			$repoHref->{$key} = $value;
		}
	}

	if ($repoHref) {
		push @repos, $repoHref;
	}

	my $reposAref = [];
	foreach my $repo (@repos) {
		my $status = $repo->{repoStatus};
		if ( $status eq 'enabled' ) {
			if ($enabled) {
				push @$reposAref, $repo;
			}
		}
		elsif ( $status eq 'disabled' ) {
			if ($disabled) {
				push @$reposAref, $repo;
			}
		}
		else {
			confess "unhandled repoStatus: $status";
		}
	}

	return $reposAref;
}

# TODO
#multi method repoList () {
#
#}

#################################################################3

method _repoListParseLine (Str $line) {

	my ( $key, @value ) = split( /:/, $line );

	$key = $self->String->trim($key);
	$key = $self->String->camelize($key);

	my $value = join ':', @value;
	$value = $self->String->trim($value);

	return ( $key, $value );
}

1;

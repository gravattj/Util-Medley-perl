package Util::Medley::File;

use Modern::Perl;
use Moose;
use Method::Signatures;
use namespace::autoclean;

use Data::Printer alias => 'pdump';
use Carp;
use File::Copy;
use File::LibMagic;
use File::Path qw(mkpath remove_tree);
use Try::Tiny;
use Cwd;
use Path::Iterator::Rule;

with 'Util::Medley::Roles::Attributes::Logger';
with 'Util::Medley::Roles::Attributes::String';
with 'Util::Medley::Roles::Attributes::Spawn';

=head1 NAME

Util::Medley::File - utility file methods

=cut

=head1 SYNOPSIS

  
=cut

########################################################

=head1 DESCRIPTION


=cut

########################################################

=head1 ATTRIBUTES

=head2 key (optional)

Key to use for encrypting/decrypting methods when one isn't provided.

=cut

#########################################################################################

=pod

use base 'Exporter';
our @EXPORT = qw();    # Symbols to autoexport (:DEFAULT tag)

our @EXPORT_OK = qw(
  chdir
  chmod
  file_type
  findFiles
  ls_zip mkdir
  trim_file_ext
  splitpath
  unlink
  xmllint
  );                   # Symbols to export on request

our %EXPORT_TAGS = (   # Define names for sets of symbols
    all => \@EXPORT_OK,
);

=cut

#########################################################################################

method cp (Str $src, Str $dest) {

	$self->verbose("cp $src, $dest");
	return File::Copy::copy( $src, $dest );
}

method trimExt (Str $name) {

	my @parts = split( /\./, $name );
	if ( @parts > 1 ) {
		pop @parts;
		return join( '.', @parts );
	}

	# nothing to do
	return $name;
}

method splitPath (Str $path) {

	my @path = split( /\/+/, $path );
	return @path;
}

method xmllint (Str :$string,
                Str :$file) {

	if ( $string and $file ) {
		confess "string and file are mutually exclusive";
	}

	if ($string) {
		my @cmd = ( 'xmllint', '--format', '-' );
		my ( $stdout, $stderr, $exit ) =
		  $self->spawn->capture( cmd => \@cmd, stdin => $string );

		return $stdout;
	}
	elsif ($file) {
		my $cmd = "xmllint --format $file > $file.tmp";
		$self->spawn->spawn( cmd => $cmd );
		$self->mv( "$file.tmp", $file );
	}
	else {
		confess "no args provided";
	}
}

method chdir (Str $dir) {

	$self->Logger->verbose("chdir($dir)");
	my $orig_dir = getcwd;
	CORE::chdir($dir) or confess "failed to chdir to $dir: $!";

	return $orig_dir;
}

method chmod (Str $perm, Str $file) {

	$self->Logger->verbose("chmod($perm $file)");
	CORE::chmod( $perm, $file );
}

method mkdir (Str $dir, Str $perm?) {

	my @param = ($dir);
	push @param, { mode => $perm } if defined $perm;
	$self->Logger->verbose("mkpath($dir)");
	mkpath(@param);
}

method mv (Str $src, Str $dest) {

	$self->verbose("mv $src, $dest");
	return File::Copy::move( $src, $dest );
}

#method ls_zip (Str :$file!) {
#
#	my @ls;
#	my @cmd = ( 'unzip', '-l', $file );
#	my $pid = open my $readme, "-|", @cmd or die "couldn't fork: $!\n";
#
#	my $in_body = 0;
#
#	#my @orig;
#	while ( my $line = <$readme> ) {
#		chomp $line;
#
#		#    push @orig, $line;
#
#		if ( !$in_body and $line =~ /^\-\-\-/ ) {
#			$in_body = 1;
#		}
#		elsif ( $in_body and $line =~ /^\-\-\-/ ) {
#			$in_body = 0;
#		}
#		elsif ($in_body) {
#			my $copy = $line;
#			$copy =~ s/^\s+//;    # drop leading ws
#			my @parts = split( /\s+/, $copy );
#			shift @parts;         # drop length
#			shift @parts;         # drop date
#			shift @parts;         # drop time
#			my $filename = join ' ', @parts;
#			push @ls, $filename;
#		}
#	}
#
#	close($readme);
#
#	return @ls;
#}

method find (Str $dir!) {

	if ( !-d $dir ) {
		confess "dir $dir does not exist";
	}

	my @files;
	my $rule = Path::Iterator::Rule->new;
	my $next = $rule->iter($dir);

	while ( defined( my $file = $next->() ) ) {
		next if -d $file;
		push @files, $file;
	}

	return @files;
}

method rmdir (Str $dir) {

	if ( -d $dir ) {
		$self->Logger->debug("rmdir $dir");
		remove_tree($dir);
	}
}

method type (Str $filename!) {

	if ( $self->String->is_blank($filename) ) {
		confess "filename is empty";
	}

	if ( !-f $filename ) {
		confess "$filename does not exist";
	}

	my $info;
	my $magic = File::LibMagic->new();
	try {
		# apparently dies on error?
		$info = $magic->info_from_filename($filename);
	}
	catch {
		return "unknown: $_";
	};

	return $info->{description};
}

method unlink (Str $path) {

	if ( -f $path ) {
		$self->Logger->debug("unlink $path");
		unlink $path or confess "failed to unlink $path: $!";
	}
}

######################################################################

1;

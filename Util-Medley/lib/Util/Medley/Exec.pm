package Util::Medley::Exec;

use Modern::Perl;
use Moose;
use namespace::autoclean;
use Kavorka '-all';
use Data::Printer alias => 'pdump';
use Util::Medley::Crypt;

=head1 NAME

Util::Medley::Exec - proxy for cmdline to libs

=cut

method encryptStr (Str :$str!,
				   Str :$key) {

	my %a;
	$a{str} = $str;
	$a{key} = $key if $key;
	
	my $crypt = Util::Medley::Crypt->new;
	my $encrypted = $crypt->encryptStr(%a);
	say $encrypted;
}

method decryptStr (Str :$str!,
				   Str :$key) {

	my %a;
	$a{str} = $str;
	$a{key} = $key if $key;
	
	my $crypt = Util::Medley::Crypt->new;
	my $decrypted = $crypt->decryptStr(%a);
	say $decrypted;
}

1;

package Util::Medley::Crypt;

use Modern::Perl;
use Moose;
use namespace::autoclean;
use Method::Signatures;
use Data::Printer alias => 'pdump';
use Crypt::CBC;
use Crypt::Blowfish;

=head1 NAME

Util::Medley::Crypt - Class for simple encrypt/descrypt of strings.

=cut

=head1 SYNOPSIS

  my $key = 'abcdefghijklmnopqrstuvwxyz';
  my $str = 'foobar';
  
  my $encrypted_str = $self->encryptStr($key, $str);
 
  my $origin = $self->decryptStr($key, $encrypted_str); 
  
=cut

########################################################

=head1 DESCRIPTION

This class provides a thin wrapper around Crypt::CBC.
 
All methods confess on error.

=cut

########################################################

=head1 ATTRIBUTES

=head2 key (optional)

Key to use for encrypting/decrypting methods when one isn't provided.

=cut

has key =>(
	is => 'rw',
	isa => 'Str',
);

########################################################

=head2 decryptStr

Decrypts the provided string.

=head3 required args

=over

=item * str:  String to Decrypt.

=back

=head3 optional args

=over

=item * key:  Decryption key.

=back

=cut

method decryptStr (Str :$str!,
				   Str :$key) {

	$key = $self->_getKey($key);
	
    my $cipher = Crypt::CBC->new(-key => $key, -cipher => 'Blowfish');
    return $cipher->decrypt_hex($str);
}

=head2 encryptStr

Encrypts the provided string.

=head3 required args

=over

=item * str:  String to Encrypt.

=back

=head3 optional args

=over

=item * key:  Encryption key.

=back

=cut

method encryptStr (Str :$str!, 
				   Str :$key) {

	$key = $self->_getKey($key);

    my $cipher = Crypt::CBC->new(-key => $key, -cipher => 'Blowfish');
    return $cipher->encrypt_hex($str);
}

method _getKey (Str|Undef $key) {

	if ( !$key ) {
		if ( !$self->key ) {
			confess "must provide key";
		}

		return $self->key;
	}

	return $key;
}

1;
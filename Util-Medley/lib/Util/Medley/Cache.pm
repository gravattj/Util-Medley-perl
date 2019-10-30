package Util::Medley::Cache;

use Modern::Perl;
use Moose;
use Method::Signatures;
use namespace::autoclean;
use CHI;
use File::Path 'remove_tree';
use Data::Printer alias => 'pdump';

########################################################

=head1 NAME

Util::Medley::Cache - Simple caching mechanism.

=cut

########################################################

=head1 SYNOPSIS

  $self->set(namespace => 'unittest', 
             key       => 'test1', 
             data      => { foo => 'bar' });

  my $data = $self->get(namespace => 'unittest', 
                        key       => 'test1');

  my @keys = $self->getKeys(namespace => 'unittest');

  $self->delete(namespace => 'unittest', 
                key       => 'test1');

=cut

########################################################

=head1 DESCRIPTION

This class provides a thin wrapper around CHI.  The caching has 2 levels:
 
=over

=item * level 1 (memory)

=item * level 2 (disk)

=back

When fetching from the cache, level 1 (L1) is always checked first.  If the
requested object is not found, it searches the level 2 (L2) cache.

The cached data can be an object, reference, or string.

All methods confess on error.

=cut

########################################################

=head1 ATTRIBUTES

=head2 rootDir (optional)

Location of the L2 file cache.  

=over

=item default: $HOME/.util-medley/cache

=back

=cut

has rootDir => (
	is      => 'ro',
	isa     => 'Str',
	lazy    => 1,
	builder => '_buildRootDir'
);

=head2 enabled (optional)

Toggles caching on or off.

=over

=item default: 1

=back

=cut

has enabled => (
	is      => 'rw',
	isa     => 'Bool',
	lazy    => 1,
	builder => '_buildEnabled',
);

=head2 expireSecs (optional)

Sets the cache expiration.  

Default: 0 (never)

Env Var: MEDLEY_CACHE_DISABLED

=cut

has expireSecs => (

	# zero = never
	is      => 'rw',
	isa     => 'Int',
	default => 0,
);

=head2 namespace (optional)

Sets the cache namespace.  

=cut

has namespace => (
	is  => 'rw',
	isa => 'Str',
);

=head2 l1Enabled (optional)

Toggles the L1 cache on or off.

Default: 1

Env Var: MEDLEY_CACHE_L1_DISABLED

=cut

has l1Enabled => (
	is      => 'rw',
	isa     => 'Bool',
	lazy    => 1,
	builder => '_buildL1Enabled',
);

=head2 l2Enabled (optional) 

Toggles the L2 cache on or off.

Default: 1

Env Var: MEDLEY_CACHE_L2_DISABLED

=cut

has l2Enabled => (
	is      => 'rw',
	isa     => 'Bool',
	lazy    => 1,
	builder => '_buildL2Enabled',
);

##########################################################

has _chiObjects => (
	is      => 'rw',
	isa     => 'HashRef',
	default => sub { {} }
);

has _l1Cache => (
	is      => 'rw',
	isa     => 'HashRef',
	default => sub { {} }
);

##########################################################

=head1 METHODS

=head2 clear 

Clears all cache for a given namespace.

=head3 usage:

 clear( [ namespace => $ns ] )

=head3 args:

=over

=item * namespace: The cache namespace.

=back

=cut

method clear (Str :$namespace) {

	$self->_l1Clear(@_) if $self->l1Enabled;
	$self->_l2Clear(@_) if $self->l2Enabled;

	return 1;
}

=head2 delete 

Deletes a cache object.

=head3 usage:

 delete(
      key       => <string>,
    [ namespace => <string> ]
 )
  
=head3 args:

=over

=item * key: Unique identifier of the cache object.

=item * namespace: The cache namespace.

=back

=cut

method delete (Str :$key!,
               Str :$namespace) {

	$self->_l1Delete(@_) if $self->l1Enabled;
	$self->_l2Delete(@_) if $self->l1Enabled;

	return 1;
}

=head2 destroy

Deletes L1 cache and removes L2 from disk completely.

=head3 usage:

 destroy( [namespace => $ns] )
  
=head3 args:

=over

=item * namespace: The cache namespace.  

=back

=cut

method destroy (Str :$namespace) {

	$self->_l1Destroy(@_) if $self->l1Enabled;
	$self->_l2Destroy(@_) if $self->l1Enabled;

	return 1;
}

=head2 get

Gets a unique cache object.  Returns undef if not found.

=head3 usage:

 get(
      key       => $key,
    [ namespace => $ns ]
 )
 
=head3 args:

=over

=item * key: Unique identifier of the cache object.

=item * namespace: The cache namespace.  

=back

=cut

method get (Str :$namespace,
            Str :$key!) {

	if ( $self->l1Enabled ) {
		my $data = $self->_l1Get(@_);
		if ($data) {
			return $data;
		}
	}

	if ( $self->l2Enabled ) {
		my $data = $self->_l2Get(@_);
		if ($data) {
			$self->_l1Set(@_, data => $data);
			return $data;
		}
	}
}

=head2 getNamespaceDir

Gets the L2 cache dir.

=head3 usage:

 getNamespaceDir( [ namespace => $ns ] )
 
=head3 args:

=over

=item * namespace: The cache namespace.  

=back

=cut


method getNamespaceDir (Str $namespace?) {

	$namespace = $self->_getNamespace($namespace);

	return sprintf "%s/%s", $self->rootDir, $namespace;
}


=head2 set

Commits the data object to the cache.

=head3 usage:

 set(
      key       => $key,
      data      => $data,
    [ namespace => $ns ],
 )
   
=head3 args:

=over

=item * key: Unique identifier of the cache object.

=item * data: An object, reference, or string.

=item * namespace: The cache namespace.  

=back

=cut

method set (Str :$key!,
            Any :$data!,
            Str :$namespace) {

	$self->_l1Set(@_) if $self->l1Enabled;
	$self->_l2Set(@_) if $self->l2Enabled;

	return 1;
}

=head2 getKeys

Returns a list of cache keys.

=head3 usage:

 getKeys( [ namespace => $ns ] )
 
=head3 args:

=over

=item * namespace: The cache namespace.  

=back

=cut

method getKeys (Str :$namespace) {

	if ( $self->l2Enabled ) {
		return $self->_l2GetKeys(@_);
	}

	if ( $self->l1Enabled ) {
		return $self->_l1GetKeys(@_);
	}
}

############################################################

method _getChiObject (Str :$namespace) {

	$namespace = $self->_getNamespace($namespace);

	my $href = $self->_chiObjects;

	if ( exists $href->{$namespace} ) {
		return $href->{$namespace};
	}

	my %params = (
		driver    => 'File',
		root_dir  => $self->rootDir,
		namespace => $namespace,
	);

	my $chi = CHI->new(%params);
	$href->{$namespace} = $chi;
	$self->_chiObjects($href);

	return $chi;
}

######################################################################

method _buildL1Enabled {

	if ( $self->enabled ) {
		if ( !$ENV{MEDLEY_CACHE_L1_DISABLED} ) {
			return 1;
		}
	}

	return 0;
}

method _buildL2Enabled {

	if ( $self->enabled ) {
		if ( !$ENV{MEDLEY_CACHE_L2_DISABLED} ) {
			return 1;
		}
	}

	return 0;
}

method _buildRootDir {

	if ( defined $ENV{HOME} ) {
		return "$ENV{HOME}/.chi";
	}

	confess "unable to determine HOME env var";
}

method _buildEnabled {

	if ( $ENV{MEDLEY_CACHE_DISABLED} ) {
		return 0;
	}

	return 1;
}

method _l1Get (Str :$namespace,
                    Str :$key!) {

	$namespace = $self->_getNamespace($namespace);

	$self->_l1Expire(@_);

	my $l1 = $self->_l1Cache;
	if ( $l1->{$namespace}->{$key}->{data} ) {
		return $l1->{$namespace}->{$key}->{data};
	}

	return;
}

method _l1Expire (Str :$namespace,
                       Str :$key!) {

	$namespace = $self->_getNamespace($namespace);

	my $l1 = $self->_l1Cache;

	if ( $l1->{$namespace}->{$key} ) {
		my $href = $l1->{$namespace}->{$key};

		if ( $href->{expire_epoch} ) {    # zero or undef = never

			if ( time() > $href->{expire_epoch} ) {
				$self->_l1Delete(@_);
			}
		}
		else {
			# zero or undef = never
		}
	}

	return;
}

method _l1Delete (Str :$namespace,
                       Str :$key!) {

	$namespace = $self->_getNamespace($namespace);

	my $l1 = $self->_l1Cache;
	if ( $l1->{$namespace}->{$key} ) {
		delete $l1->{$namespace}->{$key};
	}

	return;
}

method _l1Destroy (Str :$namespace) {

	$self->_l1Clear(@_);
}

method _l2Destroy (Str :$namespace) {

	$namespace = $self->_getNamespace($namespace);

	my $href = $self->_chiObjects;
	if ($href->{$namespace}) {
		delete $href->{$namespace};
	}

	remove_tree($self->getNamespaceDir($namespace));	
}

method _l1Clear (Str :$namespace) {

	$namespace = $self->_getNamespace($namespace);

	my $l1 = $self->_l1Cache;
	$l1->{$namespace} = {};
}

method _l2Clear (Str :$namespace) {

	$namespace = $self->_getNamespace($namespace);

	my $chi = $self->_getChiObject( namespace => $namespace );
	$chi->clear;
}

method _l1Set (Str :$namespace,
                    Str :$key!,
                    Any :$data!) {
	
	$namespace = $self->_getNamespace($namespace);

	my $node = {
		data         => $data,
		expire_epoch => 0,
	};

	if ( $self->expireSecs ) {    # defined and greater than zero
		$node->{expire_epoch} = time + int( $self->expireSecs );
	}

	my $l1 = $self->_l1Cache;
	$l1->{$namespace}->{$key} = $node;

	return;
}

method _l1GetKeys (Str :$namespace) {

	$namespace = $self->_getNamespace($namespace);

	my $l1 = $self->_l1Cache;
	if ( $l1 and $l1->{$namespace} ) {
		return keys %{ $l1->{$namespace} };
	}
}

method _getExpireSecsForChi {

	if ( $self->expireSecs ) {    # defined and > 0
		return $self->expireSecs;
	}

	return 'never';
}

method _l2Set (Str :$namespace,
                    Str :$key!,
                    Any :$data!) {

	$namespace = $self->_getNamespace($namespace);

	my $chi = $self->_getChiObject( namespace => $namespace );

	return $chi->set( $key, $data, $self->_getExpireSecsForChi );
}

method _l2Delete (Str :$namespace,
                       Str :$key) {

	$namespace = $self->_getNamespace($namespace);

	my $chi = $self->_getChiObject( namespace => $namespace );
	$chi->expire($key);

	return;
}

method _l2Get (Str :$namespace,
               Str :$key) {

	$namespace = $self->_getNamespace($namespace);

	my $chi = $self->_getChiObject( namespace => $namespace );
	return $chi->get($key);
}

method _l2GetKeys (Str :$namespace) {

	$namespace = $self->_getNamespace($namespace);

	my @keys;

	my $chi = $self->_getChiObject( namespace => $namespace );
	if ($chi) {
		@keys = $chi->get_keys;
	}

	return @keys;
}

method _getNamespace (Str|Undef $namespace) {

	if ( !$namespace ) {
		if ( !$self->namespace ) {
			confess "must provide namespace";
		}

		return $self->namespace;
	}

	return $namespace;
}

1;

package Util::Medley::Roles::Cache;

use Modern::Perl;
use Moose::Role;
use Method::Signatures;
use CHI;
use Data::Printer alias => 'pdump';

########################################################

=head1 NAME

Util::Medley::Roles::Cache

Moose Role for simple caching. 

=cut

########################################################

our $VERSION = 0.001;

#=head1 VERSION 

#0.001

#=cut

########################################################

=head1 SYNOPSIS

  $self->cacheSet(namespace => 'unittest', 
                  cache_key => 'test1', 
                  data      => { foo => 'bar' });

  my $data = $self->cacheGet(namespace => 'unittest', 
                             cache_key => 'test1');

  my @keys = $self->cacheGetKeys(namespace => 'unittest');

  $self->cacheDelete(namespace => 'unittest', 
                     cache_key => 'test1');

=cut

########################################################

=head1 DESCRIPTION

This role provides a thin wrapper around CHI.  The caching has 2 levels:
 
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

=head2 cacheRootDir (optional)

Location of the L2 file cache.  

Default: $HOME/.util-medley/cache

=cut

has cacheRootDir => (
	is      => 'ro',
	isa     => 'Str',
	lazy    => 1,
	builder => '_buildCacheRootDir'
);

=head2 cacheEnabled (optional)

Toggles caching on or off.

Default: 1

=cut

has cacheEnabled => (
	is      => 'rw',
	isa     => 'Bool',
	lazy    => 1,
	builder => '_buildCacheEnabled',
);

=head2 cacheExpireSecs (optional)

Sets the cache expiration.  

Default: 0 (never)

Env Var: MEDLEY_CACHE_DISABLED

=cut

has cacheExpireSecs => (

	# zero = never
	is      => 'rw',
	isa     => 'Int',
	default => 0,
);

=head2 cacheNamespace (optional)

Sets the cache namespace.  

=cut

has cacheNamespace => (
	is      => 'rw',
	isa     => 'Str',
);

=head2 cacheL1Enabled (optional)

Toggles the L1 cache on or off.

Default: 1

Env Var: MEDLEY_CACHE_L1_DISABLED

=cut

has cacheL1Enabled => (
	is      => 'rw',
	isa     => 'Bool',
	lazy    => 1,
	builder => '_buildCacheL1Enabled',
);

=head2 cacheL2Enabled (optional) 

Toggles the L2 cache on or off.

Default: 1

Env Var: MEDLEY_CACHE_L2_DISABLED

=cut

has cacheL2Enabled => (
	is      => 'rw',
	isa     => 'Bool',
	lazy    => 1,
	builder => '_buildCacheL2Enabled',
);

#########################################################3

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

##################
# public methods #
##################

=head1 METHODS

=head2 cacheClear

Clears all cache for a given namespace.

=head3 optional args

=over

=item * namespace:  The cache namespace.  

=back

=cut

method cacheClear (Str :$namespace) { 
	
	$self->_cacheL1Clear(@_);
	$self->_cacheL2Clear(@_);

	return 1;
}

=head2 cacheDelete

Deletes a cache object.

=head3 required args

=over

=item * cache_key:  Unique identifier of the cache object.

=back

=head3 optional args

=over

=item * namespace:  The cache namespace.  

=back

=cut

method cacheDelete (Str :$cache_key!,
                    Str :$namespace) {

	$self->_cacheL1Delete(@_) if $self->cacheL1Enabled;
	$self->_cacheL2Delete(@_) if $self->cacheL1Enabled;

	return 1;
}

=head2 cacheGet

Gets a unique cache object.  Returns undef if not found.

=head3 required args

=over

=item * cache_key:  Unique identifier of the cache object.

=back

=head3 optional args

=over

=item * namespace:  The cache namespace.  

=back

=cut

method cacheGet (Str :$namespace,
                 Str :$cache_key!) {

	if ( $self->cacheL1Enabled ) {
		my $data = $self->_cacheL1Get(@_);
		if ($data) {
			return $data;
		}
	}

	if ( $self->cacheL2Enabled ) {
		my $data = $self->_cacheL2Get(@_);
		if ($data) {
			$self->_cacheL1Set(
				cache_key => $cache_key,
				data      => $data
			);
			
			return $data;
		}
	}
}

=head2 cacheSet

Commits the data 1an object to the Gets a unique cache object.  Returns undef if not found.

=head3 required args

=over

=item * cache_key:  Unique identifier of the cache object.

=item * data:  An object, reference, or string.

=back

=head3 optional args

=over

=item * namespace:  The cache namespace.  

=back

=cut

method cacheSet (Str :$cache_key!,
                 Any :$data!,
                 Str :$namespace) {

	$self->_cacheL1Set(@_) if $self->cacheL1Enabled;
	$self->_cacheL2Set(@_) if $self->cacheL2Enabled;

	return 1;
}

=head2 cacheGetKeys

Returns a list of cache keys.

=head3 optional args

=over

=item * namespace:  The cache namespace.  

=back

=cut

method cacheGetKeys (Str :$namespace) {

	if ( $self->cacheL2Enabled ) {
		return $self->_cacheL2GetKeys(@_);
	}

	if ( $self->cacheL1Enabled ) {
		return $self->_cacheL1GetKeys(@_);
	}
}

###################
# private methods #
###################

method _cacheGetChiObject (Str :$namespace) {

	$namespace = $self->_getNamespace($namespace);	

	my $href = $self->_chiObjects;

	if ( exists $href->{$namespace} ) {
		return $href->{$namespace};
	}

	my %params = (
		driver    => 'File',
		root_dir  => $self->cacheRootDir,
		namespace => $namespace,
	);

	my $chi = CHI->new(%params);
	$href->{$namespace} = $chi;
	$self->_chiObjects($href);

	return $chi;
}

######################################################################

method _buildCacheL1Enabled {

	if ( $self->cacheEnabled ) {
		if ( !$ENV{MEDLEY_CACHE_L1_DISABLED} ) {
			return 1;
		}
	}

	return 0;
}

method _buildCacheL2Enabled {

	if ( $self->cacheEnabled ) {
		if ( !$ENV{MEDLEY_CACHE_L2_DISABLED} ) {
			return 1;
		}
	}

	return 0;
}

method _buildCacheRootDir {

	if ( defined $ENV{HOME} ) {
		return "$ENV{HOME}/.chi";
	}

	confess "unable to determine HOME env var";
}

method _cacheGetNamespaceDir (Str $namespace) {

	$namespace = $self->_getNamespace($namespace);	

	return sprintf "%s/%s", $self->cacheRootDir, $namespace;
}

method _buildCacheEnabled {

	if ( $ENV{MEDLEY_CACHE_DISABLED} ) {
		return 0;
	}

	return 1;
}

method _cacheL1Get (Str :$namespace,
                    Str :$cache_key!) {

	$namespace = $self->_getNamespace($namespace);	

	$self->_cacheL1Expire(@_);

	my $l1 = $self->_l1Cache;
	if ( $l1->{$namespace}->{$cache_key}->{data} ) {
		return $l1->{$namespace}->{$cache_key}->{data};
	}

	return;
}

method _cacheL1Expire (Str :$namespace,
                       Str :$cache_key!) {

	$namespace = $self->_getNamespace($namespace);	

	my $l1 = $self->_l1Cache;

	if ( $l1->{$namespace}->{$cache_key} ) {
		my $href = $l1->{$namespace}->{$cache_key};

		if ( $href->{expire_epoch} ) {    # zero or undef = never

			if ( time() > $href->{expire_epoch} ) {
				$self->_cacheL1Delete(@_);
			}
		}
		else {
			# zero or undef = never
		}
	}

	return;
}

method _cacheL1Delete (Str :$namespace,
                       Str :$cache_key!) {

	$namespace = $self->_getNamespace($namespace);	

	my $l1 = $self->_l1Cache;
	if ( $l1->{$namespace}->{$cache_key} ) {
		delete $l1->{$namespace}->{$cache_key};
	}

	return;
}

method _cacheL1Clear (Str :$namespace) {

	$namespace = $self->_getNamespace($namespace);	

	my $l1 = $self->_l1Cache;
	$l1->{$namespace} = {};
}

method _cacheL2Clear (Str :$namespace) {

	$namespace = $self->_getNamespace($namespace);	

	my $chi = $self->_cacheGetChiObject( namespace => $namespace );
	$chi->clear;
}

method _cacheL1Set (Str :$namespace,
                    Str :$cache_key!,
                    Any :$data!) {

	$namespace = $self->_getNamespace($namespace);	

	my $node = {
		data         => $data,
		expire_epoch => 0,
	};

	if ( $self->cacheExpireSecs ) {    # defined and greater than zero
		$node->{expire_epoch} = time + int( $self->cacheExpireSecs );
	}

	my $l1 = $self->_l1Cache;
	$l1->{$namespace}->{$cache_key} = $node;

	return;
}

method _cacheL1GetKeys (Str :$namespace) {

	$namespace = $self->_getNamespace($namespace);	

	my $l1 = $self->_l1Cache;
	if ( $l1 and $l1->{$namespace} ) {
		return keys %{ $l1->{$namespace} };
	}
}

method _cacheGetExpireSecsForChi {

	if ( $self->cacheExpireSecs ) {    # defined and > 0
		return $self->cacheExpireSecs;
	}

	return 'never';
}

method _cacheL2Set (Str :$namespace,
                    Str :$cache_key!,
                    Any :$data!) {

	$namespace = $self->_getNamespace($namespace);	

	my $chi = $self->_cacheGetChiObject( namespace => $namespace );
	
	return $chi->set( $cache_key, $data, $self->_cacheGetExpireSecsForChi );
}

method _cacheL2Delete (Str :$namespace,
                       Str :$cache_key) {

	$namespace = $self->_getNamespace($namespace);	

	my $chi = $self->_cacheGetChiObject( namespace => $namespace );
	$chi->expire($cache_key);

	return;
}

method _cacheL2Get (Str :$namespace,
                    Str :$cache_key) {

	$namespace = $self->_getNamespace($namespace);	

	my $chi = $self->_cacheGetChiObject( namespace => $namespace );
	return $chi->get($cache_key);
}

method _cacheL2GetKeys (Str :$namespace) {

	$namespace = $self->_getNamespace($namespace);	

	my @keys;

	my $chi = $self->_cacheGetChiObject( namespace => $namespace );
	if ($chi) {
		@keys = $chi->get_keys;
	}

	return @keys;
}

method _getNamespace (Str|Undef $namespace) {

	if (!$namespace) {
		if (!$self->cacheNamespace) {	
			confess "must provide namespace";	
		}
		
		$namespace = $self->cacheNamespace;
	}
	
	return $namespace;	
}

1;

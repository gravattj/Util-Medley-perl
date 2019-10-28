package Util::Medley::Roles::Cache;

use Modern::Perl;
use Moose::Role;
use Method::Signatures;
use CHI;
use Data::Printer alias => 'pdump';

########################################################

has cache_enabled => (
    is      => 'rw',
    isa     => 'Bool',
    lazy    => 1,
    builder => '_build_cache_enabled',
);

has cache_l1_enabled => (
    is      => 'rw',
    isa     => 'Bool',
    lazy    => 1,
    builder => '_build_cache_l1_enabled',
);

has cache_l2_enabled => (
    is      => 'rw',
    isa     => 'Bool',
    lazy    => 1,
    builder => '_build_cache_l2_enabled',
);

has cache_root_dir => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_cache_root_dir'
);

has cache_expire_secs => (

    # zero = never
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

#########################################################3

has _chi_objects => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} }
);

has _l1_cache => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} }
);

##################
# public methods #
##################

method cache_get (Str :$namespace!,
                  Str :$cache_key!) {

    if ( $self->cache_l1_enabled ) {
        my $data = $self->_cache_l1_get(@_);
        if ($data) {
            return $data;
        }
    }

    if ( $self->cache_l2_enabled ) {
        my $data = $self->_cache_l2_get(@_);
        if ($data) {
            $self->_cache_l1_set( namespace => $namespace, cache_key => $cache_key, data => $data );
            return $data;
        }
    }
}

method cache_delete (Str :$namespace!,
                     Str :$cache_key) {

    if (!$cache_key) {
        my $dir = $self->_cache_get_namespace_dir($namespace);
                        
    }
    else {
    $self->_cache_l1_delete(@_) if $self->cache_l1_enabled;
    $self->_cache_l2_delete(@_) if $self->cache_l1_enabled;
    }
}

method cache_set (Str :$namespace!,
                  Str :$cache_key!,
                  Any :$data) {

    $self->_cache_l1_set(@_) if $self->cache_l1_enabled;
    $self->_cache_l2_set(@_) if $self->cache_l2_enabled;
}

method cache_get_keys (Str :$namespace!) {

    if ( $self->cache_l2_enabled ) {
        return $self->_cache_l2_get_keys(@_);
    }

    if ( $self->cache_l1_enabled ) {
        return $self->_cache_l1_get_keys(@_);
    }
}

###################
# private methods #
###################

method _cache_get_chi_object (Str :$namespace) {

    my $href = $self->_chi_objects;

    if ( exists $href->{$namespace} ) {
        return $href->{$namespace};
    }

    my %params = (
        driver    => 'File',
        root_dir  => $self->cache_root_dir,
        namespace => $namespace,
    );

    my $chi = CHI->new(%params);
    $href->{$namespace} = $chi;
    $self->_chi_objects($href);

    return $chi;
}

######################################################################

method _build_cache_l1_enabled {

    if ( $self->cache_enabled ) {
        if ( !$ENV{MEDLEY_CACHE_L1_DISABLED} ) {
            return 1;
        }
    }

    return 0;
}

method _build_cache_l2_enabled {

    if ( $self->cache_enabled ) {
        if ( !$ENV{MEDLEY_CACHE_L2_DISABLED} ) {
            return 1;
        }
    }

    return 0;
}

method _build_cache_root_dir {

    if ( defined $ENV{HOME} ) {
        return "$ENV{HOME}/.chi";
    }

    confess "unable to determine HOME env var";
}

method _cache_get_namespace_dir (Str $ns!) {
    
    return sprintf "%s/%s", $self->cache_root_dir, $ns;
}

method _build_cache_enabled {

    if ( $ENV{MEDLEY_CACHE_DISABLED} ) {
        return 0;
    }

    return 1;
}

method _cache_l1_get (Str :$namespace!,
                      Str :$cache_key!) {

    $self->_cache_l1_expire(@_);

    my $l1 = $self->_l1_cache;
    if ( $l1->{$namespace}->{$cache_key}->{data} ) {
        return $l1->{$namespace}->{$cache_key}->{data};
    }

    return;
}

method _cache_l1_expire ( Str :$namespace!,
                          Str :$cache_key! ) {

    my $l1 = $self->_l1_cache;

    if ( $l1->{$namespace}->{$cache_key} ) {
        my $href = $l1->{$namespace}->{$cache_key};

        if ( $href->{expire_epoch} ) {    # zero or undef = never

            if ( time() > $href->{expire_epoch} ) {
                $self->_cache_l1_delete(@_);
            }
        }
        else {
            # zero or undef = never
        }
    }

    return;
}

method _cache_l1_delete (Str :$namespace!,
                         Str :$cache_key!) {

    my $l1 = $self->_l1_cache;
    if ( $l1->{$namespace}->{$cache_key} ) {
        delete $l1->{$namespace}->{$cache_key};
    }

    return;
}

method _cache_l1_set (Str :$namespace!,
                      Str :$cache_key!,
                      Any :$data!) {

    my $node = {
        data         => $data,
        expire_epoch => 0,
    };

    if ( $self->cache_expire_secs ) {    # defined and greater than zero
        $node->{expire_epoch} = time + int( $self->cache_expire_secs );
    }

    my $l1 = $self->_l1_cache;
    $l1->{$namespace}->{$cache_key} = $node;

    return;
}

method _cache_l1_get_keys (Str :$namespace!) {

    my $l1 = $self->_l1_cache;
    if ( $l1 and $l1->{$namespace} ) {
        return keys %{ $l1->{$namespace} };
    }
}

method _cache_get_expire_secs_for_chi {

    if ( $self->cache_expire_secs ) {    # defined and > 0
        return $self->cache_expire_secs;
    }

    return 'never';
}

method _cache_l2_set (Str :$namespace!,
                      Str :$cache_key!,
                      Any :$data!) {

    my $chi = $self->_cache_get_chi_object( namespace => $namespace );
    return $chi->set( $cache_key, $data, $self->_cache_get_expire_secs_for_chi );
}

method _cache_l2_delete (Str :$namespace!,
                         Str :$cache_key) {

    my $chi = $self->_cache_get_chi_object( namespace => $namespace );
    $chi->expire($cache_key);

    return;
}

method _cache_l2_get (Str :$namespace!,
                      Str :$cache_key) {

    my $chi = $self->_cache_get_chi_object( namespace => $namespace );
    return $chi->get($cache_key);
}

method _cache_l2_get_keys (Str :$namespace!) {

    my @keys;

    my $chi = $self->_cache_get_chi_object( namespace => $namespace );
    if ($chi) {
        @keys = $chi->get_keys;
    }

    return @keys;
}

1;

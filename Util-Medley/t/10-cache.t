use Test2::V0;
use Test2::Plugin::DieOnFail;
use Modern::Perl;
use Util::Medley::Cache;
use Data::Printer alias => 'pdump';

$SIG{__WARN__} = sub { die @_ };

#####################################
# coNstructor
#####################################

my $Ns   = 'unittest';
my @Keys = qw(item1 item2 item3 item4);
my @Data = ( 'foobar', { biz => 'baz' }, [ x => 'y' ], [ 1, 2 ] );

my $c = Util::Medley::Cache->new;
ok($c);

$c = Util::Medley::Cache->new( namespace => $Ns );
ok($c);

#####################################
# set
#####################################

test_set( Util::Medley::Cache->new );
test_set( Util::Medley::Cache->new( namespace => $Ns ) );

#####################################
# get
#####################################

test_get( Util::Medley::Cache->new );
test_get( Util::Medley::Cache->new( namespace => $Ns ) );

#####################################
# getKeys
#####################################

test_getKeys( Util::Medley::Cache->new );
test_getKeys( Util::Medley::Cache->new( namespace => $Ns ) );

#####################################
# delete
#####################################

test_delete( Util::Medley::Cache->new );
test_delete( Util::Medley::Cache->new( namespace => $Ns ) );

#####################################
# clear
#####################################

test_clear( Util::Medley::Cache->new );
test_clear( Util::Medley::Cache->new( namespace => $Ns ) );

#
# tests without any attributes passed in
#
$c = Util::Medley::Cache->new;

# add and verify seed data
ok( $c->destroy( namespace => $Ns ) );
$c->set( namespace => $Ns, key => 'item1', data => { foo => 'bar' } );
$c->set( namespace => $Ns, key => 'item2', data => { biz => 'baz' } );
ok( my @keys = $c->getKeys( namespace => $Ns ) );
ok( @keys == 2 );

# happy path
ok( $c->clear( namespace => $Ns ) );

# verify clear worked
@keys = $c->getKeys( namespace => $Ns );
ok( @keys == 0 );

#
# tests with namespace attribute set
#
$c = Util::Medley::Cache->new( namespace => $Ns );

# add and verify seed data
ok( $c->destroy( namespace => $Ns ) );
$c->set( namespace => $Ns, key => 'item1', data => { foo => 'bar' } );
$c->set( namespace => $Ns, key => 'item2', data => { biz => 'baz' } );
ok( @keys = $c->getKeys );
ok( @keys == 2 );

# happy path
ok( $c->clear );

# verify clear worked
@keys = $c->getKeys;
ok( @keys == 0 );

# Note: is does deep checking, unlike the 'is' from Test::More.
#is(...);

done_testing;

######################################################################

sub test_clear {

	my $c = shift;

	nuke_data();
	seed_data();

	if ( !$c->namespace ) {

		ok( my @curr = $c->getKeys( namespace => $Ns ) );
	}
	else {

	}
}

sub nuke_data {

	my $c = Util::Medley::Cache->new;
	ok( $c->destroy( namespace => $Ns ) );
}

sub seed_data {

	my $c = Util::Medley::Cache->new;
	$c->set( namespace => $Ns, key => $Keys[0], data => $Data[0] );
	$c->set( namespace => $Ns, key => $Keys[1], data => $Data[1] );
	$c->set( namespace => $Ns, key => $Keys[2], data => $Data[2] );
	$c->set( namespace => $Ns, key => $Keys[3], data => $Data[3] );
}

sub test_set {

	my $c = shift;

	nuke_data();
	
	if ( !$c->namespace ) {

		# should succeed
		ok( $c->set( namespace => $Ns, key => $Keys[0], data => $Data[0] ) );

		# should fail
		eval { $c->set( key => $Keys[1], $Data[1] ) };
		ok($@);
	}
	else {

		# should succeed
		ok( $c->set( key => $Keys[1], data => $Data[1] ) );
	}
}

sub test_getKeys {

	my $c = shift;

	nuke_data();
	seed_data();
		
	if ( !$c->namespace ) {

		# should succeed
		ok( my @keys = $c->getKeys( namespace => $Ns ) );
		is(@keys, @Keys);
		
		# should fail
		eval { $c->getKeys };
		ok($@);
	}
	else {

		# should succeed
		ok( my @keys = $c->getKeys );
		is( @keys, @Keys );
	}
}

sub test_delete {

	my $c = shift;

	nuke_data();
	seed_data();
	
	if ( !$c->namespace ) {

		# should succeed
		ok( $c->delete( namespace => $Ns, key => $Keys[0] ) );
		ok( !$c->get( namespace => $Ns, key => $Keys[0] ) );

		# should succeed
		ok( $c->delete( namespace => $Ns, key => 'doesnotexist' ) );

		# should fail
		eval { $c->delete( key => $Keys[1] ) };
		ok($@);
	}
	else {

		# should succeed
		ok( $c->delete( key => $Keys[2] ) );
		ok( !$c->get( key => $Keys[2] ) );

		# should succeed
		ok( $c->delete( key => 'doesnotexist' ) );
	}
}

sub test_get {

	my $c = shift;

	nuke_data();
	seed_data();
	
	if ( !$c->namespace ) {

		# should succeed
		ok( my $data = $c->get( namespace => $Ns, key => $Keys[2] ) );
		is( $data, $Data[2]);

		# should fail
		eval { $c->get( key => $Keys[3] ) };
		ok($@);
	}
	else {

		# should succeed
		ok( my $data = $c->get( key => $Keys[2] ) );
		is( $data, $Data[2] );

		# should succeed
		eval { $c->get( key => $Keys[3] ) };
		ok( !$@ );
	}
}

use Test2::V0;
use Test2::Plugin::DieOnFail;
use Modern::Perl;
use Util::Medley::Cache;
use Data::Printer alias => 'pdump';

#####################################
# constructor
#####################################

my $ns = 'unittest';

my $c = Util::Medley::Cache->new;
ok($c);

$c = Util::Medley::Cache->new( namespace => $ns );
ok($c);

ok($c->destroy);  # nuke any residue
ok(! -d $c->getNamespaceDir );

#####################################
# set
#####################################

#
# tests without any attributes passed in
#
$c = Util::Medley::Cache->new;

# happy path
ok(
	$c->set(
		namespace => $ns,
		key => 'test1',
		data      => { foo => 'bar' }
	)
);

# missing namespace
eval { $c->set( key => 'test1', data => { foo => 'bar' } ) };
ok($@);


#
# tests with namespace attribute set
#
$c = Util::Medley::Cache->new( namespace => $ns );

# happy path
ok( $c->set( key => 'test2', data => { foo => 'bar' } ) );

#####################################
# get
#####################################

#
# tests without any attributes passed in
#
$c = Util::Medley::Cache->new;

# happy path
ok( my $data = $c->get(namespace => $ns, key => 'test1' ) );

# missing namespace
eval { $c->get( key => 'test1') };
ok($@);

#
# tests with namespace attribute set
#
$c = Util::Medley::Cache->new( namespace => $ns );

# happy path
ok( $data = $c->get(key => 'test1' ) );
ok(ref($data) eq 'HASH');

#####################################
# getKeys
#####################################

#
# tests without any attributes passed in
#
$c = Util::Medley::Cache->new;

# happy path
ok( my @keys = $c->getKeys( namespace => $ns ) );
ok( @keys == 2 );

# missing namespace
eval { @keys = $c->getKeys };
ok ($@);
	
#
# tests with namespace attribute set
#
$c = Util::Medley::Cache->new( namespace => $ns );

# happy path
ok( @keys = $c->getKeys );
ok( @keys == 2 );

#####################################
# delete
#####################################

#
# tests without any attributes passed in
#
$c = Util::Medley::Cache->new;

# happy path
ok($c->delete(namespace => $ns, key => 'test1'));

# verify delete
$data = $c->get(namespace => $ns, key => 'test1');
ok(!$data);

eval { $c->delete(key => 'test1'); };
ok($@);

# delete non existent item
ok($c->delete(namespace => $ns, key => 'bogus'));

#
# tests with namespace attribute set
#
$c = Util::Medley::Cache->new( namespace => $ns );

ok( $c->delete( key => 'test2' ) );

#####################################
# clear
#####################################

#
# tests without any attributes passed in
#
$c = Util::Medley::Cache->new;

# add and verify seed data
ok($c->destroy(namespace=>$ns));
$c->set(namespace => $ns, key => 'item1', data => { foo => 'bar' });
$c->set(namespace => $ns, key => 'item2', data => { biz => 'baz' });
ok(@keys = $c->getKeys(namespace => $ns));
ok(@keys == 2);

# happy path
ok($c->clear(namespace => $ns));

# verify clear worked
@keys = $c->getKeys(namespace => $ns);
ok(@keys == 0);

#
# tests with namespace attribute set
#
$c = Util::Medley::Cache->new( namespace => $ns );

# add and verify seed data
ok($c->destroy(namespace=>$ns));
$c->set(namespace => $ns, key => 'item1', data => { foo => 'bar' });
$c->set(namespace => $ns, key => 'item2', data => { biz => 'baz' });
ok(@keys = $c->getKeys);
ok(@keys == 2);

# happy path
ok($c->clear);

# verify clear worked
@keys = $c->getKeys;
ok(@keys == 0);

# Note: is does deep checking, unlike the 'is' from Test::More.
#is(...);

done_testing;

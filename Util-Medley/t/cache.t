use Test2::V0;
use Test2::Plugin::DieOnFail;
use Modern::Perl;
use Util::Medley::Cache;
use Data::Printer alias => 'pdump';

#####################################
# happy path 1
#####################################

my $ns = 'unittest';

my $c = Util::Medley::Cache->new;
ok($c);

ok($c->cacheSet(namespace => $ns, cache_key => 'test1', data => { foo => 'bar' })) ;

ok(my $data = $c->cacheGet(namespace => $ns, cache_key => 'test1'));

ok(my @keys = $c->cacheGetKeys(namespace => $ns));
ok(@keys == 1);

ok($c->cacheDelete(namespace => $ns, cache_key => 'test1'));

ok($c->cacheClear(namespace => $ns));

#####################################
# happy path 2
####################################

$c = Util::Medley::Cache->new(cacheNamespace => 'myns');
ok($c);

ok($c->cacheSet(cache_key => 'test1', data => { foo => 'bar' })) ;

ok($data = $c->cacheGet(cache_key => 'test1'));

ok(@keys = $c->cacheGetKeys());
ok(@keys == 1);

ok($c->cacheDelete(cache_key => 'test1'));

ok($c->cacheClear);

#####################################
# not happy path
####################################

# Note: is does deep checking, unlike the 'is' from Test::More.
#is(...);

done_testing;

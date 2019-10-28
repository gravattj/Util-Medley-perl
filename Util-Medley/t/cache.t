use Test2::V0;
use Test2::Plugin::DieOnFail;
use Modern::Perl;
use Util::Medley::Cache;


my $c = Util::Medley::Cache->new;
ok($c);
 
# Note: is does deep checking, unlike the 'is' from Test::More.
#is(...);
 
 
done_testing;

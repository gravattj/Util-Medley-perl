use Test::More;
use Modern::Perl;
use Util::Medley::Hostname;
use Data::Printer alias => 'pdump';

my $util = Util::Medley::Hostname->new;
ok($util);

my ($h, $d) = $util->parseHostname('foobar.example.com');
ok($h eq 'foobar');
ok($d eq 'example.com');

my $bool = $util->isFqdn('foobar.example.com');
ok($bool);

$bool = $util->isFqdn('foobar');
ok(!$bool);

done_testing;

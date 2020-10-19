#!perl

use Test::More;
use Modern::Perl;
use Data::Printer alias => 'pdump';
use Util::Medley::File;
use Util::Medley::Spawn;
use English;

###################################################

use vars qw();

###################################################

use_ok('Util::Medley::PkgManager::RPM');

my $file = Util::Medley::File->new;

my $rpm = Util::Medley::PkgManager::RPM->new;
ok($rpm);

SKIP: {
	my $path = $file->which('rpm');
	skip "can't find rpm exe" if !$path;

    doRpmQueryAll($rpm);
    doRpmQueryList($rpm);
}

done_testing;

###################################################

sub doRpmQueryList {
    my $rpm = shift;
    
    my $all = $rpm->queryAll;
    my $rpmName = shift @$all;
    
    my $list = $rpm->queryList($rpmName);
    ok(ref($list) eq 'ARRAY');
}

sub doRpmQueryAll {
    my $rpm = shift;
    
    my $aref = $rpm->queryAll;
    ok(ref($aref) eq 'ARRAY');
    ok(@$aref > 0); # there should be at least one rpm installed
}


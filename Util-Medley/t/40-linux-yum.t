#!perl

use Test::More;
use Modern::Perl;
use Data::Printer alias => 'pdump';
use Util::Medley::File;

###################################################

use vars qw();

###################################################

use_ok('Util::Medley::Linux::Yum');

my $yum = Util::Medley::Linux::Yum->new;
ok($yum);

SKIP: {
	my $file    = Util::Medley::File->new;
	my $yumPath = $file->which('yum');

	skip "can't find yum exe" if !$yumPath;

    doTests($yum);
}

done_testing;

###################################################

sub doTests {
    my ($yum) = @_;	
    
    my $aref = $yum->repoList(enabled => 1, disabled => 1);
    isa_ok($aref, 'ARRAY');
    
    foreach my $repo (@$aref) {
        isa_ok($repo, 'HASH');	
        ok($repo->{repoId});
        ok($repo->{repoStatus});
    }
}


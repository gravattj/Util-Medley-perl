use Test2::V0;
use Test2::Plugin::DieOnFail;
use Modern::Perl;
use Util::Medley::File;
use Data::Printer alias => 'pdump';

#####################################
# constructor
#####################################

my $file = Util::Medley::File->new;
ok($file);


done_testing;

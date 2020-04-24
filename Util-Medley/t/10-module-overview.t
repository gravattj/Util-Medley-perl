use Test::More;
use Modern::Perl;
use Data::Printer alias => 'pdump';
use Util::Medley::Module::Overview;

$SIG{__WARN__} = sub { die @_ };

#####################################
# coNstructor
#####################################

my $mo =
  Util::Medley::Module::Overview->new( moduleName => 'Util::Medley::String', );
ok($mo);

my @imported = $mo->getImportedModules;
ok(@imported);

my @parents = $mo->getParents;
ok(@parents);

my @methods = $mo->getMethods;
ok(@methods);

my @inherited = $mo->getInheritedMethods;
ok(@inherited);

$mo = Util::Medley::Module::Overview->new(
	moduleName                => 'Util::Medley::String',
	pruneInheritedMethodsFrom => ['Moose::Object']
);
ok($mo);

ok( scalar $mo->getImported == scalar @imported );
ok( scalar $mo->getParents == scalar @parents );
ok( scalar $mo->getMethods == scalar @methods );
ok( scalar $mo->getInheritedMethods == 0 );

done_testing;

######################################################################


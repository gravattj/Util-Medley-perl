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

my @publicMethods = $mo->getPublicMethods;
ok(@publicMethods);

my @privateMethods = $mo->getPrivateMethods;

my @inheritedPublicMethods = $mo->getInheritedPublicMethods;
pdump @inheritedPublicMethods;

my @inheritedPrivateMethods = $mo->getInheritedPrivateMethods;
pdump @inheritedPrivateMethods;

$mo = Util::Medley::Module::Overview->new(
	moduleName  => 'Util::Medley::String',
	hideModules => ['Moose::Object']
);
ok($mo);

ok( $mo->getImportedModules == @imported );
ok( $mo->getParents == @parents );
ok( $mo->getPublicMethods == @publicMethods );
ok( $mo->getPrivateMethods == @privateMethods );
ok( $mo->getInheritedPublicMethods == @inheritedPublicMethods );
ok( $mo->getInheritedPrivateMethods == @inheritedPrivateMethods );

done_testing;

######################################################################


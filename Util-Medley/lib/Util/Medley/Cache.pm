package Util::Medley::Cache;

use Modern::Perl;
use Moose;
use Method::Signatures;
use namespace::autoclean;
use Data::Printer alias => 'pdump';

with 'Util::Medley::Roles::Cache';

1;

use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.05

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/MooseX/Meta/TypeCoercion/Structured.pm',
    'lib/MooseX/Meta/TypeCoercion/Structured/Optional.pm',
    'lib/MooseX/Meta/TypeConstraint/Structured.pm',
    'lib/MooseX/Meta/TypeConstraint/Structured/Optional.pm',
    'lib/MooseX/Types/Structured.pm',
    'lib/MooseX/Types/Structured/MessageStack.pm',
    'lib/MooseX/Types/Structured/OverflowHandler.pm'
);

notabs_ok($_) foreach @files;
done_testing;

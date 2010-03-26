use strict;
use warnings;
use Test::More;

use MooseX::Types::Moose qw(Int Num);
use MooseX::Types::Structured qw(Map);

my $type = Map[ Int, Num ];

ok($type->assert_valid({ 10 => 10.5 }), "simple Int -> Num mapping");

eval { $type->assert_valid({ 10.5 => 10.5 }) };
like($@, qr{value 10\.5}, "non-Int causes rejection on key");

eval { $type->assert_valid({ 10 => "ten and a half" }) };
like("$@", qr{value ten and a half}, "non-Num value causes rejection on value");

ok($type->assert_valid({ }), "empty hashref is a valid mapping of any sort");

done_testing;


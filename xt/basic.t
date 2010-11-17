use Benchmark ':hireswallclock', qw(:all);
use MooseX::Types::Moose qw(Str Int ArrayRef Object HashRef Any);
use MooseX::Types::Structured qw(Tuple Dict slurpy);
use Moose::Util::TypeConstraints;


timethese(4000, {
    Complex => sub { (Tuple[Tuple[Object,Int,Object,ArrayRef[Int],slurpy ArrayRef[Any]],Dict[]])->check([1,2,3]) },

});

my $assigned_int;
my $assigned_array;
my $assigned_hash;
my $assigned_tuple;
my $assigned_dict;

my $subtype_int;
my $subtype_array;
my $subtype_hash;
my $subtype_tuple;
my $subtype_dict;

timethese( 5000, {
    AssignTypes => sub {
        $assigned_int = Int;
        $assigned_array = ArrayRef[Int];
        $assigned_hash = HashRef[Int];
        $assigned_tuple = Tuple[Int];
        $assigned_dict = Dict[first=>Int];
    },
    Subtypes => sub {
        $subtype_int = subtype as Int;
        $subtype_array = subtype as ArrayRef[Int];
        $subtype_hash = subtype as HashRef[Int];
        $subtype_tuple = subtype as Tuple[Int];
        $subtype_dict = subtype as Dict[first=>Int];
    },
});

use Data::Dumper;
warn Dumper {
    Assigned => ref $assigned_array,
    Subtype => ref $subtype_array,
    Inline => ref (ArrayRef[Int]),
};

timethese( 250000, {

    IntAssigned => sub { $assigned_int->check(1) },
    ArrayAssigned => sub { $assigned_array->check([1]) },
    HashAssigned => sub { $assigned_hash->check({first=>1}) },
    TupleAssigned => sub { $assigned_tuple->check([1]) },
    DictAssigned => sub { $assigned_dict->check({first=>1}) },

    IntSubtype => sub { $subtype_int->check(1) },
    ArraySubtype => sub { $subtype_array->check([1]) },
    HashSubtype => sub { $subtype_hash->check({first=>1}) },
    TupleSubtype => sub { $subtype_tuple->check([1]) },
    DictSubtype => sub { $subtype_dict->check({first=>1}) },

    IntInline => sub { (Int)->check(1) },
    ArrayInline => sub { (ArrayRef[Int])->check([1]) },
    HashInline => sub { (HashRef[Int])->check({first=>1}) },
    TupleInline => sub { (Tuple[Int])->check([1]) },
    DictInline => sub { (Dict[first=>Int])->check({first=>1}) },

});


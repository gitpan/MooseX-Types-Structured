package MooseX::Types::Structured;

use 5.008;
use Moose::Util::TypeConstraints;
use MooseX::Meta::TypeConstraint::Structured;
use MooseX::Types -declare => [qw(Dict Tuple Optional)];

our $VERSION = '0.06';
our $AUTHORITY = 'cpan:JJNAPIORK';

=head1 NAME

MooseX::Types::Structured - Structured Type Constraints for Moose

=head1 SYNOPSIS

The following is example usage for this module.

    package MyApp::MyClass;
	
    use Moose;
    use MooseX::Types::Moose qw(Str Int);
    use MooseX::Types::Structured qw(Dict Optional);

    ## A name has a first and last part, but middle names are not required
    has name => (
        isa=>Dict[
            first=>Str,
            last=>Str,
            middle=>Optional[Str],
        ],
    );

Then you can instantiate this class with something like:

    my $john = MyApp::MyClass->new(
        name => {
            first=>'John',
            middle=>'James'
            last=>'Napiorkowski',
        },
    );

Or with:

    my $vanessa = MyApp::MyClass->new(
        name => {
            first=>'Vanessa',
            last=>'Li'
        },
    );

But all of these would cause a constraint error for the 'name' attribute:

    MyApp::MyClass->new( name=>'John' );
    MyApp::MyClass->new( name=>{first_name=>'John'} );
    MyApp::MyClass->new( name=>{first_name=>'John', age=>39} );
    MyApp::MyClass->new( name=>{first=>'Vanessa', middle=>[1,2], last=>'Li'} );
    
Please see the test cases for more examples.

=head1 DESCRIPTION

A structured type constraint is a standard container L<Moose> type constraint,
such as an arrayref or hashref, which has been enhanced to allow you to
explicitly name all the allow type constraints inside the structure.  The
generalized form is:

    TypeConstraint[@TypeParameters|%TypeParameters]

Where 'TypeParameters' is an array or hash of L<Moose::Meta::TypeConstraint>.

This type library enables structured type constraints. It is built on top of the
L<MooseX::Types> library system, so you should review the documentation for that
if you are not familiar with it.

=head2 Comparing Parameterized types to Structured types

Parameterized constraints are built into core Moose and you are probably already
familuar with the type constraints 'HashRef' and 'ArrayRef'.  Structured types
have similar functionality, so their syntax is  likewise similar. For example,
you could define a parameterized constraint like:

    subtype ArrayOfInts,
     as Arrayref[Int];

which would constraint a value to something like [1,2,3,...] and so on.  On the
other hand, a structured type constraint explicitly names all it's allowed
'internal' type parameter constraints.  For the example:

    subtype StringFollowedByInt,
     as Tuple[Str,Int];
	
would constrain it's value to something like ['hello', 111] but ['hello', 'world']
would fail, as well as ['hello', 111, 'world'] and so on.  Here's another
example:

    subtype StringIntOptionalHashRef,
     as Tuple[
        Str, Int,
        Optional[HashRef]
     ];
     
This defines a type constraint that validates values like:

    ['Hello', 100, {key1=>'value1', key2=>'value2'}];
    ['World', 200];
    
Notice that the last type constraint in the structure is optional.  This is
enabled via the helper Optional type constraint, which is a variation of the
core Moose type constraint Maybe.  The main difference is that Optional type
constraints are required to validate if they exist, while Maybe permits undefined
values.  So the following example would not validate:

    StringIntOptionalHashRef->validate(['Hello Undefined', 1000, undef]);
    
Please note the subtle difference between undefined and null.  If you wish to
allow both null and undefined, you should use the core Moose Maybe type constraint
instead:

    use MooseX::Types -declare [qw(StringIntOptionalHashRef)];
    use MooseX::Types::Moose qw(Maybe);
    use MooseX::Types::Structured qw(Tuple);

    subtype StringIntOptionalHashRef,
     as Tuple[
        Str, Int, Maybe[HashRef]
     ];

This would validate the following:

    ['Hello', 100, {key1=>'value1', key2=>'value2'}];
    ['World', 200, undef];    
    ['World', 200];

Structured Constraints are not limited to arrays.  You can define a structure
against a hashref with 'Dict' as in this example:

    subtype FirstNameLastName,
     as Dict[firstname=>Str, lastname=>Str];

This would constrain a hashref to something like:

    {firstname=>'Vanessa', lastname=>'Li'};
    
but all the following would fail validation:

     {first=>'Vanessa', last=>'Li'};
     {firstname=>'Vanessa', lastname=>'Li', middlename=>'NA'};   
     ['Vanessa', 'Li']; 

These structures can be as simple or elaborate as you wish.  You can even
combine various structured, parameterized and simple constraints all together:

    subtype crazy,
     as Tuple[
        Int,
        Dict[name=>Str, age=>Int],
        ArrayRef[Int]
     ];
	
Which would match "[1, {name=>'John', age=>25},[10,11,12]]".  Please notice how
the type parameters can be visually arranged to your liking and to improve the
clarity of your meaning.  You don't need to run then altogether onto a single
line.

=head2 Alternatives

You should exercise some care as to whether or not your complex structured
constraints would be better off contained by a real object as in the following
example:

    package MyApp::MyStruct;
    use Moose;
    
    has $_ for qw(full_name age_in_years);
    
    package MyApp::MyClass;
    use Moose;
    
    has person => (isa=>'MyApp::MyStruct');		
    
    my $instance = MyApp::MyClass->new(
        person=>MyApp::MyStruct->new(full_name=>'John', age_in_years=>39),
    );
	
This method may take some additional time to setup but will give you more
flexibility.  However, structured constraints are highly compatible with this
method, granting some interesting possibilities for coercion.  Try:

    use MyApp::MyStruct;
    use MooseX::Types::DateTime qw(DateTime);
    use MooseX::Types -declare [qw(MyStruct)];
    use MooseX::Types::Moose qw(Str Int);
    use MooseX::Types::Structured qw(Dict);

    ## Use class_type to create an ISA type constraint if your object doesn't
    ## inherit from Moose::Object.
    class_type 'MyApp::MyStruct';

    ## Just a shorter version really.
    subtype MyStruct,
     as 'MyApp::MyStruct';
    
    ## Add the coercions.
    coerce MyStruct,
     from Dict[
        full_name=>Str,
        age_in_years=>Int
     ], via {
        MyApp::MyStruct->new(%$_);
     },
     from Dict[
        lastname=>Str,
        firstname=>Str,
        dob=>DateTime
     ], via {
        my $name = $_->{firstname} .' '. $_->{lastname};
        my $age = DateTime->now - $_->{dob};
        MyApp::MyStruct->new( full_name=>$name, age_in_years=>$age->years );
     };

If you are not familiar with how coercions work, check out the L<Moose> cookbook
entry L<Moose::Cookbook::Recipe5> for an explanation.  The section L</Coercions>
has additional examples and discussion.

=head2 Subtyping a Structured type constraint

You need to exercise some care when you try to subtype a structured type
as in this example:

    subtype Person,
     as Dict[name=>Str, age=>Int];
	 
    subtype FriendlyPerson,
     as Person[name=>Str, age=>Int, totalFriends=>Int];
	 
This will actually work BUT you have to take care that the subtype has a
structure that does not contradict the structure of it's parent.  For now the
above works, but I will clarify the syntax for this at a future point, so
it's recommended to avoid (should not really be needed so much anyway).  For
now this is supported in an EXPERIMENTAL way.  Your thoughts, test cases and
patches are welcomed for discussion.

=head2 Coercions

Coercions currently work for 'one level' deep.  That is you can do:

    subtype Person,
     as Dict[name=>Str, age=>Int];
    
    subtype Fullname,
     as Dict[first=>Str, last=>Str];
    
    coerce Person,
     ## Coerce an object of a particular class
     from BlessedPersonObject,
     via { +{name=>$_->name, age=>$_->age} },
     ## Coerce from [$name, $age]
     from ArrayRef,
     via { +{name=>$_->[0], age=>$_->[1] },
     ## Coerce from {fullname=>{first=>...,last=>...}, dob=>$DateTimeObject}
     from Dict[fullname=>Fullname, dob=>DateTime],
     via {
        my $age = $_->dob - DateTime->now;
        +{
            name=> $_->{fullname}->{first} .' '. $_->{fullname}->{last},
            age=>$age->years
        }
     };
	 
And that should just work as expected.  However, if there are any 'inner'
coercions, such as a coercion on 'Fullname' or on 'DateTime', that coercion
won't currently get activated.

Please see the test '07-coerce.t' for a more detailed example.  Discussion on
extending coercions to support this welcome on the Moose development channel or
mailing list.

=head1 TYPE CONSTRAINTS

This type library defines the following constraints.

=head2 Tuple[@constraints]

This defines an arrayref based constraint which allows you to validate a specific
list of constraints.  For example:

    Tuple[Int,Str]; ## Validates [1,'hello']
    Tuple[Str|Object, Int]; ##Validates ['hello', 1] or [$object, 2]

=head2 Dict[%constraints]

This defines a hashref based constraint which allowed you to validate a specific
hashref.  For example:

    Dict[name=>Str, age=>Int]; ## Validates {name=>'John', age=>39}

=head2 Optional[$constraint]

This is primarily a helper constraint for Dict and Tuple type constraints.  What
this allows if for you to assert that a given type constraint is allowed to be
null (but NOT undefined).  If the value is null, then the type constraint passes
but if the value is defined it must validate against the type constraint.  This
makes it easy to make a Dict where one or more of the keys doesn't have to exist
or a tuple where some of the values are not required.  For example:

    subtype Name() => as Dict[
        first=>Str,
        last=>Str,
        middle=>Optional[Str],
    ];
        
Creates a constraint that validates against a hashref with the keys 'first' and
'last' being strings and required while an optional key 'middle' is must be a
string if it appears but doesn't have to appear.  So in this case both the
following are valid:

    {first=>'John', middle=>'James', last=>'Napiorkowski'}
    {first=>'Vanessa', last=>'Li'}
    
=head1 EXAMPLES

Here are some additional example usage for structured types.  All examples can
be found also in the 't/examples.t' test.  Your contributions are also welcomed.

=head2 Normalize a HashRef

You need a hashref to conform to a canonical structure but are required accept a
bunch of different incoming structures.  You can normalize using the Dict type
constraint and coercions.  This example also shows structured types mixed which
other MooseX::Types libraries.

    package Test::MooseX::Meta::TypeConstraint::Structured::Examples::Normalize;
    
    use Moose;
    use DateTime;
    
    use MooseX::Types::Structured qw(Dict Tuple);
    use MooseX::Types::DateTime qw(DateTime);
    use MooseX::Types::Moose qw(Int Str Object);
    use MooseX::Types -declare => [qw(Name Age Person)];
     
    subtype Person,
     as Dict[name=>Str, age=>Int];
    
    coerce Person,
     from Dict[first=>Str, last=>Str, years=>Int],
     via { +{
        name => "$_->{first} $_->{last}",
        age=>$_->{years},
     }},
     from Dict[fullname=>Dict[last=>Str, first=>Str], dob=>DateTime],
     via { +{
        name => "$_->{fullname}{first} $_->{fullname}{last}",
        age => ($_->{dob} - 'DateTime'->now)->years,
     }};
     
    has person => (is=>'rw', isa=>Person, coerce=>1);

=cut

Moose::Util::TypeConstraints::get_type_constraint_registry->add_type_constraint(
	MooseX::Meta::TypeConstraint::Structured->new(
		name => "MooseX::Types::Structured::Tuple" ,
		parent => find_type_constraint('ArrayRef'),
		constraint_generator=> sub { 
			## Get the constraints and values to check
            my ($type_constraints, $values) = @_;
			my @type_constraints = defined $type_constraints ? @$type_constraints: ();            
			my @values = defined $values ? @$values: ();
			## Perform the checking
			while(@type_constraints) {
				my $type_constraint = shift @type_constraints;
				if(@values) {
					my $value = shift @values;
					unless($type_constraint->check($value)) {
						return;
					}				
				} else {
					unless($type_constraint->check()) {
						return;
					}
				}
			}
			## Make sure there are no leftovers.
			if(@values) {
				return;
			} elsif(@type_constraints) {
				return;
			}else {
				return 1;
			}
		}
	)
);
	
Moose::Util::TypeConstraints::get_type_constraint_registry->add_type_constraint(
	MooseX::Meta::TypeConstraint::Structured->new(
		name => "MooseX::Types::Structured::Dict",
		parent => find_type_constraint('HashRef'),
		constraint_generator=> sub { 
			## Get the constraints and values to check
            my ($type_constraints, $values) = @_;
			my %type_constraints = defined $type_constraints ? @$type_constraints: ();            
			my %values = defined $values ? %$values: ();
			## Perform the checking
			while(%type_constraints) {
				my($key, $type_constraint) = each %type_constraints;
				delete $type_constraints{$key};
				if(exists $values{$key}) {
					my $value = $values{$key};
					delete $values{$key};
					unless($type_constraint->check($value)) {
						return;
					}
				} else { 
					unless($type_constraint->check()) {
						return;
					}
				}
			}
			## Make sure there are no leftovers.
			if(%values) { 
				return;
			} elsif(%type_constraints) {
				return;
			}else {
				return 1;
			}
		},
	)
);

OPTIONAL: {
    my $Optional = Moose::Meta::TypeConstraint::Parameterizable->new(
        name => 'MooseX::Types::Structured::Optional',
        package_defined_in => __PACKAGE__,
        parent => find_type_constraint('Item'),
        constraint => sub { 1 },
        constraint_generator => sub {
            my ($type_parameter, @args) = @_;
            my $check = $type_parameter->_compiled_type_constraint();
            return sub {
                my (@args) = @_;			
                if(exists($args[0])) {
                    ## If it exists, we need to validate it
                    $check->($args[0]);
                } else {
                    ## But it's is okay if the value doesn't exists
                    return 1;
                }
            }
        }
    );

    Moose::Util::TypeConstraints::register_type_constraint($Optional);
    Moose::Util::TypeConstraints::add_parameterizable_type($Optional);
}


=head1 SEE ALSO

The following modules or resources may be of interest.

L<Moose>, L<MooseX::Types>, L<Moose::Meta::TypeConstraint>,
L<MooseX::Meta::TypeConstraint::Structured>

=head1 TODO

Need to clarify deep coercions, need to clarify subtypes of subtypes.

=head1 AUTHOR

John Napiorkowski, C<< <jjnapiork@cpan.org> >>

=head1 COPYRIGHT & LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
	
1;
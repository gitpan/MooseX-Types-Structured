package ## Hide from PAUSE
  MooseX::Types::Structured::OverflowHandler;

use Moose;

use overload '""' => 'name', fallback => 1;


has type_constraint => (
    is       => 'ro',
    isa      => 'Moose::Meta::TypeConstraint',
    required => 1,
    handles  => [qw/check/],
);


sub name {
    my ($self) = @_;
    return 'slurpy ' . $self->type_constraint->name;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding UTF-8

=for :stopwords John Napiorkowski Florian Ragwitz יובל קוג'מן (Yuval Kogman) Tomas (t0m)
Doran Robert Sedlacek

=head1 NAME

MooseX::Types::Structured::OverflowHandler

=head1 VERSION

version 0.29

=head1 ATTRIBUTES

=head2 type_constraint

=head1 METHODS

=head2 name

=head1 AUTHORS

=over 4

=item *

John Napiorkowski <jjnapiork@cpan.org>

=item *

Florian Ragwitz <rafl@debian.org>

=item *

יובל קוג'מן (Yuval Kogman) <nothingmuch@woobling.org>

=item *

Tomas (t0m) Doran <bobtfish@bobtfish.net>

=item *

Robert Sedlacek <rs@474.at>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2008 by John Napiorkowski.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

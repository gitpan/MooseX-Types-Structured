package ## Hide from PAUSE
  MooseX::Meta::TypeConstraint::Structured::Optional;

use Moose;
use MooseX::Meta::TypeCoercion::Structured::Optional;

extends 'Moose::Meta::TypeConstraint::Parameterizable';

around parameterize => sub {
    my $orig = shift;
    my $self = shift;

    my $ret = $self->$orig(@_);

    $ret->coercion(MooseX::Meta::TypeCoercion::Structured::Optional->new(type_constraint => $ret));

    return $ret;
};

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;

__END__

=pod

=encoding UTF-8

=for :stopwords John Napiorkowski Florian Ragwitz יובל קוג'מן (Yuval Kogman) Tomas (t0m)
Doran Robert Sedlacek Ansgar 'phaylon' Stevan Little Yuval Kogman arcanez
Burchardt Dave Rolsky Jesse Luehrs Karen Etheridge Ricardo Signes

=head1 NAME

MooseX::Meta::TypeConstraint::Structured::Optional

=head1 VERSION

version 0.29

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

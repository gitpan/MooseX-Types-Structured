package ## Hide from PAUSE
  MooseX::Types::Structured::MessageStack;

use Moose;


has 'level' => (
    traits => ['Counter'],
    is => 'ro',
    isa => 'Num',
    required => 0,
    default => 0,
    handles => {
        inc_level => 'inc',
        dec_level => 'dec',
    },
);


has 'messages' => (
    traits => ['Array'],
    is => 'ro',
    isa => 'ArrayRef[HashRef]',
    required => 1,
    default => sub { [] },
    handles => {
        has_messages => 'count',
        add_message => 'push',
        all_messages => 'elements',
    },
);


sub as_string {
    my @messages = (shift)->all_messages;
    my @flattened_msgs =  map {
        "\n". (" " x $_->{level}) ."[+] " . $_->{message};
    } reverse @messages;

    return join("", @flattened_msgs);
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

MooseX::Types::Structured::MessageStack

=head1 VERSION

version 0.29

=head1 ATTRIBUTES

=head2 level

=head2 messages

=head1 METHODS

=head2 as_string

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

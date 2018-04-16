package Web::Microformats2::Item;
use Moose;
use Carp;

has 'properties' => (
    is => 'ro',
    isa => 'HashRef',
    traits => ['Hash'],
    default => sub { {} },
    handles => {
        has_properties => 'count',
        has_property   => 'get',
    },
);

has 'parent' => (
    is => 'ro',
    isa => 'Maybe[Web::Microformats2::Item]',
    weak_ref => 1,
);

has 'children' => (
    is => 'ro',
    isa => 'ArrayRef[Web::Microformats2::Item]',
    default => sub { [] },
    traits => ['Array'],
    handles => {
        add_child => 'push',
    },
);

has 'types' => (
    is => 'ro',
    isa => 'ArrayRef[Str]',
    required => 1,
    traits => ['Array'],
    handles => {
        find_type => 'first',
    },

);

has 'value' => (
    is => 'rw',
    isa => 'Maybe[Str]',
);

sub add_property {
    my $self = shift;

    my ( $key, $value ) = @_;

    $self->{properties}->{$key} ||= [];

    push @{ $self->{properties}->{$key} }, $value;
}

sub get_properties {
    my $self = shift;

    my ( $key ) = @_;

    return $self->{properties}->{$key} || [];
}

sub get_property {
    my $self = shift;

    my $properties_ref = $self->get_properties( @_ );

    if ( @$properties_ref > 1 ) {
        carp "get_property called with multiple properties set\n";
    }

    return $properties_ref->[0];

}

sub has_type {
    my $self = shift;
    my ( $type ) = @_;

    $type =~ s/^h-//;

    return $self->find_type( sub { $_ eq $type } );
}

sub TO_JSON {
    my $self = shift;

    my $data = {
        properties => $self->properties,
        type => [ map { "h-$_" } @{ $self->types } ],
    };
    if ( defined $self->value ) {
        $data->{value} = $self->value;
    }
    if ( @{$self->children} ) {
        $data->{children} = $self->children;
    }
    return $data;
}

1;


=pod

=head1 NAME

Web::Microformats2::Item - A parsed Microformats2 item

=head1 DESCRIPTION

An object of this class represents a Microformats2 item, contained
within a larger, parsed Microformats2 data structure. An item represents
a single semantically meaningful something-or-other: an article, a
person, a photograph, et cetera.

The expected use-case is that you will never directly construct items,
but rather query them through the methods provided by this class and
related ones, once you have constructed a document object via parsing
HTML or deserializing some JSON.

See L<Web::Microformats2> for further context and purpose.

=head1 METHODS

=head2 Object Methods

Only read-only methods are described here, on the argument that this
object represents an item defined elsewhere and therefore manipulating
its contents doesn't really represent a meaningful activity.

=over

=item get_properties ( $property_key )

Returns a list reference of all property values identified by the given
key. Values can be strings, unblessed references, or more item objects.

Note that Microformats2 stores its properties' key without their
prefixes, so that's how you should query for them here. In order words,
pass in "name" or "url" as an argument, not "p-name" or "u-url".

=item get_property ( $property_key )

Returns the first property value identified by the given key.

If this item contains more than one such value, the object will also
emit a warning.

=item value ( )

Returns the special C<value> attribute, if this item has it defined.

=item types ( )

Returns a list reference to all the types that this item identifies as.
Guaranteed to contain at least one value.

Note that each member of the list is the type without its original
prefix, so e.g. "entry" and "card" and not "h-entry" and "h-card".
I<This behavior might change in near-future versions.>

=item has_type ( $type )

Returns true if the item claims to be of the given type, false
otherwise. (The argument can include a prefix, so e.g. both "entry" and
"h-entry" return the same result here.)

=item parent ( )

Returns this item's parent item, if set.

=item children ( )

Returns a list of child items.

=back

=head1 AUTHOR

Jason McIntosh (jmac@jmac.org)

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

The expected use-case is that you will never directly construct item
objects. Instead, your code will receive item objects by querying a
L<Web::Microformats2::Document> instance, itself created by running
Microformats2-laden HTML or JSON through a L<Web::Microformats2::Parser>
object.

See L<Web::Microformats2> for further context and purpose.

=head1 METHODS

=head2 Object Methods

=head3 get_properties

 $properties_ref = $item->get_properties( $property_key )

 # To get all "u-url" properties of this item:
 $urls = $item->get_properties( 'url' );
 # To get all "p-name" properties:
 $names = $item->get_properties( 'name' );

Returns a list reference of all property values identified by the given
key. Values can be strings, unblessed references, or more item objects.

Note that Microformats2 stores its properties' keys without their
prefixes, so that's how you should query for them here. In order words,
pass in "name" or "url" as an argument, not "p-name" or "u-url".

=head3 get_property

 $property_value = $item->get_property( $property_key );

 # To get the first (and maybe only?) "u-url" property of this item:
 $url = $item->get_property( 'url' );
 # To get its "p-name" property:
 $name = $item->get_property( 'name' );

Like L<"get_properties">, but returns only the first property value identified
by the given key.

If this item contains more than one such value, this will also emit a warning.

=head3 value

 $value = $item->value;

Returns the special C<value> attribute, if this item has it defined.

=head3 types

 $types_ref = $item->types;

Returns a list reference to all the types that this item identifies as.
Guaranteed to contain at least one value.

Note that each member of the list is the type without its original
prefix, so e.g. "entry" and "card" and not "h-entry" and "h-card".
I<This behavior might change in near-future versions.>

=head3 has_type

 $bool = $item->has_type( $type )

Returns true if the item claims to be of the given type, false
otherwise. (The argument can include a prefix, so e.g. both "entry" and
"h-entry" return the same result here.)

=head3 parent

 $parent = $item->parent;

Returns this item's parent item, if set.

=head3 children

 $children_ref = $item->children;

Returns a list reference of child items.

=head1 AUTHOR

Jason McIntosh (jmac@jmac.org)

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Jason McIntosh.

This is free software, licensed under:

  The MIT (X11) License

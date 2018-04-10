package Web::Microformats2::Document;
use Moose;
use JSON qw(decode_json);

use Web::Microformats2::Item;

has 'top_level_items' => (
    is => 'ro',
    traits => ['Array'],
    isa => 'ArrayRef[Web::Microformats2::Item]',
    default => sub { [] },
    lazy => 1,
    handles => {
        all_top_level_items => 'elements',
        add_top_level_item => 'push',
        count_top_level_items => 'count',
        has_top_level_items => 'count',
    },
);

has 'items' => (
    is => 'ro',
    traits => ['Array'],
    isa => 'ArrayRef[Web::Microformats2::Item]',
    default => sub { [] },
    lazy => 1,
    handles => {
        add_item => 'push',
        all_items => 'elements',
    },
);

has 'rels' => (
    is => 'ro',
    isa => 'HashRef',
    lazy => 1,
    clearer => '_clear_rels',
    default => sub { {} },
);

has 'rel_urls' => (
    is => 'ro',
    isa => 'HashRef',
    lazy => 1,
    clearer => '_clear_rel_urls',
    default => sub { {} },
);

sub as_json {
    my $self = shift;

    my $data_for_json = {
        rels => $self->rels,
        'rel-urls' => $self->rel_urls,
        items => $self->top_level_items,
    };

    return JSON->new->convert_blessed->pretty->encode( $data_for_json );
}

sub new_from_json {
    my $class = shift;

    my ( $json ) = @_;

    my $data_ref = decode_json ($json);

    my $document = $class->new;
    for my $deflated_item ( @{ $data_ref->{items} } ) {
        my $item = $class->_inflate_item( $deflated_item );
        $document->add_top_level_item( $item );
        $document->add_item ( $item );
    }

    return $document;
}

sub _inflate_item {
    my $class = shift;

    my ( $deflated_item ) = @_;

    foreach ( @{ $deflated_item->{type} } ) {
        s/^h-//;
    }

    my $item = Web::Microformats2::Item->new(
        types => $deflated_item->{type},
    );

    if ( defined $deflated_item->{value} ) {
        $item->value( $deflated_item->{value} );
    }

    for my $deflated_child ( @{ $deflated_item->{children} } ) {
        $item->add_child ( $class->_inflate_item( $deflated_child ) );
    }

    for my $property ( keys %{ $deflated_item->{properties} } ) {
        my $properties_ref = $deflated_item->{properties}->{$property};
        for my $property_value ( @{ $properties_ref } ) {
            if ( ref( $property_value ) ) {
                $property_value = $class->_inflate_item( $property_value );
            }
            $item->add_property( $property, $property_value );
        }
    }

    return $item;
}

sub get_first {
    my $self = shift;

    my ( $type ) = @_;

    for my $item ( $self->all_items ) {
        return $item if $item->has_type( $type );
    }

    return;
}

1;

=pod

=head1 NAME

Web::Microformats2::Document - A parsed Microformats2 data structure

=head1 DESCRIPTION

An object of this class represents a Microformats2 data structure that has been either parsed from an HTML document or deserialized from JSON.

The expected use-case is that you will construct document objects either via the "parse" method of Web::Microformats2::Parse, or by this class's "new_from_json" method. Once constructed, we expect you to treat documents as read-only.

See Web::Microformats2 for further context and purpose.

=head1 METHODS

=head2 Class Methods

=over

=item new_from_json ( $json_string )

Given a JSON string containing a properly serialized Microformats2 data structure, returns a Web::Microformats2::Document object.

=back

=head2 Object Methods

=over

=item all_top_level_items ( )

Returns a list of all Web::Microformats2::Item objects this document contains at the top level.

=item all_items ( )

Returns a list of all Web::Microformats2::Item objects this document contains at I<any> level.

=item get_first ( $item_type )

Given a Microformats2 item-type string -- e.g. "h-entry" (or just "entry") -- returns the first item of that type that this document contains (in document order, depth-first).

=back

=head1 AUTHOR

Jason McIntosh (jmac@jmac.org)

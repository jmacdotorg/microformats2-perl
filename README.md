# microformats2-perl

These Perl libraries let you read Microformats2 metadata from HTML or JSON.

## Synopsis

```
 use Web::Microformats2;

 my $mf2_parser = Web::Microformats2::Parser->new;
 my $mf2_doc    = $mf2_parser->parse( $string_full_of_tasty_html );

 for my $item ( $mf2_doc->all_top_level_items ) {
    # Each $item is a Web::Microformats2::Item object.
    my $types_ref = $item->types;
    print "I see an MF2 item with these types set: @$types_ref\n";

    my $name = $item->get_property( 'name' );
    print "The value of the item's 'name' property is: '$name'\n";
 }

 my $serialized_mf2_doc = $mf2_doc->as_json;

 my $other_mf2_doc = Web::Microformats2::Document->new_from_json(
    $serialized_mf2_doc_from_somehwere_else
 );
```

## Description

The Web::Microformats2 modules provide Perl programs with a way to parse and analyze HTML documents containing Microformats2 metadata. They can pull Microformats2 information from a given HTML document, representing it as a queryable in-memory object. They can also serialize this object as JSON (using the Microformats2 rules for this), or read an already JSON-serialized Microformats2 structure for further analysis.

See "About Microformats2", below, for arguments about why this might be interesting to you.

## Classes

* Web::Microformats2::Parser

Parses HTML for Microformats2 metadata. Returns what it finds as a Web::Microformats2::Document object.

* Web::Microformats2::Document

Objects are queryable structures of parsed Microformats2 metadata. Each came either fresh from HTML, or re-inflated from its JSON serialization format.

* Web::Microformats2::Item

Each document object contains one or more objects of this class. Each item represents a single, "h-"prefixed microformat substructure, defining what we in the Perl world might call some _thingy_: an article, a person, an invitation, and so on. Each item has some number of properties, and possibly a parent item and a list of child items.

## Project status

These modules are **alpha**. Their developer is still figuring out how they want to be used, and their interface may change dramatically. It's not ready for CPAN just yet. This software is currently being "dogfooded" on an experimental branch of the author's own essay blog.

Further, the parser implementation is incomplete. The HTML and JSON documents found in t/microformats-v2 include the full Microformats2 parser test suite found at https://github.com/microformats/tests, as of early April, 2018. The parser-test program in t/parser.pl marks a great deal of these tests as TODO. (But fewer than half of them, for all that, so hey.)

## About Microformats2

Microformats2 allows the attachment of semantic metadata to arbitrary HTML elements, in a way that neither hinders the human readability of the underlying HTML document nor strictly prescribes any set vocabulary to this metadata.

For example, an HTML page containing several recent blog entries might use Microformats2 to identify the title, date, and content of each entry, as well as its author. It could furthermore define not just the author's name, but also their contact information, homepage URL, and avatar-graphic. It might even identify some entries as public responses to other articles found elsewhere on the web. Since all this metadata exists quietly within the "class" attributes found within the HTML page's ordinary markup, its presence does not affect or interfere with the web page's rendering or readability to humans.

A Microfomats2 parser can read these special attribute values -- identifiable by their conspicuous use of prefixes, such as "h-entry" and "p-name" -- and turn them into data structures that use this metadata to give additional order, structure, and semantic labeling to the content found within. These data structures can then be passed (usually as JSON strings) to other processors, which can make all sorts of interesting things happen.

Microformats2 is the successor to Microformats. While similar in intent and execution, their implementations are very different. Rather than using the pre-defined vocabularies of its predecessor, Microformats2 uses a relatively simple set of rules that allow for limitless user-definable labels for metadata items and their constituent properties.

For more information about Microformats2, please see http://microformats.org/wiki/microformats2.

## Author

Jason McIntosh (jmac@jmac.org)

## Other contributors

The tests found in `t/microformats-v2` are based on prior work by the Microformats community, canonically stored at https://github.com/microformats/tests/tree/master/tests/microformats-v2.

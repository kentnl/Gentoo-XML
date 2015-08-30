use 5.006;
use strict;
use warnings;

package Gentoo::XML;

our $VERSION = '0.001000';

# ABSTRACT: Work with various Gentoo XML documents in an object oriented manner

# AUTHORITY

our %DTDS = (
  'http://www.gentoo.org/dtd/metadata.dtd'  => 'Gentoo::XML::Metadata',
  'https://www.gentoo.org/dtd/metadata.dtd' => 'Gentoo::XML::Metadata',
);
our %PARSER_OPTIONS = (
  load_ext_dtd => 0,
  no_network   => 0,
);

=method C<load_xml>

  my $object = Gentoo::XML->load_xml( $type => $value );

=over 4

=item * C<$type = >B<C<"string">>

Load C<$value> as either a scalar or scalar reference.

=item * C<$type = >B<C<"IO">>

Read C<$value> as a File Handle

=item * C<$type = >B<C<"location">>

Read C<$value> by opening the URI

=back

See related documentation on C<XML DOM> Parsing in
L<< C<XML::LibXML::Parser>|XML::LibXML::Parser/DOM Parser >>

=cut

sub load_xml {
  my ( $class, $type, $file ) = @_;
  return $class->_inflate_doc( $class->_parser->load_xml( $type => $file ) );
}

sub _parser_options { %PARSER_OPTIONS }

sub _parser {
  require XML::LibXML;
  return XML::LibXML->new( $_[0]->_parser_options );
}

sub _inflate_doc {
  my ( undef, $doc ) = @_;
  my $dtd      = $doc->internalSubset;
  my $dispatch = $dtd->systemId;
  my $name     = $dtd->getName;
  if ( not exists $DTDS{$dispatch} ) {
    require Carp;
    Carp::croak("Unknown DTD $dispatch");
  }
  require Module::Load;
  Module::Load::load( $DTDS{$dispatch} );    ## no critic (ProhibitCallsToUnexportedSubs)
  return $DTDS{$dispatch}->inflate( $doc, $name );
}

1;


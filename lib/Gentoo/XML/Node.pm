use 5.006;    # our
use strict;
use warnings;

package Gentoo::XML::Node;

our $VERSION = '0.001000';

# ABSTRACT: A root of an abstract node handler

# AUTHORITY

use Carp qw( croak );
use Safe::Isa qw( $_isa );

=method inflate

  my $node = Gentoo::XML::Node->inflate( $xml_document, $path );

Finds exactly one node in C<$xml_document> matching C<$path> and inflate it as
a C<Gentoo::XML::Node> instance.

Errors otherwise.

=cut

sub inflate {
  my ( $class, $document, $path ) = @_;
  croak '->inflate( *document*, path ) must be of type XML::LibXML::Document'
    unless _isa_document($document);
  $path = q;.; if not defined $path;
  my (@nodes) = $document->findnodes($path);
  return $class->new( _root_node => $nodes[0] ) if 1 == @nodes;
  croak "Too many/too few nodes matched $path ( expected exactly one )";
}

=method inflate_all

  my (@nodes) = Gentoo::XML::Node->inflate_all( $xml_document, $path );

B<In List Context>: Finds all nodes in C<$xml_document> matching C<$path> and
inflates them as C<Gentoo::XML::Node> instances.

B<In Scalar Context>: Finds the first node in C<$xml_document> matching
C<$path> and inflates it as a C<Gentoo::XML::Node> instance. Returns undef
otherwise.

=cut

sub inflate_all {
  my ( $class, $document, $path ) = @_;
  croak '->inflate( *document*, path ) must be of type XML::LibXML::Document'
    unless _isa_document($document);
  $path = q;.; if not defined $path;
  if (wantarray) {
    return map { $class->new( _root_node => $_ ) } $document->findnodes($path);
  }
  for ( $document->findnodes($path) ) {
    return $class->new( _root_node => $_ );
  }
  return;
}

sub to_string { return $_[0]->_root_node->toString }

sub new {
  my ( $class, @args ) = @_;
  my ($params) = { ( 'HASH' eq ref $args[0] ) ? %{ $args[0] } : @args };
  my $instance = bless $params, $class;
  $instance->BUILD;
  return $instance;
}

sub _isa_xpath {
  return unless defined $_[0];
  return 1 if not ref $_[0];
  $_[0]->$_isa('XML::LibXML::XPathExpression');
}

sub _isa_document { $_[0]->$_isa('XML::LibXML::Document') }
sub _isa_node     { $_[0]->$_isa('XML::LibXML::Node') }

=for Pod::Coverage BUILD new to_string

=cut

sub BUILD {
  my ($self) = @_;
  croak '_root_node is required'
    unless exists $self->{_root_node} and _isa_node( $self->{_root_node} );
}

sub _path       { return $_[0]->_root_node->nodePath() }
sub _root_node  { return $_[0]->{_root_node} }
sub _document   { return $_[0]->_root_node->ownerDocument }
sub _find_nodes { return $_[0]->_root_node->findnodes( $_[1] ) }
sub _get_path   { return $_[0]->_root_node->findnodes( $_[1] )->pop }

{
  my $meta = {};
  use Scalar::Util qw( blessed );

=method C<meta_node>

When called on an object or a class which is a subclass
of Gentoo::XML::Node, returns an object for managing internals
of that Node

  my $meta_node = NodeClass->meta_node();

See L<< C<_MetaNodeSet>|Gentoo::XML::Node::_MetaNode >>

=cut

  sub meta_node {
    my $class = blessed $_[0] ? blessed $_[0] : $_[0];
    return $meta->{$class} if exists $meta->{$class};
    require Gentoo::XML::Node::_MetaNode;
    return $meta->{$class} = Gentoo::XML::Node::_MetaNode->new( { class => $class, } );
  }
}
1;

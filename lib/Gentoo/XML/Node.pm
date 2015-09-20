use 5.006;    # our
use strict;
use warnings;

package Gentoo::XML::Node;

our $VERSION = '0.001000';

# ABSTRACT: A root of an abstract node handler

# AUTHORITY

use Carp qw( croak );
use Scalar::Util qw( blessed );
use Safe::Isa qw( $_isa );

our %META_NODES;

#& $class->inflate( $root, $path )
sub inflate {
  my $class   = $_[0];
  my $root    = _isa_node( $_[1] ) ? $_[1] : croak '->inflate( *root*, path ) must be of type XML::LibXML::Node';
  my $path    = defined $_[2] ? $_[2] : q[.];
  my (@nodes) = $root->findnodes($path);
  return $class->new( _root_node => $nodes[0] ) if 1 == @nodes;
  croak "Too many/too few nodes matched $path ( expected exactly one )";
}

#& $class->inflate_all( $root, $path )
sub inflate_all {
  my $class = $_[0];
  my $root  = _isa_node( $_[1] ) ? $_[1] : croak '->inflate_all( *root*, path ) must be of type XML::LibXML::Node';
  my $path  = defined $_[2] ? $_[2] : q[.];
  if (wantarray) {
    return map { $class->new( _root_node => $_ ) } $root->findnodes($path);
  }
  for ( $root->findnodes($path) ) {
    return $class->new( _root_node => $_ );
  }
  return;
}

#& $instance->to_string()
sub to_string { return $_[0]->_root_node->toString }

#& $class->new( %args )
#& $class->new( { %args } )
sub new {
  my ( $class, @args ) = @_;
  my ($params) = { ( 'HASH' eq ref $args[0] ) ? %{ $args[0] } : @args };
  my $instance = bless $params, $class;
  $instance->BUILD;
  return $instance;
}

#& $class->meta_node
#& $instance->meta_node
sub meta_node {
  my $class = blessed $_[0] ? blessed $_[0] : $_[0];
  return $META_NODES{$class} if exists $META_NODES{$class};
  require Gentoo::XML::Node::_MetaNode;
  return $META_NODES{$class} = Gentoo::XML::Node::_MetaNode->new( { class => $class, } );
}

#& _isa_xpath($thing)
sub _isa_xpath {
  return unless defined $_[0];
  return 1 if not ref $_[0];
  $_[0]->$_isa('XML::LibXML::XPathExpression');
}

#& _isa_document($thing)
sub _isa_document { $_[0]->$_isa('XML::LibXML::Document') }

#& _isa_node($thing)
sub _isa_node { $_[0]->$_isa('XML::LibXML::Node') }

=for Pod::Coverage BUILD new to_string

=cut

#& $instance->BUILD
sub BUILD {
  croak '_root_node is required'
    unless exists $_[0]->{_root_node} and _isa_node( $_[0]->{_root_node} );
}

#& $instance->_path
sub _path { return $_[0]->_root_node->nodePath() }

#& $instance->_root_node
sub _root_node { return $_[0]->{_root_node} }

#& $instance->_document
sub _document { return $_[0]->_root_node->ownerDocument }

#& $instance->_find_nodes($path)
sub _find_nodes { return $_[0]->_root_node->findnodes( $_[1] ) }

#& $instance->_get_path($path)
sub _get_path { return $_[0]->_root_node->findnodes( $_[1] )->pop }

1;

=method inflate

  my $node = Gentoo::XML::Node->inflate( $xml_document, $path );

Finds exactly one node in C<$xml_document> matching C<$path> and inflate it as
a C<Gentoo::XML::Node> instance.

Errors otherwise.

=method inflate_all

  my (@nodes) = Gentoo::XML::Node->inflate_all( $xml_document, $path );

B<In List Context>: Finds all nodes in C<$xml_document> matching C<$path> and
inflates them as C<Gentoo::XML::Node> instances.

B<In Scalar Context>: Finds the first node in C<$xml_document> matching
C<$path> and inflates it as a C<Gentoo::XML::Node> instance. Returns undef
otherwise.

=method C<meta_node>

When called on an object or a class which is a subclass
of Gentoo::XML::Node, returns an object for managing internals
of that Node

  my $meta_node = NodeClass->meta_node();

See L<< C<_MetaNodeSet>|Gentoo::XML::Node::_MetaNode >>

=cut

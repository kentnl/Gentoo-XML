use 5.006;    # our
use strict;
use warnings;

package Gentoo::XML::Node::_MetaCollection;

our $VERSION = '0.001000';

# ABSTRACT: A Meta-Object for collections within Gentoo::XML::Node::_MetaNode

# AUTHORITY

sub new {
  my $self = bless { %{ $_[1] } }, $_[0];
  $self->sort_order();
  $self->element_class();
  return $self;
}
sub name        { $_[0]->{name} }
sub owner_class { $_[0]->{owner_class} }
sub meta_node   { $_[0]->owner_class->meta_node }

sub sort_order {
  return $_[0]->{sort_order} if exists $_[0]->{sort_order};
  $_[0]->{sort_order} = $_[0]->meta_node->next_sort_order;
  return $_[0]->{sort_order};
}

sub element {
  return $_[0]->{element} if exists $_[0]->{element};
  return $_[0]->name;
}

sub element_class {
  if ( exists $_[0]->{element_class} ) {
    my $element_class = $_[0]->{element_class};
    local $@ = undef;
    eval "require $element_class; 1" or croak $@;
    return $element_class;
  }
  $_[0]->meta_node->class_for_element( $_[0]->element );
}

sub gensub_collection_has {
  my ($collection) = @_;
  return sub {
    my ($self) = @_;
    return !!scalar $self->_find_nodes( $collection->element );
  };
}

sub gensub_collection_elements {
  my ($collection) = @_;
  my $element_class = $collection->element_class;
  return sub {
    my ($self) = @_;
    return map { $element_class->new( _root_node => $_ ) } $self->_find_nodes( $collection->element );
  };
}

1;

=method C<new>

Create a new C<_MetaCollection> object, representing a set of accessors on a
C<::Node> class.

  my $metacollection = Gentoo::XML::Node::_MetaCollection->new({
    name        => 'element_name',
    owner_class => 'Foo::Node',
    { @spec }
  });

=method C<name>

Returns the chosen name collection. This is the name used in sub accessors.

  my $name = $metacollection->name;

This B<MUST> be passed to C<new>

=method C<owner_class>

Returns the package the metacollection is to be attached to.

  my $owner_class = $metacollection->owner_class();

This B<MUST> be passed to C<new>

=method C<element>

This returns the value for the C<element> in the C<XML> that
this collection works with.

If not passed to C<new>, defaults to the same as C<name>

=method C<element_class>

This returns the value for the class name that C<element> should be inflated
into.

If not passed to C<new>, instead returns whatever C<meta_node> says to use for
C<element>

=method C<meta_node>

Returns the C<meta_node> of the C<owner_class>

=method C<sort_order>

The order of the node in tree generation actions.

If not passed to C<new>, is filled with a new order value from C<meta_node>.

=method C<gensub_collection_has>

Returns a C<CodeRef> that can be applied to a C<Class>, so that calling that
C<CodeRef> on an object as follows will return whether or not there were
instances of child elements called C<element>

  my $coderef = $meta_collection->gensub_collection_has();

  $object->$coderef(); # asks if $object has child nodes called $meta_collection->element

=method C<gensub_collection_elements>

Returns a C<CodeRef> that can be applied to a C<Class>, so that calling that
C<CodeRef> on an object as follows will return a list of all applicable
instances of child elements called C<element>, with them inflated into the
appropriate class C<element_class>

  my $coderef = $meta_collection->gensub_collection_elements();

  $object->$coderef(); # returns a list of "element" nodes cast to Foo::Element


use 5.006;    # our
use strict;
use warnings;

package Gentoo::XML::Node::_MetaNode;

our $VERSION = '0.001000';

# ABSTRACT: A metaobject for subclasses of Gentoo::XML::Node

# AUTHORITY

sub new { bless { %{ $_[1] } }, $_[0] }
sub class             { $_[0]->{class} }
sub meta_nodeset      { $_[0]->nodeset_class->meta_nodeset }
sub class_for_element { $_[0]->meta_nodeset->class_for_element( $_[1] ) }
sub collections       { $_[0]->{collections} ||= {} }

sub next_sort_order {
  if ( not exists $_[0]->{sort_order} ) {
    return $_[0]->{sort_order} = 0;
  }
  return ++$_[0]->{sort_order};
}

sub nodeset_class {
  return $_[0]->{nodeset_class} if exists $_[0]->{nodeset_class};
  my $class = $_[0]->class;
  $_[0]->{nodeset_class} = do {
    no strict 'refs';
    no warnings 'once';
    ${ $class . '::NODESET' };
  };
  my $nodeset_class = $_[0]->{nodeset_class} ||= do {
    $class =~ s/::[^:]+$//sx;
    $class;
  };
  local $@;
  eval "require $nodeset_class; 1" or croak $@;
  return $nodeset_class;
}

sub add_collection {
  my ( $self, $name, $args ) = @_;
  if ( exists $self->collections->{$name} ) {
    require Carp;
    Carp::croak( "Collection $name for class " . $self->class . ' already defined' );
  }
  require Gentoo::XML::Node::_MetaCollection;
  my $meta_collection = Gentoo::XML::Node::_MetaCollection->new(
    {
      name        => $name,
      owner_class => $self->class,
      %{$args},
    },
  );
  $self->collections->{$name} = $meta_collection;
  my $class = $self->class;
  {
    no strict 'refs';
    *{ $class . q[::has_] . $name } = $meta_collection->gensub_collection_has;
    *{ $class . q[::] . $name . q[_collection] } = $meta_collection->gensub_collection_elements;
  }
  return $meta_collection;
}

1;

=method C<new>

Create a new C<_MetaNode> representing
the node C<Foo::Node>, which is a member of nodeset
C<$NODESET>

  package Foo::Node;

  our $NODESET = 'Foo';
  my $metanode = Gentoo::XML::Node::_MetaNode->new({
    class => 'Foo::Node',
  });

=method C<class>

Get the associated class of this C<metanode>

  my $class = $metanode->class();

This value B<MUST> be passed to C<new>

=method C<meta_nodeset>

Returns the L<< C<_MetaNodeSet>|Gentoo::XML::NodeSet::_MetaNodeSet >> of the associated C<NodeSet>

  my $meta_nodeset = $metanode->meta_nodeset;

See L<< C<nodeset_class>|/nodeset_class >>

=method C<class_for_element>

Returns the class name that elements named C<$x> are supposed to be
inflated to.

  my $class_name = $metanode->class_for_elements('table');
  # Foo::Table

This is computed by C</class_for_elements> on the related C<_MetaNodeSet>

=method C<collections>

Returns a C<HashRef> of C<_MetaCollection> nodes.

  my $hash = $metanode->collections();

=method C<next_sort_order>

Each C<metanode> has a C<sort_order> property which is used to give serial
numbers to collections so that they can be ordered in the order they are
defined.

Subsequently, for each C<metanode>, the first time this is called it will
return a C<0>, and return a value larger by C<1> on each subsequent call.

  my (@items);
  push @items, $metanode->next_sort_order for 0..4;
  push @items, $metanode->next_sort_order for 0..4;
  # @items now contains numbers 0 through 9

=method C<nodeset_class>

Returns the class of the associated C<NodeSet>.

  my $class = $metanode->nodeset_class;

If this is not passed to C<new>, then it is automatically determined, first
by looking in C<$YourClass::YourNode::NODESET>, and if that is not defined,
falls back and assumes the C<nodeset_class> can be derived by:

  $class =~ s/::[^:]+$//sx

And will then validate that by loading the module.

=method C<add_collection>

Adds a collection accessor to the current class.

  $metanode->add_collection(
    element_name => { @spec }
  );

This proxies through to

  Gentoo::XML::Node::_MetaCollection->new(
    name => 'element_name',
    owner_class => $metanode->class,
    { @spec }
  );

And then creates accessor functions:

  (bless {}, Foo::Node)->has_element_name();
  (bless {}, Foo::Node)->element_name_collection();

See L<< C<_MetaCollection>|Gentoo::XML::Node::_MetaCollection >>

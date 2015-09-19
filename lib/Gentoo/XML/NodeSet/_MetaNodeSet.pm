use 5.006;    # our
use strict;
use warnings;

package Gentoo::XML::NodeSet::_MetaNodeSet;

our $VERSION = '0.001000';

# ABSTRACT: A Meta-Object for subclasses of Gentoo::XML::NodeSet

# AUTHORITY

sub new { bless { %{ $_[1] } }, $_[0] }
sub class       { $_[0]->{class} }
sub has_element { exists $_[0]->elements->{ $_[1] } }
sub element     { $_[0]->elements->{ $_[1] } }

sub elements {
  no strict 'refs';
  no warnings 'once';
  \%{ $_[0]->{class} . q[::ELEMENTS] };
}

sub class_for_element {
  return $_[0]->prefix . $_[0]->element( $_[1] ) if $_[0]->has_element( $_[1] );
  require Carp;
  Carp::croak("Unknown element $_[1]");
}

sub prefix {
  no strict 'refs';
  no warnings 'once';
  ( defined ${ $_[0]->{class} . q[::PREFIX] } )
    ? ${ $_[0]->{class} . q[::PREFIX] }
    : ( $_[0]->{class} . q[::] );
}

1;

=method C<new>

Create a Meta-Object for a C<Gentoo::XML::NodeSet> subclass.

  package Gentoo::XML::Thing;
  use parent 'Gentoo::XML::NodeSet';

  our $PREFIX = "Gentoo::XML::Thing::";
  our %ELEMENTS = (
    element_name => "ElementSuffix",
  );

  my $metanodeset = Gentoo::XML::NodeSet::_MetaNodeSet->new({
    class => 'Gentoo::XML::Thing',
  });

=method C<class>

The associated class for this C<_MetaNodeSet>

  my $class = $metanodeset->class();

=method C<has_element>

Probe the C<class>es associated C<%ELEMENTS> hash
to see if it has a key called C<'element'>

  $metanodeset->has_element('element');

=method C<element>

Get the C<class>'s suffix for element C<'element'>

  my $suffix = $metanodeset->element('element');

=method C<elements>

Get the C<class>'s whole C<%ELEMENTS> hash.

  my $hash = $metanodeset->elements;

=method C<class_for_element>

Get the fully qualified C<class> name for C<'element'>

  my $class_name = $metanodeset->class_for_element('element');

=method C<prefix>

Get the C<class_for_element> prefix.

Resolved from the C<class>'s C<$PREFIX> global, or computed from:

  $metanodeset->class() . '::'

When C<$PREFIX> is not defined.

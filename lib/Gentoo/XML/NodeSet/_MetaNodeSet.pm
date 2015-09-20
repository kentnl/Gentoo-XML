use 5.006;    # our
use strict;
use warnings;

package Gentoo::XML::NodeSet::_MetaNodeSet;

our $VERSION = '0.001000';

use Carp qw( croak );

# ABSTRACT: A Meta-Object for subclasses of Gentoo::XML::NodeSet

# AUTHORITY

#& $class->new(\%args)
sub new { bless { %{ $_[1] } }, $_[0] }

#& $instance->class
sub class { $_[0]->{class} }

#& $instance->has_element( $element_name )
sub has_element { exists $_[0]->elements->{ $_[1] } }

#& $instance->element( $element_name )
sub element { $_[0]->elements->{ $_[1] } }

#& $instance->elements
sub elements {
  no strict 'refs';
  no warnings 'once';
  \%{ $_[0]->{class} . q[::ELEMENTS] };
}

#& $instance->class_for_element( $element_name )
sub class_for_element {
  if ( $_[0]->has_element( $_[1] ) ) {
    my $class = $_[0]->prefix . $_[0]->element( $_[1] );
    local $@ = undef;
    eval "require $class; 1" or croak($@);
    return $class;
  }
  croak "Unknown element $_[1]";
}

#& $instance->prefix
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

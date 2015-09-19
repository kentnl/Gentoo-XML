use 5.006;    # our
use strict;
use warnings;

package Gentoo::XML::NodeSet;

our $VERSION = '0.00100';

# ABSTRACT: Base class for collections of nodes

# AUTHORITY

=method C<inflate>

Inflate C<$document> into an instance of the NodeSet dictated class.

  my $root_node = ::NodeSet->inflate( $document, $nodename );

NodeSet is a factory class.

=cut

sub inflate {
  my ( $class, $doc, $name ) = @_;
  my ($module) = $class->_meta_nodeset->class_for_element($name);
  require Module::Load;
  Module::Load::load($module);    ## no critic (ProhibitCallsToUnexportedSubs)
  return $module->inflate( $doc, $name );
}
{
  my $meta = {};
  use Scalar::Util qw( blessed );

=method C<meta_nodeset>

When called on an object or a class which is a subclass
of Gentoo::XML::NodeSet, returns an object for managing internals
of that NodeSet

  my $meta_nodeset = NodeSetSubClass->meta_nodeset();

See L<< C<_MetaNodeSet>|Gentoo::XML::NodeSet::_MetaNodeSet >>

=cut

  sub meta_nodeset {
    my $class = blessed $_[0] ? blessed $_[0] : $_[0];
    return $meta->{$class} if exists $meta->{$class};
    require Gentoo::XML::NodeSet::_MetaNodeSet;
    return $meta->{$class} = Gentoo::XML::NodeSet::_MetaNodeSet->new( { class => $class, } );
  }
}

1;

=head1 SYNOPSIS

  package Project::SomeName;

  use parent 'Gentoo::XML::NodeSet';

  our $PREFIX   = "Project::SomeName::";
  our %ELEMENTS = (
    'xml_element_name' => 'SuffixString';
  );


  ...

  my $node = Project::SomeName->inflate( $xml_dom, 'xml_element_name' );
  # $node isa Project::SomeName::SuffixString;

=cut

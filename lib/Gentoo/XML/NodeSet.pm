use 5.006;    # our
use strict;
use warnings;

package Gentoo::XML::NodeSet;

our $VERSION = '0.00100';

# ABSTRACT: Base class for collections of nodes

# AUTHORITY

=method C<inflate>

  my $root_node = ::NodeSet->inflate( $document, $nodename );

NodeSet is a factory class

=cut

sub inflate {
  my ( $class, $doc, $name ) = @_;
  my ($module) = do {
    no strict 'refs';
    no warnings 'once';
    if ( not exists ${ $class . '::ELEMENTS' }{$name} ) {
      require Carp;
      Carp::croak("Unknown element $name");
    }
    ${ $class . '::PREFIX' } . ${ $class . '::ELEMENTS' }{$name};
  };
  require Module::Load;
  Module::Load::load($module);    ## no critic (ProhibitCallsToUnexportedSubs)
  return $module->inflate( $doc, q;.; );
}
1;

=head1 SYNOPSIS

  package Project::SomeName;

  use parent 'Gentoo::XML::NodeSet';

  our $PREFIX = "Project::SomeName::";
  our %ELEMENTS = (
    'xml_element_name' => 'SuffixString';
  );


  ...

  my $node = Project::SomeName->inflate( $xml_dom, 'xml_element_name' );
  # $node isa Project::SomeName::SuffixString;

=cut

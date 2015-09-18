use strict;
use warnings;

use Test::More;

# ABSTRACT: Basic test for Node creation and access

use Test::Deep;
use Gentoo::XML::Node;
use XML::LibXML;

sub document {
  my (@args) = @_;

  my $document = <<_XML_;
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE x SYSTEM "x">
<x>
  <y>
  </y>
  <y>
  </y>
  <z>
  </z>
</x>
_XML_

  my $dom = XML::LibXML->load_xml( string => $document );

  #XML::Twig->new();
  #$twig->parse($document);
  my $node = Gentoo::XML::Node->inflate_all( $dom, @args );
}

cmp_deeply( document->to_string,                     re(qr/\A<\?xml/), "Root" );
cmp_deeply( document('x')->to_string,                re(qr/\A<x>/),   "-> x" );
cmp_deeply( document('x/y')->to_string,              re(qr/\A<y>/),   "-> x/y" );
cmp_deeply( document('x/z')->to_string,              re(qr/\A<z>/),   "-> x/z" );
cmp_deeply( document('x')->_get_path('y')->toString, re(qr/\A<y>/),   "->x , ->y" );

done_testing;


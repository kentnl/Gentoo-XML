use 5.006;    # our
use strict;
use warnings;

package Gentoo::XML::Metadata::CatMetadata;

our $VERSION = '0.001000';

# ABSTRACT: Metadata for a category in metadata.xml

# AUTHORITY

use parent 'Gentoo::XML::Node';

__PACKAGE__->meta_node->add_collection( longdescription => {} );

1;


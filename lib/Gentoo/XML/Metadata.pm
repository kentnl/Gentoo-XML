use 5.006;    # our
use strict;
use warnings;

package Gentoo::XML::Metadata;

our $VERSION = '0.001000';

# ABSTRACT: An Object oriented handler for reading and modifying metadata.xml files

# AUTHORITY

our $PREFIX   = 'Gentoo::XML::Metadata::';
our %ELEMENTS = (
  'bug'             => 'Bug',
  'bugs-to'         => 'BugsTo',
  'cat'             => 'Cat',
  'catmetadata'     => 'CatMetadata',
  'change'          => 'Change',
  'changelog'       => 'Changelog',
  'contributor'     => 'Contributor',
  'date'            => 'Date',
  'description'     => 'Description',
  'developer'       => 'Developer',
  'doc'             => 'Doc',
  'email'           => 'Email',
  'file'            => 'File',
  'flag'            => 'Flag',
  'herd'            => 'Herd',
  'longdescription' => 'LongDescription',
  'maintainer'      => 'Maintainer',
  'name'            => 'Name',
  'natural-name'    => 'NaturalName',
  'packages'        => 'Packages',
  'pkg'             => 'Pkg',
  'pkgmetadata'     => 'PkgMetadata',
  'remote-id'       => 'RemoteId',
  'upstream'        => 'Upstream',
  'use'             => 'Use',
  'version'         => 'Version',
);

use parent 'Gentoo::XML::NodeSet';

1;


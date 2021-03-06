# This file was automatically generated by Dist::Zilla::Plugin::MakeMaker v5.039.
use strict;
use warnings;

use 5.006;

use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
  "ABSTRACT" => "Work with various Gentoo XML documents in an object oriented manner",
  "AUTHOR" => "Kent Fredric <kentnl\@cpan.org>",
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => 0
  },
  "DISTNAME" => "Gentoo-XML",
  "LICENSE" => "perl",
  "MIN_PERL_VERSION" => "5.006",
  "NAME" => "Gentoo::XML",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Safe::Isa" => 0,
    "Scalar::Util" => 0,
    "XML::LibXML" => 0,
    "parent" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "TEST_REQUIRES" => {
    "ExtUtils::MakeMaker" => 0,
    "File::Spec" => 0,
    "Test::Deep" => 0,
    "Test::More" => "0.89"
  },
  "VERSION" => "0.001000",
  "test" => {
    "TESTS" => "t/*.t t/00-compile/*.t t/internals/*.t"
  }
);


my %FallbackPrereqs = (
  "Carp" => 0,
  "ExtUtils::MakeMaker" => 0,
  "File::Spec" => 0,
  "Safe::Isa" => 0,
  "Scalar::Util" => 0,
  "Test::Deep" => 0,
  "Test::More" => "0.89",
  "XML::LibXML" => 0,
  "parent" => 0,
  "strict" => 0,
  "warnings" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);

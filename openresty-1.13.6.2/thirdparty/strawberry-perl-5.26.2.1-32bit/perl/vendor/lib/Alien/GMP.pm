package Alien::GMP;

use strict;
use warnings;
use parent 'Alien::Base';
use Role::Tiny::With qw( with );

our $VERSION = '1.08'; # VERSION
# ABSTRACT: Alien package for the GNU Multiple Precision library.

with 'Alien::Role::Alt';

1;
=encoding utf8

=head1 NAME

Alien::GMP - Alien package for the GNU Multiple Precision library.

=head1 SYNOPSIS

In your Build.PL:

 use Module::Build;
 use Alien::GMP;
 my $builder = Module::Build->new(
   ...
   configure_requires => {
     'Alien::GMP' => '0',
     ...
   },
   extra_compiler_flags => Alien::GMP->cflags,
   extra_linker_flags   => Alien::GMP->libs,
   ...
 );
 
 $build->create_build_script;

In your Makefile.PL:

 use ExtUtils::MakeMaker;
 use Config;
 use Alien::GMP;
 
 WriteMakefile(
   ...
   CONFIGURE_REQUIRES => {
     'Alien::GMP' => '0',
   },
   CCFLAGS => Alien::GMP->cflags . " $Config{ccflags}",
   LIBS    => [ Alien::GMP->libs ],
   ...
 );

=head1 DESCRIPTION

This distribution installs GMP so that it can be used by other Perl distributions.  If already
installed for your operating system, and it can be found, this distribution will use the GMP
that comes with your operating system, otherwise it will download it from the Internet, build and
install it for you.

=head2 C++ support

This Alien will provide the C++ bindings for GMP (libgmpxx) if possible.  If you do not have a
C++ compiler, or if your operating system vendor provides a GMP package without the needed C++
files then it will not be available.  To use the C++ bindings, you can use the C<alt> method
to create a C++ instance of this GMP Alien.  For example:

 use ExtUtils::MakeMaker;
 use Config;
 use Alien::GMP;
 
 WriteMakefile(
   ...
   CONFIGURE_REQUIRES => {
     'Alien::GMP' => '1.06', # require version that provides C++ bindings
   },
   CCFLAGS => Alien::GMP->alt('gmpxx')->cflags . " $Config{ccflags}",
   LIBS    => [ Alien::GMP->alt('gmpxx')->libs ],
   ...
 );

=head1 Inline support

This module supports L<Inline's with functionality|Inline/"Playing 'with' Others">.

=head1 SEE ALSO

L<GMP|https://gmplib.org/>

=head1 AUTHOR

Richard Simões C<< <rsimoes AT cpan DOT org> >>

=head1 COPYRIGHT & LICENSE

Copyright © 2012 Richard Simões. This module is released under the terms of the
L<GNU Lesser General Public License|http://gnu.org/licenses/lgpl.html> ("LGPL")
v. 3.0 and may be modified and/or redistributed under the same or any compatible
license. The GNU Multiple Precision library itself is copyrighted by the
L<Free Software Foundation|http://www.fsf.org/> and is also distributed under
terms of the LGPL v. 3.0.

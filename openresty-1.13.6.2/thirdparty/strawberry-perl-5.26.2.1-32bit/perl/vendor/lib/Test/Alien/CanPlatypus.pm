package Test::Alien::CanPlatypus;

use strict;
use warnings;
use base 'Test2::Require';

# ABSTRACT: Skip a test file unless FFI::Platypus is available
our $VERSION = '1.39'; # VERSION


sub skip
{
  eval { require FFI::Platypus; 1 } ? undef : 'This test requires FFI::Platypus.';
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test::Alien::CanPlatypus - Skip a test file unless FFI::Platypus is available

=head1 VERSION

version 1.39

=head1 SYNOPSIS

 use Test::Alien::CanPlatypus;

=head1 DESCRIPTION

This is just a L<Test2> plugin that requires that L<FFI::Platypus>
be available.  Otherwise the test will be skipped.

=head1 SEE ALSO

=over 4

=item L<Test::Alien>

=item L<FFI::Platypus>

=back

=head1 AUTHOR

Author: Graham Ollis E<lt>plicease@cpan.orgE<gt>

Contributors:

Diab Jerius (DJERIUS)

Roy Storey

Ilya Pavlov

David Mertens (run4flat)

Mark Nunberg (mordy, mnunberg)

Christian Walde (Mithaldu)

Brian Wightman (MidLifeXis)

Zaki Mughal (zmughal)

mohawk (mohawk2, ETJ)

Vikas N Kumar (vikasnkumar)

Flavio Poletti (polettix)

Salvador Fandiño (salva)

Gianni Ceccarelli (dakkar)

Pavel Shaydo (zwon, trinitum)

Kang-min Liu (劉康民, gugod)

Nicholas Shipp (nshp)

Juan Julián Merelo Guervós (JJ)

Joel Berger (JBERGER)

Petr Pisar (ppisar)

Lance Wicks (LANCEW)

Ahmad Fatoum (a3f, ATHREEF)

José Joaquín Atria (JJATRIA)

Duke Leto (LETO)

Shoichi Kaji (SKAJI)

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

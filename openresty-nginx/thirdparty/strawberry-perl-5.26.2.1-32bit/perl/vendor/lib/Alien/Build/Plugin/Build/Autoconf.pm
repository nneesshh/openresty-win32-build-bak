package Alien::Build::Plugin::Build::Autoconf;

use strict;
use warnings;
use Alien::Build::Plugin;
use constant _win => $^O eq 'MSWin32';
use Path::Tiny ();

# ABSTRACT: Autoconf plugin for Alien::Build
our $VERSION = '1.39'; # VERSION


has with_pic       => 1;
has ffi            => 0;
has msys_version   => undef;

sub init
{
  my($self, $meta) = @_;
  
  $meta->apply_plugin('Build::MSYS',
    (defined $self->msys_version ? (msys_version => $self->msys_version) : ()),
  );
  
  $meta->prop->{destdir} = 1;
  $meta->prop->{autoconf} = 1;
  
  my $intr = $meta->interpolator;

  my $set_autoconf_prefix = sub {
    my($build) = @_;
    my $prefix = $build->install_prop->{prefix};
    die "Prefix is not set.  Did you forget to run 'make alien_prefix'?"
      unless $prefix;
    if(_win)
    {
      $prefix = Path::Tiny->new($prefix)->stringify;
      $prefix =~ s!^([a-z]):!/$1!i if _win;
    }
    $build->install_prop->{autoconf_prefix} = $prefix;
  };

  $meta->before_hook(
    build_ffi => $set_autoconf_prefix,
  );

  # FFI mode undocumented for now...

  if($self->ffi)
  {
    $meta->add_requires('configure', 'Alien::Build::Plugin::Build::Autoconf' => '0.41');
    $meta->default_hook(
      build_ffi => [
        '%{configure} --enable-shared --disable-static --libdir=%{.install.autoconf_prefix}/dynamic',
        '%{make}',
        '%{make} install',
      ]
    );
  }

  $meta->around_hook(
    build => sub {
      my $orig = shift;
      my $build = shift;

      $set_autoconf_prefix->($build);
      my $prefix = $build->install_prop->{autoconf_prefix};
      die "Prefix is not set.  Did you forget to run 'make alien_prefix'?"
        unless $prefix;
      
      $intr->replace_helper(
        configure => sub {
          my $configure;
          
          if($build->meta_prop->{out_of_source})
          {
            my $extract = $build->install_prop->{extract};
            $configure = _win ? "sh $extract/configure" : "$extract/configure";
          }
          else
          {
            $configure = _win ? 'sh configure' : './configure';
          }
          $configure .= ' --prefix=' . $prefix;
          $configure .= ' --with-pic' if $self->with_pic;
          $configure;
        }
      );

      my $ret = $orig->($build, @_);

      if(_win)
      {
        my $real_prefix = Path::Tiny->new($build->install_prop->{prefix});
        my @pkgconf_dirs;
        push @pkgconf_dirs, Path::Tiny->new($ENV{DESTDIR})->child($prefix)->child("$_/pkgconfig") for qw(lib share);
      
        # for any pkg-config style .pc files that are dropped, we need
        # to convert the MSYS /C/Foo style paths to C:/Foo
        for my $pkgconf_dir (@pkgconf_dirs) {
            if(-d $pkgconf_dir)
            {
              foreach my $pc_file ($pkgconf_dir->children)
              {
                $pc_file->edit(sub {s/\Q$prefix\E/$real_prefix->stringify/eg;});
              }
            }
        }
      }
      
      $ret;
    },
  );


  $intr->add_helper(
    configure => sub {
      my $configure = _win ? 'sh configure' : './configure';
      $configure .= ' --with-pic' if $self->with_pic;
      $configure;
    },
  );
  
  $meta->default_hook(
    build => [
      '%{configure} --disable-shared',
      '%{make}',
      '%{make} install',
    ]
  );
  
  $self;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Alien::Build::Plugin::Build::Autoconf - Autoconf plugin for Alien::Build

=head1 VERSION

version 1.39

=head1 SYNOPSIS

 use alienfile;
 plugin 'Build::Autoconf';

=head1 DESCRIPTION

This plugin provides some tools for building projects that use autoconf.  The main thing
this provides is a C<configure> helper, documented below and the default build stage,
which is:

 '%{configure} --disable-shared',
 '%{make}',
 '%{make} install',

On Windows, this plugin also pulls in the L<Alien::Build::Plugin::Build::MSYS> which is
required for autoconf style projects on windows.

The other thing that this plugin does is that it does a double staged C<DESTDIR> install.
The author has found this improves the overall reliability of L<Alien> modules that are
based on autoconf packages.

This plugin supports out-of-source builds (known in autoconf terms as "VPATH" builds) via
the meta property C<out_of_source>.

=head1 PROPERTIES

=head2 with_pic

Adds C<--with-pic> option when running C<configure>.  If supported by your package, it
will generate position independent code on platforms that support it.  This is required
to XS modules, and generally what you want.

autoconf normally ignores options that it does not understand, so it is usually a safe
and reasonable default to include it.  A small number of projects look like they use
autoconf, but are really an autoconf style interface with a different implementation.
They may fail if you try to provide it with options such as C<--with-pic> that they do
not recognize.  Such packages are the rationale for this property.

=head2 msys_version

The version of L<Alien::MSYS> required if it is deemed necessary.  If L<Alien::MSYS>
isn't needed (if running under Unix, or MSYS2, for example) this will do nothing.

=head1 HELPERS

=head2 configure

 %{configure}

The correct incantation to start an autoconf style C<configure> script on your platform.
Some reasonable default flags will be provided.

=head1 SEE ALSO

L<Alien::Build::Plugin::MSYS>, L<Alien::Build::Plugin>, L<Alien::Build>, L<Alien::Base>, L<Alien>

L<https://www.gnu.org/software/autoconf/autoconf.html>

L<https://www.gnu.org/prep/standards/html_node/DESTDIR.html>

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

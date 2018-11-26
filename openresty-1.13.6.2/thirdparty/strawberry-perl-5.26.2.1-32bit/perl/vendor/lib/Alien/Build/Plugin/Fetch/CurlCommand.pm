package Alien::Build::Plugin::Fetch::CurlCommand;

use strict;
use warnings;
use 5.008001;
use Alien::Build::Plugin;
use File::Which qw( which );
use Path::Tiny qw( path );
use Capture::Tiny qw( capture );
use File::Temp qw( tempdir );
use File::chdir;

# ABSTRACT: Plugin for fetching files using curl
our $VERSION = '1.39'; # VERSION


has curl_command => sub { defined $ENV{CURL} ? which($ENV{CURL}) : which('curl') };
has ssl => 0;
has _see_headers => 0;

sub init
{
  my($self, $meta) = @_;

  $meta->add_requires('configure', 'Alien::Build::Plugin::Fetch::CurlCommand' => '1.19');

  $meta->register_hook(
    fetch => sub {
      my($build, $url) = @_;
      $url ||= $meta->prop->{start_url};

      my($scheme) = $url =~ /^([a-z0-9]+):/i;
      
      if($scheme =~ /^https?$/)
      {
        local $CWD = tempdir( CLEANUP => 1 );
      
        path('writeout')->spew(
          join("\\n",
            "ab-filename     :%{filename_effective}",
            "ab-content_type :%{content_type}",
            "ab-url          :%{url_effective}",
          ),
        );
      
        my @command = (
          $self->curl_command,
          '-L', '-f', -o => 'content',
          -w => '@writeout',
        );
      
        push @command, -D => 'head' if $self->_see_headers;
      
        push @command, $url;
      
        my($stdout, $stderr) = $self->_execute($build, @command);

        my %h = map { my($k,$v) = m/^ab-(.*?)\s*:(.*)$/; $k => $v } split /\n/, $stdout;

        if($h{url} =~ m{/([^/]+)$})
        {
          $h{filename} = $1;
        }
        else
        {
          $h{filename} = 'index.html';
        }
        
        rename 'content', $h{filename};

        if(-e 'head')
        {
          $build->log(" ~ $_ => $h{$_}") for sort keys %h;
          $build->log(" header: $_") for path('headers')->lines;
        }
      
        my($type) = split ';', $h{content_type};

        if($type eq 'text/html')
        {
          return {
            type    => 'html',
            base    => $h{url},
            content => scalar path($h{filename})->slurp,
          };
        }
        else
        {
          return {
            type     => 'file',
            filename => $h{filename},
            path     => path($h{filename})->absolute->stringify,
          };
        }
      }
#      elsif($scheme eq 'ftp')
#      {
#        if($url =~ m{/$})
#        {
#          my($stdout, $stderr) = $self->_execute($build, $self->curl_command, -l => $url);
#          chomp $stdout;
#          return {
#            type => 'list',
#            list => [
#              map { { filename => $_, url => "$url$_" } } sort split /\n/, $stdout,
#            ],
#          };
#        }
#
#        my $first_error;
#
#        {
#          local $CWD = tempdir( CLEANUP => 1 );
#
#          my($filename) = $url =~ m{/([^/]+)$};
#          $filename = 'unknown' if (! defined $filename) || ($filename eq '');
#          my($stdout, $stderr) = eval { $self->_execute($build, $self->curl_command, -o => $filename, $url) };
#          $first_error = $@;
#          if($first_error eq '')
#          {
#            return {
#              type     => 'file',
#              filename => $filename,
#              path     => path($filename)->absolute->stringify,
#            };
#          }
#        }
#        
#        {
#          my($stdout, $stderr) = eval { $self->_execute($build, $self->curl_command, -l => "$url/") };
#          if($@ eq '')
#          {
#            chomp $stdout;
#            return {
#              type => 'list',
#              list => [
#                map { { filename => $_, url => "$url/$_" } } sort split /\n/, $stdout,
#              ],
#            };
#          };
#        }
#
#        $first_error ||= 'unknown error';
#        die $first_error;
#
#      }
      else
      {
        die "scheme $scheme is not supported by the Fetch::CurlCommand plugin";
      }
      
    },
  ) if $self->curl_command;
  
  $self;  
}

sub _execute
{
  my($self, $build, @command) = @_;
  $build->log("+ @command");
  my($stdout, $stderr, $err) = capture {
    system @command;
    $?;
  };
  if($err)
  {
    chomp $stderr;
    $stderr = [split /\n/, $stderr]->[-1];
    die "error in curl fetch: $stderr";
  }
  ($stdout, $stderr);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Alien::Build::Plugin::Fetch::CurlCommand - Plugin for fetching files using curl

=head1 VERSION

version 1.39

=head1 SYNOPSIS

 use alienfile;
 
 share {
   start_url 'https://www.openssl.org/source/';
   plugin 'Fetch::CurlCommand';
 };

=head1 DESCRIPTION

B<WARNING>: This plugin is somewhat experimental at this time.

This plugin provides a fetch based on the C<curl> command.  It works with other fetch
plugins (that is, the first one which succeeds will be used).  Most of the time the best plugin
to use will be L<Alien::Build::Plugin::Download::Negotiate>, but for some SSL bootstrapping
it may be desirable to try C<curl> first.

Protocols supported: C<http>, C<https>

=head1 PROPERTIES

=head2 curl_command

The full path to the C<curl> command.  The default is usually correct.

=head2 ssl

Ignored by this plugin.  Provided for compatibility with some other fetch plugins.

=head1 SEE ALSO

=over 4

=item L<alienfile>

=item L<Alien::Build>

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

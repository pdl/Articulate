package Articulate::Authentication::Preconfigured;
use Moo;

use Digest::SHA;
use Articulate::Storage;
use Time::HiRes; # overrides time()

=head1 NAME

Articulate::Authentication::Preconfigured

=cut

=head1 WARNING

Warning: This is highly insecure, you will be storing your passwords in plain text in the configuration file.

=head1 METHODS

=cut
has passwords => (
  is      => 'rw',
  default => sub { { } },
);

=head3 authenticate

  $self->authenticate( $user_id, $password );

Returns the user id if the password matches. Returns undef otherwise.

=cut

sub authenticate {
  my $self     = shift;
  my $user_id  = shift;
  my $password = shift;

  if ( exists $self->passwords->{$user_id} ) {
    return $user_id if $password eq $self->passwords->{$user_id};
  }
  # if we ever need to know if the user does not exist, now is the time to ask,
  # but we do not externally expose the difference between
  # "user not found" and "password doesn't match"
  return undef;
}


1;

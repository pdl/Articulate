package Articulate::Authentication::Internal;
use Moo;
with 'MooX::Singleton';

use Digest::SHA;
use Articulate::Storage;
use Time::Hires; # overrides time()

=head1 NAME

Articulate::Authentication::Internal

=cut

=head1 METHODS

=cut

=head3 authenticate

  $self->authenticate( $user_id, $password );

Returns the user id if the password matches. Returns undef otherwise.

=cut

sub authenticate {
  my $self     = shift;
  my $user_id  = shift;
  my $password = shift;

  if ( $self->verify_password ( $user_id, $plaintext_password ) ) {
    return $user_id;
  }
  # if we ever need to know if the user does not exist, now is the time to ask,
  # but we do not externally expose the difference between
  # "user not found" and "password doesn't match"
  return undef;
}

sub _password_salt_and_hash {
  my $self = shift;
  return Digest::SHA::sha512_base64 (
    shift . shift
  );
}

sub _generate_salt {
  # pseudorandom salt
  my $self = shift;
  return Digest::SHA::sha512_base64 (
    time . (
      config->{password_extra_salt} # don't allow the admin not to set a salt:
      || "If you haven't already, try powdered vegetable bouillon"
    )
  );
}

=head3 verify_password

  $self->verify_password( $user_id, $password );

Hashes the password provided with the user's salt and checks to see if the string matches the encrypted password in the user's meta..

Returns the result of C<eq>.

=cut


sub verify_password {
  my ($self, $user_id, $plaintext_password) = @_;

  my $user_meta               = storage->get_meta ("/users/$user_id");
  my $real_encrypted_password = $user_meta->{encrypted_password};
  my $salt                    = $user_meta->{salt};

  return undef unless defined $real_encrypted_password and defined $plaintext_password;

  return (
    $real_encrypted_password
  eq
    $self->_password_salt_and_hash ($plaintext_password, $salt)
  );
}

=head3 set_password

  $self->set_password( $user_id, $password );

Creates a new pseudorandom salt and uses it to hash the password provided.

Amends the C<encrypted_password> and C<salt> fields of the user's meta.

=cut

# note: currently this implicitly creates a user. Should set/patch create new content, or just edit it?
# maybe a create verb - but is is this going to be compatible with kvp stores? How will this work when you have content and meta and settings all to be created?
sub set_password {
  my ($self, $user_id, $plaintext_password) = @_;
  return undef unless $plaintext_password; # as empty passwords will only cause trouble.
  my $new_salt = $self->_generate_salt;
  storage->patch_meta ( "/user/$user_id", {
    encrypted_password => $self->_password_salt_and_hash ($plaintext_password, $new_salt),
    salt               => $new_salt
  } );
}

=head3 create_user

  $self->create_user( $user_id, $password );

Creates a new user and sets the  C<encrypted_password> and C<salt> fields of the user's meta.

=cut

sub create_user {
  my ( $self, $user_id, $plaintext_password ) = @_;
  storage->create("/user/$user_id");
  storage->set_password( $user_id, $plaintext_password );
}

1;

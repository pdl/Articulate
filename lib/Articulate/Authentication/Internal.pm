package Articulate::Authentication::Internal;
use Moo;
use Digest::SHA;
use Articulate::Storage;
use Time::Hires; # overrides time()

sub login {
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

# note: currently this implicitly creates a user. Should set/patch create new content, or just edit it?
# maybe a create verb - but is is this going to be compatible with kvp stores? How will this work when you have content and meta and settings all to be created?
sub set_password {
  my ($self, $user_id, $plaintext_password) = @_;
  return undef unless $plaintext_password; # as empty passwords will only cause trouble.
  my $new_salt = $self->_generate_salt;
  patch_meta ( "/user/$user_id", {
    encrypted_password => $self->_password_salt_and_hash ($plaintext_password, $new_salt),
    salt               => $new_salt
  } );
}

1;

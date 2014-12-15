package Articulate::Error::Unauthorised;

use Moo;
extends 'Articulate::Error';

has '+simple_message' =>
  default => 'Forbidden';

has '+http_code' =>
  default => 401;

1;

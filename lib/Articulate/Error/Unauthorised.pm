package Articulate::Error::Unauthorised;

use Moo;
extends 'Articulate::Error';

has '+simple_message' =>
  default => 'Unauthorised';

has '+http_code' =>
  default => 401;

1;

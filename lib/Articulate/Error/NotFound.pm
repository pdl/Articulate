package Articulate::Error::NotFound;

use Moo;
extends 'Articulate::Error';

has '+simple_message' =>
  default => 'Not found';

has '+http_code' =>
  default => 404;

1;

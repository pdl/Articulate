package Articulate::Error::BadRequest;

use Moo;
extends 'Articulate::Error';

has '+simple_message' =>
  default => 'Bad Request';

has '+http_code' =>
  default => 400;

1;

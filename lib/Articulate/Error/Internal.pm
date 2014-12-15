package Articulate::Error::Unauthorised;

use Moo;
extends 'Articulate::Error';

has '+simple_message' =>
default => 'Internal Server Error';

has '+http_code' =>
default => 500;

1;

package Articulate::Error::AlreadyExists;

use Moo;
extends 'Articulate::Error';

has '+simple_message' =>
default => 'Already exists';

has '+http_code' =>
default => 409;

1;

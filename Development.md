# Developing (with) Articulate

Articulate is designed to be easy to get involved in, even if you've only done a little bit of Perl before. If you're interested in helping the work along, here are some of the things you could do:

- Write a provider
- Improve test coverage
- Improve documentation coverage, or add documentation examples
- Write example apps in the examples/ folder

Because so much of Articulate's core functionality is plugin-like, advice for working __with__ Articulate will usually be the same as advice for working __on__ Articulate. This also functions as a guide to both.

### Setting up

To work on Articulate itself, you will need perl (system perl is fine if you have it, perlbrew is a good idea and Strawberry Perl if you're on Windows) and cpanminus ( you can get a copy from http://cpanmin.us ).

Once you have cpanm, run to following script (which will install prerequisites of Articulate, plus Dancers 1 and 2 and some other tools you'll need, and to set up git hooks for perltidy):

    dev-setup.sh

And that's it! You should be ready to work on Articulate.

### Coding style

Coding style is mostly enforced by perltidy. A synopsis of the config is:

- 2 spaces, no tabs
- No 'cuddled' else
- Loose horizontal spacing - `$self->( 2, $tokens )`

Other miscellaneous style notes:

- Separate_with_underscores not camelCase
- British English is used and in particular -s- variants: authorise not authorize (although both are in common use in British English).
- In general, use abstract nouns for components, adjectives for providers.
- In general, use nouns for attributes, accessors, verbs for methods which do something significant (mutate an object, read from a db/file). Boolean attributes may be things like is_adjectival
- private methods begin with underscore.

### Core development ideas

- Simple: Components and their providers should Do One Thing Well.
- Easy to get started: components are typically small, with a narrow interface and it should be easy to write one and see what one does.
- Reusable: The path of least resistance is the path which leads you to write code you can share.
- Configurable: The delegation and instantiation idioms make configurability really easy by default, so you don't have to reinvent the wheel working out how the user should pass arguments in.

### Single return value

Methods and functions should have a single return value wherever possible. If you are writing a function whose explicit purpose is to return a list, do so as an array reference or an object.

This is important because:

- around subs may be written which may assume there is only a single return value.
- Hash value assignment is array context. Returning a list is a good way of breaking the hash and introducing bugs.

#### Objects as interfaces

Objects like Articulate::Permission are useful for avoiding long argument lists in invocation. They're also good at responses. For delegation tasks, using items which know whether the task has been completed (e.g. Articulate::Permission) as both the argument and return value is a useful pattern where the task is such that only one provider need respond.

#### Prefer references

In general, hash references and array references are strongly preferred. Any code which returns lists or accepts flat hashes or arrays should be considered subject to change.

That said, always dereference for builtins, so as not to break things for perls up to 5.12 and (in some cases) from 5.20 onwards.

Encouraged:

  my $items = [];
  push @$items, $item;

Discouraged:

  my $items = [];
  push $items, $item;

Discouraged:

  my @items;
  push @items, $item;

### Permit delegation

Wherever it may make sense to do so, provide an interface for delegation.

### Delegation implies instantiation

When delegating, accept configuration in how you delegate and use the instantiate functions in Syntax to do so.

### Testing

As a developer working on Articulate, the Articulate core can be tested as follows:

  perl Makefile.PL
  make
  make RELEASE_TESTING=1 test

To test frameworks (using the version of Articulate in your working copy), `cd` into the framework directory use the following:

  RELEASE_TESTING=1 prove -I../../lib -l t/*

Common storage tests will ultimately need to be made into a library. All storage implementations must pass the same set of tests.

### Exporting

In general modules which export functions fall into one of three categories:

- Provides features of general interest, in which case put it on CPAN
- Provides features of no interest except in one particular application, in which case use it in your private code.
- Syntactic sugar which are specific to Articulate as a whole

Almost anything else can be provided as a service.

### Moo

Articulate uses Moo, and in any code written for Articulate should use Moo (unless it is purely functional).

Using Moose is fine for your application (Moo is Moose-friendly) but for reusable components that you are going to share, Moo is strongly preferred.

Moo attributes should be written with brackets surrounding all the arguments which follow the attribute name, so that they will be indented properly in perltidy.

  has attrname => (
    is      => 'rw',
    default => sub { ...}
  );

### Advice on writing a...

In general, working with Articulate, you will be replacing or introducing providers for components. Generally the default component will contain useful information, e.g. if you're writing an authorisation provider, take a look at L<Articulate::Authorisation>. Also look at other providers of the same type and see how they do things.

Providers are bite-sized and simple, and many have only one method (other than `new`). A few providers are necessarily more substantial, such as Storage providers.

Components should focus on doing one thing well. Providers will typically be a thin adapter to a CPAN module (exposing as much config as practical) or a well-defined, application-specific operation. If you need complex logic, especially in augmentation or enrichment, consider a flow class.

#### ... service

Services are where you encode the complex business logic that doesn't fit neatly elsewhere. The 'one thing they do well' is providing a clean interface to complex operations.

#### ... routes package

Routes are where you The 'one thing they do well' is mediating between the (sometimes) messy input - the HTTP request, the framework adapter, etc. - and the (hopefully) clean interface of the services.

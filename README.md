# Articulate, a Lightweight Perl CMS Framework

## Synopsis

Articulate provides a content management service for your web app. Lightweight means placing minimal demands on your app while maximising 'whipuptitude': it gives you a single interface in code to a framework that's totally modular underneath, and it won't claim any URL endpoints for itself.

You don't need to redesign your app around Articulate, it's a service that you call on when you need it, and all the 'moving parts' can be switched out if you want to do things your way.

It's written in Perl, the fast, reliable 'glue language' that's perfect for agile web development projects, and currently runs on the Dancer1 and Dancer2 web frameworks.

## Caveat

> Warning:
>
> This is work in progress! It's alpha-stage software and important things WILL change.
>
> Articulate isn't on CPAN yet - but don't worry, it will be when it's just a little bit more stable.
>
> If you want a preview, there's an example blog engine included, just clone the repository and type:
>
>     cd examples/plain-speaking
>     bin/app.pl
>
>  ... and then go to http://localhost:3000/
>
> Don't want a blog? Don't worry, many other things are possible!


## Roadmap

Articulate is intended to provide a flexible and lightweight core for content management which can be customised using plugins.

Articulate uses modern Perl and tries to avoid huge dependencies, while making use of really good bits of CPAN like Moo, Module::Load and IO::All.

High-level milestones:

- Write some Proof of Concept applications in order to test out the core interface
- Finalise the interfaces as far as possible and provide sufficient documentation and test coverage for a CPAN release
- Flesh out the default plugin infrastructure, develop some recommendations for writing plugins

Right now it runs atop Dancer1, and (as of February 2015) Dancer2, and support for other frameworks is a goal.

Initial concept work on Articulate started in early 2014 and it was rewritten from scratch in November 2014.

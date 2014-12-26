# Articulate, a Lightweight Perl CMS Framework

## Synopsis

Articulate provides a content management service for your web app. Lightweight means placing minimal demands on your app while maximising 'whipuptitude': it gives you a single interface in code to a framework that's totally modular underneath, and it won't claim any URL endpoints for itself.

You don't need to redesign your app around Articulate, it's a service that you call on when you need it, and all the 'moving parts' can be switched out if you want to do things your way.

It's written in Perl, the fast, reliable 'glue language' that's perfect for agile web development projects.

## Caveat

> Warning:
>
> This is work in progress! It's alpha-stage software and important things WILL change.
>
> Currently the interface is not final so examples would be premature.
>
> For the same reason, it isn't on CPAN yet - but don't worry, it will be.

## Roadmap

Articulate is intended to provide a flexible and lightweight core for content management which can be customised using plugins.

Articulate uses modern Perl and tries to avoid huge dependencies, while making use of really good bits of CPAN like Moo, Module::Load and IO::All.

- Write some Proof of Concept Applications
- 

Right now it runs atop Dancer1, but the intention is to ensure it also supports Dancer2 and maybe some other frameworks if there is demand.

Initial concept work on Articulate started in early 2014 and it was rewritten from scratch in November 2014.

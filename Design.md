Articulate is an expression of the idea that a CMS is foremost an API:

- it should not place arbitrary restrictions on the front end
- it should not place arbitrary restrictions on role of the content (blog, issue tracker, wiki)
- it should not place arbitrary restrictions on the content-types you want to host, or how you want to edit them
- it should not force you into a url schema you don't want.

It should be easy to add an Articulate component to a project with other functions.

Each page component is loaded

GET zone/foo/article/foo/section/2 # retrieval from cache

GET zone/foo/article/foo/section/2/edit # retrieval from source. Once done, void cache.

GET zone/foo/article/foo/comments/add/

POST article

A document looks in

GET /permalink/slug

IN FOLDER /content/

The application can always retrieve a meta.yml file

todo: write a slug sorter


?? Content requests are always JSON except that /article/foo calls unless they ask for JSON will default to the full HTML template plus

## Qs

### How to convert a blob to HTML?

The blob must be of a type.

### Can a blob be edited?

Depends on the blob type. If it is a subclass of file, probably not.

If the blob type has an associated edit method - this needs to make the browser load some js and maybe pass some arguments. Eg. load the XML editor and configure it.

### Can a blob be validated?

The blob type needs an associated validator writing.

### Can a blob be during editing?

### Does metadata need validating?

Ultimately yes. It may need to conform to several progressively more restrictive schemas.

### Can we create structured/HTML-encoded results?

Each section has a type.

Groups could be on a zone basis, e.g. public/authors (roles?)

What about Groups of groups, e.g. "developer" across projects

### Implementation

Create a content interpreter which gets meta and content together, and does things like run the XSLT. For this we really need the content retrieval to be OO.

The intepreter should be configured with a list of converters.

It will take the content and determine if it can convert the contents into HTML using the tools it has. If it cannot, it will offer a file location for download.

### Components

How are components (sections, comments, etc.) stored, loaded, configured, etc?

Does this include metadata extractors?

Problem: If you load a section, you need to run all the interpreters

Before the response is passed to the template, the components are loaded in order.

$component->process( $response ); # the response is mutated in-place


### Architecture summary

- Plack Middleware
- Templating
- Route handlers
- Service handlers
- Components
- Interpreters
- Content Storage
- DB/FS

### Architecture detail

- Plack Middleware
- Templating
- Route handlers
- authentication
- Service handlers - these provide all the API features, including making calls to the authentication layer, components, intperpreters, content storage. Methods are largely like content storage.
  - get_content_raw
- Components - these are called in series and are effectively several layers
  - process ($response, $context); # where context is stuff like session, params, etc.
- Interpreters - these are called in parallel, i.e. no more than one on a given piece of content
  - can_interpret ($content_type, $target_type // 'html')
  - intepret ($content_type, $content, $meta, $target_type // 'html')
- Content Storage - must provide:
  - get_item
  - get_item_cached
  - set_item
  - create_item
  - get_content
  - get_content_cached
  - set_content
  - get_meta
  - get_meta_cached
  - set_meta
    patch_meta
  - get_settings
  - get_settings_cached
  - set_settings
  - empty_content
  - and indexes??
  - Delete zone? Cascade delete?
- DB/FS

Service handlers are the fulcrum of the application and should not need to be changed.
The route handlers and templating can be rewritten at will. Components down through content storage are configured like plugins.

### Caching and indexing

The Content component is responsible for caching content, meta, etc, and also clearing the cache when edits are made. This is a low-priority issue to implement.

What about indexing things post-component? e.g. do some metadata extraction to get datesdates, then search? I wonder if indexes need to be maintained separately from content, especially to avoid contamination by non-UGC.

What about indexing with a separate service, e.g. store content locally but hive off document search to a solr instance?

### Versioning

Can this be done with a component?

### Content locking

lock_item ($user, $endtime)


### Setup

Like `dancer -a`

articulate -a --preset=empty

  bin
  lib
  content
  indexes
  public
  t

Other presets can be defined like webservice, blog, issue tracker, wiki.

---

permissions:
  view:
    groups:
    users:
  link:
    groups:
    users:
  edit:
    groups:
    users:
  assign:
    groups:
    users:
meta:
  core:
	history:
		- user:
		  date:
		- user:
		  date:
  schemaorg:
content_type: markdown

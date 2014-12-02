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

Service handlers are the fulcrum of the application and should not need to be changed.
The route handlers and templating can be rewritten at will. Components down through content storage are configured like plugins.

### Caching and indexing

The Content component is responsible for caching content, meta, etc, and also clearing the cache when edits are made. This is a low-priority issue to implement.

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

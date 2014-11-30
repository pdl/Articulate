Articulate is an expression of the idea that a CMS is foremost an API:

- it should not place arbitrary restrictions on the front end
- it should not place arbitrary restrictions on role of the content (blog, issue tracker, wiki)
- it should not place arbitrary restrictions on the content-types you want to host, or how you want to edit them
- it should not force you into a url schema you don't want.

It should be easy to add an Articulate component to a project with other functions.

Each page component is loaded

GET zone/foo/article/foo/section/2 # retrieval from index

GET zone/foo/article/foo/section/2/edit # retrieval from source

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

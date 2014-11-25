Each page component is loaded 

GET zone/foo/article/foo/section/2 # retrieval from index

GET zone/foo/article/foo/section/2/edit # retrieval from source

GET zone/foo/article/foo/comments/add/

POST article

A document looks in 

GET /permalink/slug


IN FOLDER /content/


The application can always retrieve a meta.yml file 


Content requests are always JSON except that /article/foo calls unless they ask for JSON will default to the full HTML template plus 


Each section has a type. 



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

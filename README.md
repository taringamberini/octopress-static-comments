This is a fork inspired by:

* [Matt Palmer Jekyll Static Comments plugin](http://theshed.hezmatt.org/jekyll-static-comments)
* [Kaimi Octopress Static Comments plugin](https://github.com/kaimi/octopress-static-comments)

# Octopress StaticComments

Whilst most people go for a Disqus account, or some similar JS-abusing means
of putting comments on their blog, I'm old-fashioned, and like my site to be
dead-tree usable. Hence this plugin: it provides a means of associating
comments with posts and rendering them all as one big, awesome page.

Features:

* receiving comments via email
* automatically generated comment permalink
* comments written in markdown

## Quick Start (or "what are all these files for?")

1. Move the `plugins`, `sass` and `source` folders into your octopress
   directory. For pure Jekyll, find out where to put the files first :)

1. include the comments section somewhere in your site template
   (`{% include custom/comments.html %}`).

1. Create a `_comments` directory in your `source` directory, and populate it
   with YAML comments.

1. Enjoy a wonderful, spam-free, static-commenting Nirvana.

If you receive a comment email:

1. Copy the mail’s content to a file in `source/_comments`.

1. Replace the `=` in each key value pair with `: `.

1. Add a `date: YYYY-MM-DD HH:MM` line according to the email data.

1. Rebuild and -upload your site.

## Technical details

### Where to store comments

To use StaticComments, you need to have a store of comments; this is a
directory, called `_comments`, which contains all your comments.  You can
have an arbitrary hierarchy inside this `_comments` directory (so you can
put comments in post-specific directories, if you like), and the `_comments`
directory can be anywhere in your site tree (I put it alongside my `_posts`
directory). The files containing comments can be named anything you like --
every single file within the `_comments` directory will be read and parsed
as a comment.

### Comment content and other fields

Each file in `_comments` represents a single comment object, as a YAML hash.
The YAML must contain:

* a `post_id` field, which corresponds to the `id` of the post it is a
  comment on
* a `date` field, which corresponds to the email date
* a `comment` field, which contains the comment

but apart from that the YAML fields are anything you want them to be.

The fields in your YAML file will be mapped to fields in a Comment
object. There is a new `page.static_comments` field, which contains a list
of the comment objects for each post. Iterating through a post and printing
the comments is simple. For example if your YAML comment file is:

    ---
    name: Ann
    link: https://www.ann.com
    comment: 'Hi Tarin,

      Thanks for this great post.

      Cheers'

you can iterate and print post comments with:

    {% for c in page.comments %}
      <a href="{{c.link}}">{{c.name}}</a>
      <p>
        {{c.comment | newline_to_br}
      </p>
      <hr />
    {% endfor %}

Your YAML fields, of course, may vary.

### Comment permalink

Each comment has an automatically generated `comment_id` YAML field which can
be used as a comment permalink:

    {% for c in page.comments %}
      <a href="#{{c.comment_id}}" title="Permalink">#</a>
      <p id="{{c.comment_id}}">
        {{c.comment | newline_to_br}}
      </p>
      <hr />
    {% endfor %}


The `comment_id` value is computed as the ordinal position of the comment
among all comment YAML files sorted by their mandatory `date` field.

In this way you are free both to call your comment YAML files as you prefer,
and storing (or moving) them everywhere under `_comments` directory.

### Comment written in markdown

You can include comment as markdown. For example if your comment YAML file
has a comment written in markdown:

    ---
    post_id: /blog/Great-Post
    date: 2016-03-13 22:20
    name: Ann
    comment: ! 'Hi Tarin,


      Thanks for this great post.


      I would add that ...


      Best regards,<br />Ann'

you can include it by using the `markdownify` filter:

	{% for c in page.comments %}
      <div>
        {{c.comment | markdownify}}
      </div>
      <hr />
	{% endfor %}

For examples see the `source/_comments/` directory.

### Comments moderation

E-mailing the comments to you, though, is a fairly natural workflow.  You
just save the comments out to your `_comments` directory, then re-generate
the site and upload.  This provides a natural "moderation" mechanism, at the
expense of discouraging wide-ranging "realtime" discussion.

## A caveat about Liquid

Never use the word `comment` by itself as an identifier of any kind
(variable, whatever) in your Liquid templates: the language considers it to
be the start of a comment (regardless of where it appears) and eats your
code.  Yes, apparently Liquid really *is* that stupid.  At the very least,
you'll need to put a prefix or suffix or something so that Liquid doesn't
think you're trying to execute it's `comment` function.

## Licencing, bug reports, patches, etc

This plugin is licenced under the terms of the [GNU GPL version
3](http://www.gnu.org/licenses/gpl-3.0.html).

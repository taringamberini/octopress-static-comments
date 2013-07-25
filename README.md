This is a fork of https://github.com/mpalmer/jekyll-static-comments using a
html email form instead of a php script to send comment emails. This way,
your web server still has to serve static web pages only.

# Jekyll::StaticComments

Whilst most people go for a Disqus account, or some similar JS-abusing means
of putting comments on their blog, I'm old-fashioned, and like my site to be
dead-tree useable.  Hence this plugin: it provides a means of associating
comments with posts and rendering them all as one big, awesome page.

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

1. (optional) Remove the `submit: submit` line.

1. Rebuild and -upload your site.

## Technical details

To use StaticComments, you need to have a store of comments; this is a
directory, called `_comments`, which contains all your comments.  You can
have an arbitrary hierarchy inside this `_comments` directory (so you can
put comments in post-specific directories, if you like), and the `_comments`
directory can be anywhere in your site tree (I put it alongside my `_posts`
directory).  The files containing comments can be named anything you like --
every single file within the `_comments` directory will be read and parsed
as a comment.

Each file in `_comments` represents a single comment, as a YAML hash.  The
YAML must contain a `post_id` attribute, which corresponds to the `id` of
the post it is a comment on, but apart from that the YAML fields are
anything you want them to be.

The fields in your YAML file will be mapped to fields in a Comment
object.  There is a new `page.comments` field, which contains a list of the
Comment objects for each post.  Iterating through a post and printing the
comments is as simple as:

    {% for c in page.comments %}
      <a href="{{c.link}}">{{c.nick}}</a>
      <p>
        {{c.content}}
      </p>
      <hr />
    {% endfor %}

This, of course, assumes that your YAML comments have the `link`, `nick`,
and `content` fields.  Your mileage will vary.

The order of the comments list returned in the page.comments array is
based on the lexical ordering of the filenames that the comments are
stored in.  Hence, you can preserve strict date ordering of your comments
by ensuring that the filenames are based around the date/time of comment
submission.

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

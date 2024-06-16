+++
title = "Migrating from Jekyll to Zola while preserving permalinks"
time = 2024-06-17T10:00:00+03:00
[extra]
toc = true
+++

## Intro

I've been deploying this blog using [Jekyll] for quite a while now. This is the
default choice for GitHub Pages, so why not. I've only been writing here
occasionally from the same laptop, so it did not bother me too much. _Until it
did_.

Jekyll is Ruby-based software. So you need to deal with Ruby. I tried wrapping
it into `nix`, which I've been using at one of my jobs, but it was almost
painfully slow. Also, I did not have any inspiration to write my custom themes
and I did not find anything pretty for Jekyll. The default [minima] theme is
honestly just hot garbage.

I tried [Hugo], but it just didn't sit right with me. So, after doing some
searching I settled with the combination of [Zola] with the [Anemone] theme. It
is beatiful, it is fast, it does live reloads out of the box and Zola is just a
single binary. No dependency hell, yay! And just a superior experience overall.

But the transition is not very straightforward. When you have a bunch of links
you posted across the Internet, you want to keep them alive regardless of what
software you use to generate your site. With the default settings (that I have
been using, of course), Jekyll generates permalinks that look like this:
`/blog/<year>/<month>/<day>/<page-name>`. Well, Zola doesn't do that. And
[doesn't plan][links-issue] to do that. Not a big issue for any _future_ pages,
I literally don't care. But old permalinks and the feed need to be preserved
somehow. Oh, and the time format is incompatible too, since Zola sticks to
RFC3339.

Ok, this is going to be an interesting evening and I need some beer. Let's get
started...

[Jekyll]: https://jekyllrb.com/
[minima]: https://github.com/jekyll/minima
[Hugo]: https://gohugo.io/
[Zola]: https://www.getzola.org/
[Anemone]: https://github.com/Speyll/anemone
[links-issue]: https://github.com/getzola/zola/issues/635#issuecomment-524564469

## The setup

Assuming you have done the initial setup with Zola and Anemone, let's create our
blog page:

```bash
mkdir content/blog
cp themes/anemone/content/blog/_index.md content/blog
```

Now we have an empty blog. Next, let's copy the contents of our old Jekyll-based
blog.

```bash
cp <path-to-jekyll-blog>/_posts/*.md content/blog
```

Now we have an empty blog that doesn't work. **Awesome.**

## Timestamps

That's an easy one. Jekyll timestamps this form `2018-08-11 18:42:00 +0300`
aren't RFC-compatible. But something like this is: `2018-08-11 18:42:00+03:00`.
This calls for a simple `sed` line:

```bash
sed -i -e 's/ +0300/+03:00/g' content/blog/**/*.md
```

If you have multiple timezones, just do that for these timezones as well. It can
be done nicer, but for me it was only two timezones, so I can't be bothered.

Now we have the blog that works, but the permalinks are not the same and we need
to fix that.

## Permalinks

We have no choice but to make up for the lack of this capability in Zola by
leveraging the directory structure. E.g. do something like this:

```
content
├── blog
│   ├── 2018
│   │   ├── 08
│   │   │   ├── 11
│   │   │   │   ├── 2018-08-11-tiny-docker-images.md
```

Yes, it's bad, but it works and these are old posts, so I am not going to touch
most of them anyway.

I did the job with a simple Python script:

```python
import os
import pathlib
import shutil

# front matter for intermittent _index.md files
FRONT_MATTER = """
---
render: false
transparent: true
redirect_to: "/blog/"
---
"""

BASE = "content/blog/"

files = os.listdir(BASE)

for file in files:
    # don't do anything for _index.md
    if file == "_index.md":
        continue
    # construct directory paths
    sections = file.split("-")[:3]
    pf = BASE + "/".join(sections)
    # create these dirs
    pathlib.Path(pf).mkdir(parents=True, exist_ok=True)
    # magical _index.md files
    for i in range(1, 4):
        p = BASE + "/".join(sections[:i]) + "/_index.md"
        with open(p, "w") as f:
            print(FRONT_MATTER, file=f)
    # move our post to the correct place
    shutil.move(BASE + file, pf + "/" + file)
```

This script creates the appropriate directory structure, places our article
inside it and creates empty `_index.md` files in all subdirectories. They are
not rendered, but are needed for Zola to see your directory structure correctly.
Otherwise your posts are not going to be rendered. `transparent: true` makes it
so that whatever theme you are using it sees the posts nested inside these
directories.

## Preserving `feed.xml`

If your Jekyll blog generated the RSS/Atom feed, you want to have it with Zola
as well. Good news: Zola can do that. Bad news: out of the box you are limited
to either `atom.xml` or `rss.xml`. That one is easy to solve, though. Just copy
Zola's template to your `templates` directory and rename it:

```bash
wget https://raw.githubusercontent.com/getzola/zola/b965c89d12689d658a70f67f78d9de76b1a1cf48/components/templates/src/builtins/atom.xml
mv atom.xml feed.xml
```

Then add this to your `config.toml`:

```toml
generate_feed = true
feed_filename = "feed.xml"
```

Woohoo, you are set! Almost...

## Fixing links in Anemone

If you are using Anemone, this section is for you. If you don't, do check that
all links in your templates are correct. I warned you.

Anyway, here are the patches to fix links in Anemone:

- [themes/anemone/templates/head.html](/patches/anemone-head.patch)
- [themes/anemone/templates/blog-page.html](/patches/anemone-blog-page.patch)
- [themes/anemone/templates/footer.html](/patches/anemone-footer.patch)

Just apply these patches and you are _finally_ done.

## Conclusion

While the proper transition was definitely not straightforward, I definitely
enjoy my new setup. It looks nice and it's a pleasure to work with. Zola is a
great software and it has a vibrant community with some pretty nice design, like
the one you are looking at right now.

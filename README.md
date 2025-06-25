# blog-server

This server adds dynamic elements to [my static blog](https://github.com/zsarge/zsarge.github.io) on <https://zack.fyi>.

This server contains:
- comments
    - the comment system is designed to be as barebones as possile.
    - the comment system has no concept of a post, but simply collects comments based on their associated URL
      - while lacking in database elegance, this seems to more neatly mesh with integration into my static site
    - We'll see if I regret that, but I wanted something without accounts; just something where people can contribute to the content of a blog post, without it being a community or anything.
    - I'm interested to see how a system like this fares in 2025, in the age of AI and spam.

to do:
- comment system
   - pagination
    - plan: kaminari for post level pagination
    - use AJAX for getting more replies to a comment via pagination?
    - use threading to handle depth
   - verification system via console
   - mailers
       - on comment
       - on report
    - webmention support?
- cached file system via google drive
- automatically back up db to google drive
- authentication / authorization (people should not be able to perform destructive actions without authorization)


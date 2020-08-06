# journaling-on-github


A repo set up to do some quick lightweight journaling on Github, using primarily github flavored Markdown

## How to use/build

Given an article directory like [articles/easy-example](articles/easy-example) or [articles/complex-example](articles/complex-example), running the following make command:

```sh
$ make articles/complex-example/index.md
```

Will produce a `index.md` that is a result of concatenating all the markdown files in articles/SUBDIRECTORY, e.g

- [articles/easy-example/index.md](articles/easy-example/index.md)  
- [articles/complex-example/index.md](articles/complex-example/index.md)



## Article subdirectory structure

How to structure the files in an article subdirectory

### Simple example

Create a subdirectory for each article. That subdirectory should contain a list of Markdown files to be concatenated into `SUBDIR/index.md` and `docs/SUBDIR/index.html`. For example:



### More complicated example

Most articles you write will probably link to images and other files. The builder expects your article-directory to have a local `assets` subdirectory, from which the component markdown files are locally referring to. For example:

with a subdirectory for assets (like images) specific to that article, e.g.

```
sample-article/
    ├── 001-intro.md
    ├── 002-lorem.md
    ├── 200-funtimes.md
    ├── 200-subsec
    │   ├── 201-sub-hello.md
    │   └── 202-sub-world.md
    ├── 999-goodbye.md
    |── _800-just-a-draft-to-ignore.md
    └── assets
        ├── files
        │   └── sample-data.csv
        └── images
            ├── bye.jpg
            └── hello.jpg
```

#### Subdirectories for your subsections

If you're writing a REALLY complicated article and need subdirectories for your subsections, go ahead and make them. The builder does a recursive search for all `*.md` files in the article subdirectory. The compilation is done by ordering the files by name, alphabetically.


#### Ignore Markdown files by putting a leading underscore in the filename

These Markdown files would be ignored

```
articles/hello/_800-just-a-draft-to-ignore.md
```

These *would not* be ignored:

```sh
articles/_drafts/hello.md
```







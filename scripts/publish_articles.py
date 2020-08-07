#!/usr/bin/env python3
"""

Replaces this stupid make task
publish:
    # todo:
    # - use rsync obviously
    # - rewrite assets paths? or no need?
    find $(ARTICLES_DIR) -name 'index.md' | sort | while read -r idxname; do \
        echo "Processing $$idxname"; \
        srcdir=$$(dirname $$idxname); \
        bdname=$$(basename $$srcdir); \
        targetdir=$(PUBLISH_BUILD_DIR)/$$bdname; \
        echo "Creating $$targetdir"; \
        mkdir -p $$targetdir; \
        if [[ -d "$$srcdir/assets" ]]; then cp -r $$srcdir/assets $$targetdir/assets; fi; \
        target=$$targetdir/index.html; \
        pandoc -f markdown -t html $$idxname | ./scripts/publish_html.py > $$target ;\
    done
#       pandoc -f markdown -t html -o $$target $$idxname; \

"""

from lxml.html import fromstring as lxsoup
from pathlib import Path
from sys import argv, stdin, stdout, stderr
from jinja2 import Template
import pypandoc
import subprocess

HTML_TEMPLATE_PATH = Path('scripts/assets/html_template.html')
HTML_TEMPLATE = HTML_TEMPLATE_PATH.read_text()

MAIN_INDEX_TEMPLATE_PATH = Path('scripts/assets/main_index_template.html')
MAIN_INDEX_TEMPLATE = MAIN_INDEX_TEMPLATE_PATH.read_text()


RSYNC_EXCLUDED = '.DS_Store'
RSYNC_INCLUDED_SUBDIRS = ('assets', )


def mylog(*args, label=None):
    lab = f"{label}:" if label else "LOG:"
    txt = ' '.join(str(s) for s in args)
    stderr.write(f"{lab} {txt}\n")


def convert_markdown(rawtxt):
    html = pypandoc.convert_text(rawtxt, 'html', format='md')
    return html

def extract_meta(rawhtml):

    def _ex_title(soup):
        s = soup.xpath("//h1/text()")
        return s[0] if len(s) > 0 else ""

    meta = {}
    soup = lxsoup(rawhtml)
    meta['title'] = _ex_title(soup)

    return meta


def prettify_article(rawhtml, meta):
    """
    rawhtml is a text string
    meta is a dict of values, generated from extract_meta
    """
    values = {'content': rawhtml}
    values.update(meta)
    template = Template(HTML_TEMPLATE)

    return template.render(values)

def publish_article(src_path, publish_dir):
    """
    returns a dict of metadata
    path = path relative to `publish_dir`
    title
    (other meta)
    """
    def _get_target_path(srcpath):
        nonlocal publish_dir
        subname = srcpath.parent.name
        fname = srcpath.stem
        return publish_dir.joinpath(subname, f'{fname}.html')

    def _produce_html_file(srcpath):
        mylog(srcpath, label="Reading")
        txt = srcpath.read_text()
        rawhtml = convert_markdown(txt)
        meta = extract_meta(rawhtml)

        newhtml = prettify_article(rawhtml, meta)
        target_path = _get_target_path(srcpath)
        target_path.parent.mkdir(exist_ok=True, parents=True)
        target_path.write_text(newhtml)
        mylog(f"{len(newhtml)} bytes to {target_path}", label="Wrote")

        d = {'path': target_path}
        d.update(meta)
        return d

    def _sync_subdirs(srcpath):
        """
        Given a path to an article file, e.g. articles/stuff/index.md
            Gathers up all the subdirectories in srcpath.parent and
            rsyncs them to the target_path parent dir
        """
        nonlocal publish_dir
        # subprocess.call(["rsync", "-l"])
        _pubdir = _get_target_path(srcpath).parent
        _subdirs = sorted(p for p in srcpath.parent.iterdir() if p.is_dir() and p.name in RSYNC_INCLUDED_SUBDIRS)
        for subdir in _subdirs:
            substr = str(subdir).rstrip('/') + '/'
            pubstr = str(_pubdir.joinpath(subdir.name)).rstrip('/')
            mylog(f"{subdir} to {pubstr}", label="rSyncing")
            subprocess.call(['rsync', '-a', '-m', '--exclude', RSYNC_EXCLUDED, substr, pubstr])

    ## end of subfunctions for publish_article
    article_meta = _produce_html_file(src_path)
    _sync_subdirs(src_path)

    return article_meta


def publish_index(article_metas, target_dir):
    """
    article_metas is a list of dicts

    target_dir is intended to be the github site homepage, e.g. /index.html, not /articles/index.html

    Result: index webpage written to target_dir/index.html
    """
    metas = article_metas.copy()
    for m in metas:
        m['path'] = str(Path(m['path']).relative_to(target_dir))

    target_path = target_dir.joinpath('index.html')

    html = Template(MAIN_INDEX_TEMPLATE).render(articles=metas, page_path=target_path.relative_to(target_dir))

    target_path.write_text(html)


def publish(articles_dir, publish_dir):

    artpaths = articles_dir.glob('**/index.md')
    metas = []
    for src_article_path in artpaths:
        artmeta = publish_article(src_article_path, publish_dir)
        metas.append(artmeta)

    publish_index(metas, publish_dir.parent)

def main():
    srcdir, targdir = [Path(p) for p in argv[1:3]]
    mylog(f"{srcdir}", label="Source dir")
    mylog(f"{targdir}", label="Target dir")

    publish(srcdir, targdir)


if __name__ == '__main__':
    main()



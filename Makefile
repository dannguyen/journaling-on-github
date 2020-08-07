.DEFAULT_GOAL := help

ARTICLES_SOURCE_DIR = articles

PUBLISH_BUILD_DIR = docs/articles


.PHONY : clean help $(ARTICLES_SOURCE_DIR)


help:
	@echo 'Run `make ALL` to see how things run from scratch'


clean:
	@echo "Clean out $(PUBLISH_BUILD_DIR)"
	if [[ -d "$(PUBLISH_BUILD_DIR)" ]]; then rm -r $(PUBLISH_BUILD_DIR); fi


## publishing
# $(PUBLISH_DIR)/%.html : $(ARTICLES_SOURCE_DIR) $(PUBLISH_DIR)
# 	mkdir -p $(PUBLISH_DIR)/assets

publish:
	./scripts/publish_articles.py $(ARTICLES_SOURCE_DIR) $(PUBLISH_BUILD_DIR)
# 	# todo:
# 	# - use rsync obviously
# 	# - rewrite assets paths? or no need?
# 	find $(ARTICLES_SOURCE_DIR) -name 'index.md' | sort | while read -r idxname; do \
# 		echo "Processing $$idxname"; \
# 		srcdir=$$(dirname $$idxname); \
# 		bdname=$$(basename $$srcdir); \
# 		targetdir=$(PUBLISH_BUILD_DIR)/$$bdname; \
# 		echo "Creating $$targetdir"; \
# 		mkdir -p $$targetdir; \
# 		if [[ -d "$$srcdir/assets" ]]; then cp -r $$srcdir/assets $$targetdir/assets; fi; \
# 		target=$$targetdir/index.html; \
# 		pandoc -f markdown -t html $$idxname | ./scripts/publish_html.py > $$target ;\
# 	done
# #		pandoc -f markdown -t html -o $$target $$idxname; \


## compilation:

$(ARTICLES_SOURCE_DIR)/%index.md :  $(ARTICLES_SOURCE_DIR)
	rm -f $(@)
	$(foo-build-article)
	$(foo-insert-article-toc)


define foo-build-article =
find $(dir $@). -name '*.md' -not -name "_*.md" | sort | while read -r fname; do cat $$fname >> $@; done
endef

define foo-insert-article-toc=
[ -e "$(@)" ] && markdown-toc -i "$(@)" || -1
endef



# F--K bash variables and conditionals!!!

# %.zoo:
# 	@echo '-----'
# 	@echo "File is" "$(@)"
# 	@echo "Directory is" $(@D)
# 	@echo Wildcards: $(wildcard $(@D)/..)
# # 	@echo Wildcards: \"$($wildcard $(@D)/*.*)\"
# #	@echo Condition: $(findstring b, dan)

#  ifeq ('..', $($(wildcard $(@D)/..)))
# ifeq ($(strip $(foo)),)
#ifeq ($(strip $(wildcard $(@D)/..)),)
# # ifeq ($(findstring b, dan),)
# # ifeq ($(findstring .., ../tmp/hey),)
# # ifeq ($(findstring .., $(strip $(wildcard $(@D)/..))),)
# ifeq ("$(@)","/tmp/samples/index.zoo")
# 	@echo "1 BLANK: $(@D) for file $(@)"
# else
# 	@echo "2 MATCH: $(@D) for file $(@)"
# endif


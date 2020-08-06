.DEFAULT_GOAL := help

ARTICLES_DIR = articles

PUBLISH_DIR = docs


.PHONY : clean help $(ARTICLES_DIR)


help:
	@echo 'Run `make ALL` to see how things run from scratch'



## publishing
# $(PUBLISH_DIR)/%.html : $(ARTICLES_DIR) $(PUBLISH_DIR)
# 	mkdir -p $(PUBLISH_DIR)/assets

publish:
	# todo:
	# - use rsync obviously
	# - rewrite assets paths? or no need?
	find $(ARTICLES_DIR) -name 'index.md' | sort | while read -r idxname; do \
		echo "Processing $$idxname"; \
		srcdir=$$(dirname $$idxname); \
		bdname=$$(basename $$srcdir); \
		targetdir=$(PUBLISH_DIR)/$$bdname; \
		echo "Creating $$targetdir"; \
		mkdir -p $$targetdir; \
		if [[ -d "$$srcdir/assets" ]]; then cp -r $$srcdir/assets $$targetdir/assets; fi; \
		target=$$targetdir/index.html; \
		pandoc -f markdown -t html -o $$target $$idxname; \
	done


## compilation:

$(ARTICLES_DIR)/%index.md :  $(ARTICLES_DIR)
	rm -f $(@)
	$(foo-build-article)
	$(foo-insert-article-toc)


define foo-build-article =
find $(dir $@). -name '*.md' -not -name "_*.md" | sort | while read -r fname; do cat $$fname >> $@; done
endef

define foo-insert-article-toc=
[ -e "$(@)" ] && markdown-toc -i "$(@)" || -1
endef


clean:
	@echo "Should clean out ./docs"


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


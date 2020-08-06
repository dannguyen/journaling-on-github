.DEFAULT_GOAL := help

ARTICLES_DIR = articles


.PHONY : clean help $(ARTICLES_DIR)


help:
	@echo 'Run `make ALL` to see how things run from scratch'

compile: articles/sample-article/index.md


$(ARTICLES_DIR)/%index.md :  $(ARTICLES_DIR)
	rm -f $(@)
	$(foo-build-article)
	$(foo-insert-article-toc)


define foo-build-article =
find $(dir $@). -name '*.md' ! -name "pattern_B"| sort | while read -r fname; do cat $$fname >> $@; done
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


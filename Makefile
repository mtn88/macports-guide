# $Id$
# Makefile to generate the macports html guide and the man pages.
# The ports 'docbook-xsl', 'docbook-xml' and 'libxslt' have to be
# installed.

# If your macports isn't installed in /opt/local you have to change PREFIX
# here and update man/resources/macports.xsl to use your port installation!


# prefix of the macports installation:
PREFIX ?= /opt/local

# command abstraction variables:
MKDIR = /bin/mkdir
CP = /bin/cp
RM = /bin/rm
SED = /usr/bin/sed
XSLTPROC = $(PREFIX)/bin/xsltproc

# data directories:
GUIDE ?= guide
MAN   ?= man
# source directories:
GUIDE-SRC ?= $(GUIDE)/xml
MAN-SRC   ?= $(MAN)/xml
# result directories:
GUIDE-RESULT ?= $(GUIDE)/html
MAN-RESULT   ?= $(MAN)/man/
# man temporary directory:
MAN-TMP ?= $(MAN)/tmp

# path to the docbook xsl files:
DOCBOOK   ?= $(PREFIX)/share/xsl/docbook-xsl
GUIDE-XSL ?= $(DOCBOOK)/xhtml/profile-docbook.xsl
MAN-XSL   ?= $(MAN)/resources/macports.xsl

# docbook html stylesheet for the guide:
STYLESHEET ?= docbook.css
# additional parameters for the guide:
STRINGPARAMS ?= --stringparam html.stylesheet $(STYLESHEET) \
	              --stringparam section.autolabel 1 \
	              --stringparam toc.section.depth 1 \
	              --stringparam generate.toc "book toc" \
	              --stringparam section.label.includes.component.label 1 \
	              --stringparam profile.condition "noman"


.PHONY: all guide man clean

all: guide man

guide:
	$(MKDIR) -p $(GUIDE-RESULT)
	$(CP) $(GUIDE)/resources/$(STYLESHEET) $(GUIDE-RESULT)/$(STYLESHEET)
	$(CP) $(GUIDE)/resources/images/* $(GUIDE-RESULT)/
	$(XSLTPROC) --xinclude $(STRINGPARAMS) --output $(GUIDE-RESULT)/index.html \
	    $(GUIDE-XSL) $(GUIDE-SRC)/guide.xml

man:
	$(MKDIR) -p $(MAN-RESULT)
	$(MKDIR) -p $(MAN-TMP)
	$(CP) $(GUIDE-SRC)/portfile-*.xml $(MAN-TMP)
	$(SED) -i "" 's|<section|<refsection|g' $(MAN-TMP)/*
	$(SED) -i "" 's|</section>|</refsection>|g' $(MAN-TMP)/*
	$(XSLTPROC) --xinclude --output $(MAN-RESULT) $(MAN-XSL) \
	    $(MAN-SRC)/port.1.xml \
	    $(MAN-SRC)/portfile.7.xml \
	    $(MAN-SRC)/portgroup.7.xml \
	    $(MAN-SRC)/porthier.7.xml
	$(RM) -r $(MAN-TMP)

clean:
	$(RM) -rf $(GUIDE-RESULT)
	$(RM) -rf $(MAN-RESULT)
	$(RM) -rf $(MAN-TMP)

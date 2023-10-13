SHELL=/bin/sh
# This makefile is used for installing the binary distribution of GNAT.
# The installation script resulting from configuration consists
# of make commands using this makefile.  The options allowed by setting
# the directories by hand are greater than those allowed in the
# configuration script.

version=10.3.1
machine=x86_64-w64-mingw32
canonical_target=x86_64-windows64
gcc_lib=gcc
prefix    = /gnat-prefix64-47
libsubdir = $(prefix)/lib/$(gcc_lib)/$(machine)/$(version)
libexecsubdir = $(prefix)/libexec/$(gcc_lib)/$(machine)/$(version)
adaobjdir = $(libsubdir)/adalib
adaincdir = $(libsubdir)/adainclude
docdir    = $(prefix)/share/doc/gnat
exdir     = $(prefix)/share/examples/gnat
gpsplugdir = $(prefix)/share/gps/plug-ins
xmlfrags   = full_project/full.xml \
	options/options.xml \
	other_languages/cpp_main/cpp_main.xml \
	other_languages/cpp_pragmas/cpp_pragmas.xml \
	other_languages/import_from_c/import_from_c.xml \
	plugins/plugins.xml \
	stream_io/stream_io.xml \
	simple_project/simple_project.xml \
	starter/starter.xml \
	xml_stream/xml_stream.xml \
	containers/anagram/anagram.xml \
	containers/genealogy/genealogy.xml \
	containers/hash/hash.xml \
	containers/library/library.xml \
	containers/shapes/shapes.xml \
	containers/spellcheck/spellcheck.xml \
	containers/wordcount/wordcount.xml \
	containers/wordfreq/wordfreq.xml \
	oo_interfaces/oo_interfaces.xml \
	oo_airline/oo_airline.xml \
	altivec/altivec.xml
ext=.exe

mkheaders=$(libexecsubdir)/install-tools/mkheaders

ins-all: ins-basic ins-ex

ins-basic: mkdirs ins-prebuilt mkheaders

# Nothing specific to check for native platforms
check-env:

ins-prebuilt:
	for d in bin lib libexec lib32 lib64 include \
                 doc examples share etc DLLs \
		 $(machine) $(canonical_target); do \
	   if [ -d "$$d" ]; then \
	      tar cf - "$$d" | (cd "$(prefix)" && tar xf -); \
	   fi \
	done

mkheaders:
	"$(mkheaders)" -v -v "$(prefix)"
	case `uname` in \
	   *_NT*) (cd "$(libsubdir)"/adalib;chmod a-w *.ali) ;; \
	esac

mkdirs:
	rm -fr "$(libsubdir)"/rts*
	rm -fr "$(adaincdir)" "$(adaobjdir)"
	rm -fr "$(prefix)"/share/gprconfig
	-mkdir -p "$(prefix)"

ins-ex: ins-basic xmlfragments

xmlfragments:
	cat "$(exdir)"/header.xml >  "$(exdir)"/gnat-examples.xml
	for d in $(xmlfrags); do cat "$(exdir)/$$d" >> "$(exdir)"/gnat-examples.xml; done
	cat "$(exdir)"/footer.xml >> "$(exdir)"/gnat-examples.xml
	sed "s:PREFIX:$(prefix):" "$(exdir)"/gnat-examples.xml > \
		"$(exdir)"/gnat-examples.xml.tmp && \
	mv "$(exdir)"/gnat-examples.xml.tmp "$(exdir)"/gnat-examples.xml
	if [ ! -d "$(gpsplugdir)" ]; then \
		mkdir -p "$(gpsplugdir)";    \
	fi
	cp "$(exdir)"/gnat-examples.xml "$(gpsplugdir)"

post-install: mkheaders xmlfragments
	-rm -f "$(prefix)"/doinstall "$(prefix)"/README

.PHONY: ins-all ins-basic ins-ex ins-prebuilt mkdirs xmlfragments mkheaders post-install

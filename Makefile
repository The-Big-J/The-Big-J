#
# Basic makefile for the project
#

SRCDIR = src
BINDIR = bin
INCDIR = include

SRCS := $(wildcard $(SRCDIR)/*.S)
ASFLAGS = --gstabs
LDFLAGS = 
ECHO = /bin/echo -e
OBJECTS := $(addprefix $(BINDIR)/,$(addsuffix .o,$(SRCS)))
OUTNAME = lab4
AS = as

all: dirs $(OBJECTS)
	@$(ECHO) ===== Linking =====
	$(LD) -o $(BINDIR)/$(OUTNAME) $(OBJECTS)

dirs:
	@mkdir -p $(BINDIR)
	@mkdir -p $(BINDIR)/$(SRCDIR)

clean:
	@rm -rf $(BINDIR)

%.o: $(SRCS)
	@$(ECHO) ===== Building $@ =====
	$(AS) -o $@ $(ASFLAGS) $<

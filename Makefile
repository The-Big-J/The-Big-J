#
# Makefile 2.0, this time it won't delete itself
#
BINDIR = bin
SRCS = $(wildcard src/*.S)

DEFINES = 

ASFLAGS = $(DEFINES) --gstabs -Isrc/
LDFLAGS =
OUTNAME = thebigj
LD = ld
AS = as 
LN = ln 
ECHO = /bin/echo -e 
RM = rm

all: dirs 
	@$(ECHO) "\e[92m========= Building All =========\e[39m"
	$(AS) $(ASFLAGS) -o $(BINDIR)/main.o $(SRCS)
	@$(ECHO) "\e[92m=========== Linking ============\e[39m"
	$(LD) -o $(BINDIR)/$(OUTNAME) $(BINDIR)/main.o
	@$(ECHO) "\e[92m==== Creating symbolic link ====\e[39m"
	$(RM) ./$(OUTNAME)
	$(LN) -s $(BINDIR)/$(OUTNAME) ./$(OUTNAME) 
	@$(ECHO) "\e[92m============ Done ==============\e[39m"

clean:
	@$(ECHO) "\e[92m============ Cleaning ==============\e[39m"
	$(RM) -rf ./$(BINDIR)
	@$(ECHO) "\e[92m============== Done ================\e[39m"

dirs:
	@mkdir -p bin/


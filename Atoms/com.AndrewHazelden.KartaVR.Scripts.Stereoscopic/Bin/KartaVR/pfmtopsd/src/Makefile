# LINUX - pfmtopsd Makefile
# by Andrew Hazelden
# Email: andrew@andrewhazelden.com
# Web: http://www.andrewhazelden.com

# You can compile this file from the command line using:
# cd /var/BlackmagicDesign/Reactor/Deploy/Bin/KartaVR/pfmtopsd_src/src
# make

# You can install the files using the command
# sudo make install

KARTAVR_DIR="/var/BlackmagicDesign/Reactor/Deploy/Bin/KartaVR/linux_tools/"

LIBDIR  = 
COMPILERFLAGS =

CC = gcc
CFLAGS = $(COMPILERFLAGS) $(INCLUDE)
LIBRARIES = -lm
all:  pfmtopsd

pfmtopsd : pfmtopsd.o
	$(CC) $(CFLAGS) pfmtopsd.c $(LIBRARIES) -o pfmtopsd 

clean:
	rm -rf $(OBJS) 
	rm -rf pfmtopsd *.o

install:
	# KartaVR Linux Folder
	chmod 777 ./pfmtopsd
	mkdir -p $(KARTAVR_DIR)
	cp ./pfmtopsd $(KARTAVR_DIR)

run:
	$(KARTAVR_DIR)pfmtopsd

go: clean all install run

#CC=clang
CFLAGS= -DHTML_404='"404_Not_Found.html"' \
        -DHTML_501='"501_Method_Not_Implemented.html"' \
	 -DDEBUG \
	-DINCaPACHE_3_1 \
	-DPRETEND_TO_BE_ROOT \
	# -g3 -O0 -Wall -pedantic \
        -DIMAGE='"uncadunca.jpg"' \
        -DSTYLE='"000_style.css"'
OBJS=aux.o http.o main.o threads.o
BIN_DIR=bin
EXE=$(BIN_DIR)/incapache

.PHONY: clean tgz-students tgz-students3.1 tgz-full

all: $(EXE)

$(EXE): $(OBJS) $(BIN_DIR)
	$(CC) $(CFLAGS) -o $(EXE) $(OBJS) -lpthread
	sudo chown root $(EXE)
	sudo chmod u+s $(EXE)

aux.o: aux.c incApache.h
http.o: http.c incApache.h
main.o: main.c incApache.h
threads.o: threads.c incApache.h

clean:
	rm -f $(OBJS) $(EXE)

tgz-students: clean
	cd .. ; tar cvzf incapache-students.tgz --exclude=incapache-students/bin/Debug --exclude=incapache-students/.idea incapache-students

tgz-students3.1: clean
	cd .. ; tar cvzf incapache-students3.1.tgz --exclude=incapache-students3.1/bin/Debug --exclude=incapache-students3.1/.idea incapache-students3.1

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

tgz-full: clean
	cd .. ; tar cvzf incapache-full.tgz --exclude=incapache-full/bin/Debug --exclude=incapache-full/.idea incapache-full



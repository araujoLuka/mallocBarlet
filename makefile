OBJECTS = main.o print.o
EXE = avalia

all: main

main: $(OBJECTS)
	ld $(OBJECTS) -o $(EXE)

main.o: main.s
	as main.s -o main.o -g

print.o: print.s
	as print.s -o print.o -g

clean:
	rm -f $(OBJECTS)

purge:
	rm -f $(EXE)

run:
	./main

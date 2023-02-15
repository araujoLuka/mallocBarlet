OBJECTS = main.o 

all: main

main: $(OBJECTS)
	ld main.o -o main

main.o: main.s
	as main.s -o main.o -g

print: print.s
	as print.s -o print.o
	ld print.o -o print

clean:
	rm -f $(OBJECTS)

purge:
	rm -f main

run:
	./main

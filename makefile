OBJECTS = main.o 

all: main

main: $(OBJECTS)
	ld main.o -o main

main.o: main.s
	as main.s -o main.o -g

clean:
	rm -f $(OBJECTS)

purge:
	rm -f main

run:
	./main

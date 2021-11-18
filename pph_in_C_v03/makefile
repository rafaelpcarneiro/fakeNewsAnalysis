CC=gcc
CFLAGS=-Werror -Wall -Wextra -ansi -pedantic -O3

all_src =  $(wildcard src/*.c)
all_obj =  $(all_src:.c=.o)

pph_prog: $(all_obj)
	$(CC) -o $@ $^ $(CFLAGS) -lpthread

clean:
	rm src/*.o

.PHONY: all clean
all: pgp.pdf
clean:
	rm pgp.satysfy-aux pgp.saty
pgp.saty: pgp.saty.template
	envsubst pgp.saty.template > pgp.saty
pgp.pdf:
	satysfi pgp.saty

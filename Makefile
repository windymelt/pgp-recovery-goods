.PHONY: all clean distclean ensureenv
all: pgp.pdf
clean:
	-rm pgp.satysfi-aux pgp.saty private.pdf revoke.pdf
distclean: clean
	-rm pgp.pdf
ensureenv:
ifndef PGP_KEY_ID
	$(error Envvar PGP_KEY_ID is undefined)
endif
KEYINFO := $$(gpg --with-colons -k ${PGP_KEY_ID})
export DATE := $(shell date --iso-8601=date)
export FINGERPRINT := $(shell echo "${KEYINFO}" | awk -F: '/^pub:.*/ { getline; print $$10 }')
export LONGKEYID := $(shell echo "${KEYINFO}" | awk -F: '/^pub:.*/ { print $$5 }')
export USERID := $(shell echo "${KEYINFO}" | awk -F: '/^uid:.*/ { print $$10 }')
export EXCAPED_USERID := $(shell echo "${USERID}" | sed -e 's/\([<@>]\)/\\\1/g')
pgp.saty: ensureenv pgp.saty.template
	cat pgp.saty.template | envsubst > pgp.saty
private.pdf:
	gpg --export-secret-key ${LONGKEYID} | paperkey --output-type raw | dmtxwrite -o private.pdf --encoding=a -r 400
revoke.pdf:
	gpg --output revoke.asc --gen-revoke ${LONGKEYID}
	cat revoke.asc | dmtxwrite -o revoke.pdf --encoding=a -r 400
	rm revoke.asc
pgp.pdf: pgp.saty private.pdf revoke.pdf
	satysfi pgp.saty
	echo "Ensure to make clean to remove private barcode!"

# pgmp -- pgxs-based makefile
#
# Copyright (C) 2011-2020 Daniele Varrazzo
#
# This file is part of the PostgreSQL GMP Module
#
# The PostgreSQL GMP Module is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 3 of the License,
# or (at your option) any later version.
#
# The PostgreSQL GMP Module is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
# General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with the PostgreSQL GMP Module.  If not, see
# https://www.gnu.org/licenses/.

.PHONY: docs

# You may have to customize this to run the test suite
# REGRESS_OPTS=--user postgres

PG_CONFIG=pg_config

SHLIB_LINK=-lgmp -lm

EXTENSION = pgmp
MODULEDIR = $(EXTENSION)
MODULE_big = $(EXTENSION)

EXT_LONGVER = 1.1.0dev0
EXT_SHORTVER = 1.1

SRC_C = $(sort $(wildcard src/*.c))
SRC_H = $(sort $(wildcard src/*.h))
SRCFILES = $(SRC_C) $(SRC_H)
OBJS = $(patsubst %.c,%.o,$(SRC_C))
TESTFILES = $(sort $(wildcard test/sql/*.sql) $(wildcard test/expected/*.out))
BENCHFILES = $(sort $(wildcard bench/*.py) $(wildcard bench/*.txt))
DOCFILES = $(sort $(wildcard docs/*.rst))
TOOLSFILES = $(sort $(wildcard tools/*.py))

PKGFILES = $(SRCFILES) $(DOCFILES) $(TESTFILES) $(BENCHFILES) $(TOOLSFILES) \
	AUTHORS COPYING README.rst Makefile META.json pgmp.control \
	sql/pgmp.pysql sql/uninstall_pgmp.sql \
	docs/conf.py docs/Makefile docs/_static/pgmp.css \
	docs/html-gitignore docs/requirements.txt

INSTALLSCRIPT=sql/pgmp--$(EXT_SHORTVER).sql
UPGRADESCRIPT=sql/pgmp--unpackaged--$(EXT_SHORTVER).sql
DATA = $(INSTALLSCRIPT) $(UPGRADESCRIPT)

# the += doesn't work if the user specified his own REGRESS_OPTS
REGRESS = --inputdir=test setup mpz mpq
EXTRA_CLEAN = $(INSTALLSCRIPT) $(UPGRADESCRIPT)

PG_CFLAGS += -I/usr/local/include $(shell pkg-config --cflags gmp)
PG_LDFLAGS += -L/usr/local/lib $(shell pkg-config --libs gmp)

USE_PGXS=1
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

# added to the targets defined in pgxs
all: $(INSTALLSCRIPT) $(UPGRADESCRIPT)

$(INSTALLSCRIPT): sql/pgmp.pysql
	tools/unmix.py < $< > $@

$(UPGRADESCRIPT): $(INSTALLSCRIPT)
	tools/sql2extension.py --extname pgmp $< > $@

docs:
	$(MAKE) -C docs

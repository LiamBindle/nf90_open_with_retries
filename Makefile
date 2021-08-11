all: simple_xy_wr simple_xy_rd simple_xy_rd_retry

clean:
	rm -f simple_xy_wr simple_xy_rd simple_xy.nc *.mod simple_xy_rd_retry

FFLAGS = $(shell nf-config --cflags) $(shell nf-config --fflags) -g
LDFLAGS = $(shell nf-config --flibs)


@PHONY: all clean

simple_xy_wr: simple_xy_wr.f90
	gfortran $(FFLAGS) $^ -o $@ $(LDFLAGS)

simple_xy_rd: simple_xy_rd.f90
	gfortran $(FFLAGS) $^ -o $@ $(LDFLAGS)

simple_xy_rd_retry: nf_retry.f90 simple_xy_rd_retry.f90
	gfortran $(FFLAGS) $^ -o $@ $(LDFLAGS)

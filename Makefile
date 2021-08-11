all: sandbox/simple_xy_wr sandbox/simple_xy_rd sandbox/simple_xy_rd_with_retries

clean:
	rm -f sandbox/simple_xy_wr sandbox/simple_xy_rd sandbox/simple_xy.nc *.mod sandbox/simple_xy_rd_with_retries

FFLAGS = $(shell nf-config --cflags) $(shell nf-config --fflags) -g
LDFLAGS = $(shell nf-config --flibs)


@PHONY: all clean

sandbox/simple_xy_wr: sandbox/simple_xy_wr.f90
	gfortran $(FFLAGS) $^ -o $@ $(LDFLAGS)

sandbox/simple_xy_rd: sandbox/simple_xy_rd.f90
	gfortran $(FFLAGS) $^ -o $@ $(LDFLAGS)

sandbox/simple_xy_rd_with_retries: nf_retry.f90 sandbox/simple_xy_rd_with_retries.f90
	gfortran $(FFLAGS) $^ -o $@ $(LDFLAGS)

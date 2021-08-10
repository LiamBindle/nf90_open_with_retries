
## Where it goes wrong

[Here](https://github.com/GEOS-ESM/MAPL/blob/d5009302d5ebac669cc7ff93db5134154a2c7a88/pfio/NetCDF4_FileFormatter.F90#L256)L

```fortran
      if (this%parallel) then
         !$omp critical
         status = nf90_open(file, IOR(omode, NF90_MPIIO), comm=this%comm, info=this%info, ncid=this%ncid)
         !$omp end critical
         _VERIFY(status)
      else
         !$omp critical
         status = nf90_open(file, IOR(omode, NF90_SHARE), this%ncid)    ! this line can fail
         !$omp end critical
         _VERIFY(status)
```

## NetCDF-Fortran's Documentation of Error Handling

### 1.6 Error Handling

The netCDF library provides the facilities needed to handle errors in a flexible way. Each netCDF function returns an integer status value. If the returned status value indicates an error, you may handle it in any way desired, from printing an associated error message and exiting to ignoring the error indication and proceeding (not recommended!). For simplicity, the examples in this guide check the error status and call a separate function to handle any errors.

The NF90_STRERROR function is available to convert a returned integer error status into an error message string.

Occasionally, low-level I/O errors may occur in a layer below the netCDF library. For example, if a write operation causes you to exceed disk quotas or to attempt to write to a device that is no longer available, you may get an error from a layer below the netCDF library, but the resulting write error will still be reflected in the returned status value.

### Summary

Do

```fortran
   status = nf90_open(...)
   if(status /= nf90_noerr) then
      print *, trim(nf90_strerror(status))
   endif
NF90_STRERROR
```

## References
1. https://www.unidata.ucar.edu/software/netcdf/docs-fortran/nc_f77_interface_guide.html#f77_NF_OPEN_
2. https://www.unidata.ucar.edu/software/netcdf/docs-fortran/f90_datasets.html#f90-nf90_strerror
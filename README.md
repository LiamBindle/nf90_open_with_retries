## nf_retry

This is a module that provides `nf90_open_with_retries`. This function wraps `nf90_open`
with the following functionality

1. NetCDF errors are printed to the console
2. Automatically retry opening the file

This is useful for working around intermittent and erroneous i/o errors in HPC cluster filesystems like GPFS. 

`nf_retry` is disabled by default and `nf90_open_with_retries` behaves exactly like `nf90_open` (except error
are automatically printed). `nf_retry` can be enabled and configured by creating `nf_retry.nml`:

```
&nf_retry
    nf_retry_wait=1,            ! Seconds to wait before retry
    nf_retry_max_tries=3,       ! Max number of retries before failure
    nf_retry_catch=0,1,3,2,     ! NetCDF error codes to catch
    nf_retry_catch_all=F,       ! Catch all NetCDF errors?
/
```

### Implementing nf_retry

Copy `nf_retry.f90` into your source code and add include it in your build.

Include the `nf_retry` module and replace `nf90_open` calls with `nf90_open_with_retries`.

```diff
+  use nf_retry
   ...
-  status = nf90_open(path, mode, ncid)
+  status = nf90_open_with_retries(path, mode, ncid)
```

module nf_retry 
   use netcdf
   implicit none
   integer :: nf_retry_catch(20)
   integer :: nf_retry_wait
   integer :: nf_retry_max_tries
contains  
   function nf90_open_with_retries(path, mode, ncid) result(status)
      implicit none
      character (len = *), intent(in) :: path
      integer, intent(in) :: mode
      integer, intent(out) :: ncid
      integer :: status
      integer :: retry_attempts

      retry_attempts=0
      
      status = nf90_open(path, mode, ncid)
      if(status /= nf90_noerr) then
         print '("nf90_open: error(", I0,"): ",A)',status,nf90_strerror(status)
         do while ( (status /= nf90_noerr) .and. ( any(nf_retry_catch==status) ) .and. (retry_attempts < nf_retry_max_tries) )
            print '("nf_retry: Caught netcdf error code(", I0,"): ",A)',status,nf90_strerror(status)
            print '("nf_retry: Retrying in ", I0,"s")',nf_retry_wait
            call sleep(nf_retry_wait)
            status = nf90_open(path, mode, ncid)
            retry_attempts = retry_attempts + 1
         end do
      endif
   end function

   subroutine nf_retry_init()
      implicit none
      integer :: fh
      logical :: exists
      character(len=*) :: filepath
      parameter (filepath = 'nf_retry.nml')
      
      namelist /nf_retry/ nf_retry_wait, nf_retry_max_tries, nf_retry_catch
      
      ! Initialize nf_retry settings
      nf_retry_catch(:) = nf90_noerr ! Safe b/c we never catch nf90_noerr
      nf_retry_wait=10
      nf_retry_max_tries=1000

      inquire (file=filepath, exist=exists)
      if (exists) then
         open (unit=fh, file=filepath)
         read (nml=nf_retry, unit=fh)
      end if
   end subroutine

end module nf_retry
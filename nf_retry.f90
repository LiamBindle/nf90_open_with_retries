! nf90_open_with_retries
!  VERSION     1.0.2
!  REPOSITORY  https://github.com/LiamBindle/nf90_open_with_retries

module nf_retry 
   use netcdf
   implicit none
   integer :: nf_retry_catch(20)
   integer :: nf_retry_wait
   integer :: nf_retry_max_tries
   logical :: nf_retry_catch_all

   logical :: nf_retry_is_initialized = .false.
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
         if (.not. nf_retry_is_initialized) then
            call nf_retry_init()
         end if
         print '("nf90_open: Error code (", I0,") opening ", A, " [", A,"]")',status,trim(path),trim(nf90_strerror(status))
         do while ( ( status /= nf90_noerr ) .and. &
                     ( any(nf_retry_catch==status) .or. nf_retry_catch_all ) .and. &
                     ( retry_attempts < nf_retry_max_tries ) )
            print '("   caught: Error code (", I0,") opening ", A, " [", A,"]")',&
               status,trim(path),trim(nf90_strerror(status))
            print '("           Retrying in ", I0,"s")',nf_retry_wait
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
      
      namelist /nf_retry/ nf_retry_wait, nf_retry_max_tries, nf_retry_catch, nf_retry_catch_all
      
      ! Initialize nf_retry settings
      nf_retry_catch(:) = nf90_noerr ! Safe b/c we never catch nf90_noerr
      nf_retry_wait=10
      nf_retry_max_tries=1000
      nf_retry_catch_all=.false.

      inquire (file=filepath, exist=exists)
      if (exists) then
         open (unit=fh, file=filepath)
         read (nml=nf_retry, unit=fh)
      end if

      nf_retry_is_initialized = .true.
   end subroutine

end module nf_retry
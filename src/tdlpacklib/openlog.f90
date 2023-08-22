subroutine openlog(kstdout,path)
implicit none

! ---------------------------------------------------------------------------------------- 
! Input/Output Variables
! ---------------------------------------------------------------------------------------- 
integer, intent(in) :: kstdout
character(len=*), intent(in), optional :: path

! ---------------------------------------------------------------------------------------- 
! Local Variables
! ---------------------------------------------------------------------------------------- 
integer :: ios

! ---------------------------------------------------------------------------------------- 
! Initialize
! ---------------------------------------------------------------------------------------- 
ios=0

! ---------------------------------------------------------------------------------------- 
! Open log file accordingly.
! ---------------------------------------------------------------------------------------- 
if(present(path))then
   open(unit=kstdout,file=path,form="formatted",status="replace",iostat=ios)
else
   open(unit=kstdout,form="formatted",status="replace",iostat=ios)
endif

return
end subroutine openlog

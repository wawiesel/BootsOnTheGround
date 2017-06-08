program tstBLAS

integer              :: n
real                 :: a
real,dimension(1000) :: x,y
integer              :: i
real                 :: expected
integer              :: incx,incy

!set up some data
n=300
do i=1,n
    x(i)=real(i)
    y(i)=real(i)**2
end do

!calculate y = a*x + y
a=7.0
incx=1
incy=1
call saxpy( n, a, x, incx, y, incy )

do i=1,n
    expected = 7.0*real(i) + real(i)**2
    if( abs( y(i)/expected - 1 )>1e-4 )then
        write(*,*)'error matching element i=',i,' expected=',expected,' received=',y(i)
        stop
    end if
end do

end program

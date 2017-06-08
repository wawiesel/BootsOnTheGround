program tstLAPACK

integer,parameter      :: n=3
real,dimension(n*n)    :: a
real,dimension(n)      :: b
integer,dimension(n)   :: ipiv
integer                :: i,info,nrhs,lda,ldb
real                   :: expected

!set up dumb system
a=(/  1,0,0,  &
      0,2,0,  &
      0,0,3  /)

b=(/   2,  &
       4,  &
       6  /)

!solution is 2,2,2

!calculate solution of a*x=b and put into b
nrhs=1
lda=n
ldb=n
call sgesv( n, nrhs, a, lda, ipiv, b, ldb, info )

if( info/=0 )then
    write(*,*)'LAPACK::sgesv failed with info=',info,'!'
    stop
end if

do i=1,n
    expected = 2
    if( abs( b(i)/expected - 1 )>1e-4 )then
        write(*,*)'error matching element i=',i,' expected=',expected,' received=',b(i)
        stop
    end if
end do

end program

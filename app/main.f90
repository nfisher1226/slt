program main
  use M_CLI2, only : set_args, get_args
  use fslt, only: print_sine
  implicit none
  integer :: depth,length,offset,idx
  logical :: hex

  call set_args('--depth:d 16 --length:l 16 --offset:o 0 --hex:x F')
  call get_args('d',depth, 'l',length, 'o',offset, 'x',hex)

  write (*,'(a1)',advance="no") '{'
  idx = 0
  do while (idx < length)
    call print_sine(depth,length,offset,hex,idx)
    idx = idx + 1
  end do
  write (*,'(a2)') '};'
end program main

!
! ---------------------------------------------------------------------
!           "THE BEER-WARE LICENSE" (Revision 42):
! <jeang3nie@HitchHiker-Linux.org> wrote this file. As long as you
! retain this notice you can do whatever you want with this stuff. If
! we meet some day, and you think this stuff is worth it, you can buy
! me a beer in return.
! ---------------------------------------------------------------------
!            ______   _______  _          _________
!           (  __  \ (  ___  )( (    /|( )\__   __/
!           | (  \  )| (   ) ||  \  ( ||/    ) (
!           | |   ) || |   | ||   \ | |      | |
!           | |   | || |   | || (\ \) |      | |
!           | |   ) || |   | || | \   |      | |
!           | (__/  )| (___) || )  \  |      | |
!           (______/ (_______)|/    )_)      )_(
!
!         _______  _______  _       _________ _______
!        (  ____ )(  ___  )( \    /|\__   __/(  ____ \
!        | (    )|| (   ) ||  \  ( |   ) (   | (    |/
!        | (____)|| (___) ||   \ | |   | |   | |
!        |  _____)|  ___  || (\ \) |   | |   | |
!        | (      | (   ) || | \   |   | |   | |
!        | )      | )   ( || )  \  |___) (___| (____|\
!        |/       |/     \||/    \_)\_______/(_______/
!
module fslt
  implicit none
  private

  public :: print_sine

  real(8),  parameter :: PI_8  = 4 * atan (1.0_8)
contains
  subroutine print_sine(depth,length,offset,hex,idx)
    integer, intent(in) :: depth,length,offset,idx
    logical, intent(in) :: hex
    real                :: hypotenuse,rads_per_index,rads
    integer             :: val

    hypotenuse = (real(depth - offset) - 1.0) / 2.0
    rads_per_index = (2.0 * PI_8) / real(length)
    rads = real(idx) * rads_per_index
    val = nint((sin(rads) * hypotenuse) + hypotenuse + offset)

    if (mod(idx, 12) == 0) then
      print *
      write (*,'(a4)',advance="no") '    '
    end if
    if (idx < length - 1) then
      if (hex) then
        if (val < 16) then
          write (*,'("0x",z1,", ")',advance="no") val
        else if (val < 256) then
          write (*,'("0x",z2,", ")',advance="no") val
        else if (val < 4096) then
          write (*,'("0x",z3,", ")',advance="no") val
        else
          write (*,'("0x",z4,", ")',advance="no") val
        end if
      else
        if (val < 10) then
          write (*,'(i1,", ")',advance="no") val
        else if (val < 100) then
          write (*,'(i2,", ")',advance="no") val
        else if (val < 1000) then
          write (*,'(i3,", ")',advance="no") val
        else
          write (*,'(i4,", ")',advance="no") val
        end if
      end if
    else
      if (hex) then
        if (val < 16) then
          write (*,'("0x",z1)') val
        else if (val < 256) then
          write (*,'("0x",z2)') val
        else if (val < 4096) then
          write (*,'("0x",z3)') val
        else
          write (*,'("0x",z4)') val
        end if
      else
        if (val < 10) then
          write (*,'(i1)') val
        else if (val < 100) then
          write (*,'(i2)') val
        else if (val < 1000) then
          write (*,'(i3)') val
        else
          write (*,'(i4)') val
        end if
      end if
    end if
  end subroutine print_sine
end module fslt

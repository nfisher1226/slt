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

program main
    use M_CLI2, only : set_args, get_args
    use fslt, only: print_sin
    implicit none
    integer :: depth,length,offset,idx
    logical :: hex

    call set_args('--depth:d 16 --length:l 16 --offset:o 0 --hex:x F')
    call get_args('d',depth, 'l',length, 'o',offset, 'x',hex)

    write (*,'(a1,/,a4)',advance="no") '{', '    '
    idx = 0
    do while (idx < length)
        call print_sin(depth,length,offset,idx,hex)
        idx = idx + 1
    end do
end program main

: platform  s" gflinux" ;
: attribute  drop ;

variable gforth-path  fpath @ gforth-path !


create path 256 allot
: defined  ( -- <word> flag ) bl word find ;
: exists ( -- <word> flag )   defined 0 <> nip ;

: append  2DUP 2>R  COUNT + SWAP MOVE  2R> C+! ;
: combined  dup >r  place  r@ append  r> count ;
: included  s" ~+/" path combined included ;
: include  ( -- <path> )
    >in @ >r  bl parse included  r> >in !  create ;
: depend  ( -- <path> )
    >in @  exists if drop exit then  >in !
    include ;
    
create cmd 256 allot
\ Note: s" cd <place>" system doesn't work because system starts another
\ process.
: cd  0 parse set-dir drop ;

: h.  hex . decimal ;
: +order >order ;
: -order >r get-order r> over >r ( an ugly one... )
    begin over while
	    rot 2dup = if drop r> 1- >r else r> swap >r >r then
	    swap 1- swap
    repeat 2drop r> dup begin dup while r> -rot 1- repeat drop set-order ;
' allot alias /allot
: upcase   bounds ?do i c@ toupper i c! loop ;
\ dictionary pointer is apparently named h in swiftforth?
' dp alias h
' name>int alias name>
: !+   over ! cell+ ;
' utime alias ucounter
: -exit ( exit if false ) postpone 0= postpone if postpone exit postpone then ;
immediate
' 0= alias not
: :is   noname : latestxt <is> ;
\ interpretation implemented only
: z"   here [char] " parse here swap dup allot move 0 c, ;
' >body alias >code
' body> alias code>

include afkit/ans/ffl/gflinux/ffl.f   \ FFL: DOM; FFL loads FPMATH
include afkit/dep/allegro5/allegrolib.fs
create tmp-color ALLEGRO_COLOR allot
: >tmp-color tmp-color
    dup ALLEGRO_COLOR.a sf!
    dup ALLEGRO_COLOR.b sf!
    dup ALLEGRO_COLOR.g sf!
        ALLEGRO_COLOR.r sf! ;
: al_clear_to_color   >tmp-color tmp-color al_clear_to_color ;
: al_draw_filled_rectangle >tmp-color tmp-color al_draw_filled_rectangle ;
include afkit/dep/X11/xlib-gforth.f
\ Some functions are assumed to behave differently than you'd expect given their
\ C definition. For example, XRaiseWindow is expected to leave nothing on the
\ stack, even though it returns an int. We rectify this here.
: autodrop
    parse-name 2dup find-name name>int -rot nextname
    create , does> perform drop ;
autodrop XMapWindow
autodrop XRaiseWindow
autodrop XSync
autodrop XSetInputFocus
autodrop XGetInputFocus
autodrop al_get_display_mode
autodrop al_show_mouse_cursor
autodrop al_hide_mouse_cursor
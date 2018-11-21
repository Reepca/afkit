[defined] gforth [if]
    include ~+/afkit/ans/version.f
[else]
    include afkit/ans/version.f
[then]
#1 #5 #0 [version] [afkit]

\ Load external libraries
[undefined] EXTERNALS_LOADED [if]  \ ensure that external libs are only ever loaded once.
    [defined] gforth [if]
        : kitconfig.f  s" ../kitconfig.f" ;
	: file-exists  r/o open-file 0= tuck if close-file then drop ;
    [else]
        : kitconfig.f  s" kitconfig.f" ;
    [then]

    kitconfig.f file-exists [if]
        kitconfig.f included
    [else]
        s" Missing kitconfig.f!!! " type QUIT
    [then]
    
    include afkit/platforms.f

    true constant EXTERNALS_LOADED

    [undefined] LIGHTWEIGHT [if]
        cd afkit/ans/ffl
            ffling +order
                include ffl/dom.fs
                include ffl/b64.fs
            ffling -order
        cd ../../..
    [then]

    : empty  only forth s" (empty) marker (empty)" evaluate ;
    marker (empty)
[then]


include afkit/ans/section.f

[section] Libraries
\ Load support libraries
include afkit/plat/win/fpext.f     \ depends on FPMATH
include afkit/ans/strops.f         \ ANS
include afkit/ans/files.f          \ ANS
include afkit/ans/roger.f          \ ANS

[section] Audio
[defined] allegro-audio [if]  include afkit/audio-allegro.f  [then]

\ --------------------------------------------------------------------------------------------------
[section] Variables
0 value al-default-font
0 value fps
0 value allegro?
0 value eventq
0 value display
create uesrc 32 cells /allot
variable fs    \  enables fullscreen when on

\ --------------------------------------------------------------------------------------------------
[section] Display
\ Initializing Allegro and creating the display window
\   need only one for now
\   simplified to sidestep degenerative stalling bug
\   derived from Bubble

include afkit/al.f

: assertAllegro
    allegro? ?exit   true to allegro?  init-allegro-all
    initaudio
;

assertAllegro

\ Native and Display Resolutions
create native  /ALLEGRO_DISPLAY_MODE /allot
  al_get_num_display_modes 1 -  native  al_get_display_mode
: xy@   dup @ swap cell+ @ ;
: x@  xy@ drop ;
: y@  xy@ nip ;
: displayw  display al_get_display_width ;
: displayh  display al_get_display_height ;
: displaywh  displayw displayh ;

\ ------------------------------------ initializing the display ------------------------------------


[defined] initial-scale [if] initial-scale [else] 1 [then] value #globalscale
[undefined] initial-res [if]  : initial-res  640 480 ;  [then]
[undefined] initial-pos [if]  : initial-pos  0 0 ;  [then]

: initDisplay  ( w h -- )
    locals| h w |
    
    assertAllegro
    
    ALLEGRO_VSYNC 1 ALLEGRO_SUGGEST  al_set_new_display_option
    allegro-display-flags al_set_new_display_flags

    [defined] dev [if]
        \ top left corner:
        initial-pos 40 + al_set_new_window_position
            w h al_create_display  to display    
        display initial-pos al_set_window_position
    [else]
        \ centered:
        native x@ 2 / w 2 / - native y@ 2 / h 2 / - 40 - al_set_new_window_position
            w h al_create_display  to display    
    [then]
    
    display al_get_display_refresh_rate ?dup 0= if 60 then to fps

    al_create_builtin_font to al-default-font

    al_create_event_queue  to eventq
    eventq  display       al_get_display_event_source  al_register_event_source
    eventq                al_get_mouse_event_source    al_register_event_source
    eventq                al_get_keyboard_event_source al_register_event_source
    uesrc al_init_user_event_source
    eventq                uesrc                        al_register_event_source

    ALLEGRO_DEPTH_TEST 0 al_set_render_state
;

: valid?  ['] @ catch nip 0 = ;


create res  initial-res swap , ,

: scaled-res  res xy@ #globalscale * swap #globalscale * swap ;
: +display  display valid? ?exit  scaled-res initDisplay ;
: -display  display valid? -exit
    display al_destroy_display  0 to display
    eventq al_destroy_event_queue  0 to eventq ;
: -allegro  -display  false to allegro?  al_uninstall_system ;

: resolution  res 2!  fs @ 0= if  -display  +display  then ;

\ ----------------------------------- words for switching windows ----------------------------------
[defined] linux [if]
    variable _hwnd
    variable _disp

    0 XOpenDisplay _disp !
    _disp @ _hwnd here XGetInputFocus

    : HWND  _hwnd @ ;

    : btf
        0 XOpenDisplay _disp !
        _disp @ over 0 0 XSetInputFocus
        _disp @ swap XRaiseWindow
        _disp @ 0 XSync ;

    : >display  display al_get_x_window_id focus ;
[else]
    : btf  ( winapi-window - )
      dup 1 ShowWindow drop  dup BringWindowToTop drop  SetForegroundWindow drop ;
    : >display  ( -- )  display al_get_win_window_handle btf ;
[then]

defer >ide
:noname [ is >ide ]  ( -- )  HWND btf ;
>ide

[section] Input
\ keyboard and joystick support, integer/float version
\ ----------------------------------------------- keyboard -----------------------------------------
create kbstate  /ALLEGRO_KEYBOARD_STATE /allot \ current frame's state
create kblast  /ALLEGRO_KEYBOARD_STATE /allot  \ last frame's state
: pollKB
  kbstate kblast /ALLEGRO_KEYBOARD_STATE move
  kbstate al_get_keyboard_state ;
: clearkb  kblast /ALLEGRO_KEYBOARD_STATE erase  kbstate /ALLEGRO_KEYBOARD_STATE erase ;
: resetkb
  clearkb
  al_uninstall_keyboard
  al_install_keyboard  not abort" Error re-establishing the keyboard :/"
  eventq  al_get_keyboard_event_source al_register_event_source ;
\ ----------------------------------------- end keyboard -------------------------------------------
\ ----------------------------------------- joysticks ----------------------------------------------
\ NTS: we don't handle connecting/disconnecting devices yet,
\   though Allegro 5 /does/ support it. (via an event)

_AL_MAX_JOYSTICK_STICKS constant MAX_STICKS
create joysticks   MAX_STICKS /ALLEGRO_JOYSTICK_STATE * /allot
: joystick[]  /ALLEGRO_JOYSTICK_STATE *  joysticks + ;
: >joyhandle  al_get_joystick ;
: joy ( joy# stick# - vector )  \ get stick position
  /ALLEGRO_JOYSTICK_STATE_STICK *  swap joystick[]
  ALLEGRO_JOYSTICK_STATE.sticks + ;
: #joys  al_get_num_joysticks ;
: pollJoys ( -- )  #joys for  i >joyhandle i joystick[] al_get_joystick_state  loop ;
\ ----------------------------------------- end joysticks ------------------------------------------

\ --------------------------------------------------------------------------------------------------
[section] Graphics
\ Graphics essentials; no-fixed-point version
16 cells constant /transform
: transform  create  here  /transform allot  al_identity_transform ;

\ integer stuff
: bmpw   ( bmp -- n )  al_get_bitmap_width  ;
: bmph   ( bmp -- n )  al_get_bitmap_height  ;
: bmpwh  ( bmp -- w h )  dup bmpw swap bmph ;
: hold>  ( -- <code> )  1 al_hold_bitmap_drawing  r> call  0 al_hold_bitmap_drawing ;
: loadbmp  ( adr c -- bmp ) zstring al_load_bitmap ;
: savebmp  ( bmp adr c -- ) zstring swap al_save_bitmap 0= abort" Allegro: Error saving bitmap." ;
: -bmp  ?dup -exit al_destroy_bitmap ;

create write-src  ALLEGRO_ADD , ALLEGRO_ONE   , ALLEGRO_ZERO          , ALLEGRO_ADD , ALLEGRO_ONE , ALLEGRO_ZERO , 
create add-src    ALLEGRO_ADD , ALLEGRO_ALPHA , ALLEGRO_ONE           , ALLEGRO_ADD , ALLEGRO_ONE , ALLEGRO_ONE  , 
create interp-src ALLEGRO_ADD , ALLEGRO_ALPHA , ALLEGRO_INVERSE_ALPHA , ALLEGRO_ADD , ALLEGRO_ONE , ALLEGRO_ONE  , 

0 value oldblender
0 value currentblender
: blend  ( blender -- ) 
    dup to currentblender
    @+ swap @+ swap @+ swap @+ swap @+ swap @ al_set_separate_blender ;
: blend>  ( blender -- ) 
    currentblender to oldblender  blend  r> call  oldblender blend ;
interp-src blend

\ Pen
create penx  0 ,  here 0 ,  constant peny
: at   ( x y -- )  penx 2! ;
: +at  ( x y -- )  penx 2+! ;
: at@  ( -- x y )  penx 2@ ;

\ --------------------------------------------------------------------------------------------------
[section] Piston
include afkit/piston.f
\ --------------------------------------------------------------------------------------------------
[section] Init
+display
>ide


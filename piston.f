\ Universal main loop, simple version; no fixed point
\  It just processes events and spits out frames, no timer, no frameskipping.
\  The previous version tried to have frameskipping and framepacing, but it became choppy after
\    an hour or two running and I couldn't figure out the cause.
\  The loop has some common controls:
\    F12 - break the loop
\    ALT-F4 - quit the process
\    ALT-ENTER - toggle fullscreen
\    ALT-I - toggles a flag called INFO


\ Values
0 value frmctr
0 value showerr
0 value steperr
0 value pumperr
0 value alt?  \ part of fix for alt-enter bug when game doesn't have focus
0 value ctrl?
0 value breaking?
0 value 'pump
0 value 'step
0 value 'show
0 value me    \ for Ramen
0 value (me)  \ save/restore

\ Flags
variable info  \ enables debugging mode display
variable eco   \ enable to save CPU (for repl/editors etc)
variable oscursor   \ turn off to hide the OS's mouse cursor
variable ide-loaded

\ Defers
defer ?overlay  ' noop is ?overlay  \ render ide  ( - )
defer ?system   ' noop is ?system   \ system events ( - )
defer onDisplayClose  :is onDisplayClose  bye ;  ( - )
defer repl?     :noname  0 ; is repl?

\ Event stuff
create evt  256 /allot
: etype  evt ALLEGRO_EVENT.TYPE @ ;
z" AKFS" @ constant FULLSCREEN_EVENT

: poll  pollKB  pollJoys ;
: break  true to breaking? ;


define internal
    transform m1
    fvariable clipx
    fvariable clipy
    fvariable clipw
    fvariable cliph


using internal
: clip ( x y w h - ) 
    #globalscale * s>f cliph sf!
    #globalscale * s>f clipw sf!
    s>f  clipy sf!
    s>f  clipx sf!
    m1   clipx clipy   al_transform_coordinates
    clipx sf@ f>s
    clipy sf@ f>s
    clipw sf@ f>s
    cliph sf@ f>s al_set_clipping_rectangle
;

: mount  ( - )
    m1 al_identity_transform
    m1 #globalscale s>f fdup al_scale_transform
    fs @ if
        m1
            native x@ 2 / res x@ #globalscale * 2 / -  s>f
            native y@ 2 / res y@ #globalscale * 2 / -  s>f  al_translate_transform
    then
    \ m1 0.625e 0.625e 2sf al_translate_transform
    m1 al_use_transform

    0 0 res xy@ clip
    
    ALLEGRO_ADD ALLEGRO_ALPHA ALLEGRO_INVERSE_ALPHA
    ALLEGRO_ADD ALLEGRO_ONE   ALLEGRO_ONE
        al_set_separate_blender
    
;
: unmount
    m1 al_identity_transform
    \ m1 0.625e 0.625e 2sf al_translate_transform
    m1 al_use_transform
    0 0 displaywh clip
    ALLEGRO_ADD ALLEGRO_ALPHA ALLEGRO_INVERSE_ALPHA
    ALLEGRO_ADD ALLEGRO_ONE   ALLEGRO_ONE
        al_set_separate_blender
;

variable (catch)
: call-code >r ; \ as opposed to call-xt, which is just EXECUTE
: try  dup -exit  sp@ cell+ >r  ['] call-code catch (catch) !  r> sp!  (catch) @ ;

: suspend
    -audio
    begin
        eventq evt al_wait_for_event
        etype ALLEGRO_EVENT_DISPLAY_SWITCH_IN = if
            clearkb  false to alt?  +audio
            exit 
        then
    again    
;

: standard-events
    etype ALLEGRO_EVENT_DISPLAY_RESIZE = if  display al_acknowledge_resize  then
    etype ALLEGRO_EVENT_DISPLAY_CLOSE = if  onDisplayClose  then
    ide-loaded @ if  etype ALLEGRO_EVENT_DISPLAY_SWITCH_OUT = if  suspend  then  then
    
    \ still needed in published games, don't remove
    etype ALLEGRO_EVENT_DISPLAY_SWITCH_IN = if
        clearkb  false to alt?
    then

    etype ALLEGRO_EVENT_KEY_DOWN = if
        evt ALLEGRO_KEYBOARD_EVENT.keycode @ case
            <alt>    of  true to alt?  endof
            <altgr>  of  true to alt?  endof
            <lctrl>  of  true to ctrl?  endof
            <rctrl>  of  true to ctrl?  endof
            <enter>  of  alt? -exit  fs @ not fs ! endof
            <f4>     of  alt? -exit  bye  endof
            <f12>    of  break  endof
            <i>      of  alt? -exit  info @ not info !  endof
        endcase
    then
    etype ALLEGRO_EVENT_KEY_UP = if
        evt ALLEGRO_KEYBOARD_EVENT.keycode @ case
            <alt>    of  false to alt?  endof
            <altgr>  of  false to alt?  endof
            <lctrl>  of  false to ctrl?  endof
            <rctrl>  of  false to ctrl?  endof
        endcase
    then ;

variable winx  variable winy
: ?poswin   \ save/restore window position when toggling in and out of fullscreen
    display al_get_display_flags ALLEGRO_FULLSCREEN_WINDOW and if
        fs @ 0= if  r> call  display winx @ winy @ al_set_window_position  then
    else
        fs @ if     display winx winy al_get_window_position  then
    then ;

: al-emit-user-event  ( type - )  \ EVT is expected to be filled, except for the type
    evt ALLEGRO_EVENT.type !  uesrc evt 0 al_emit_user_event ;

0 value #lastscale
variable newfs
: 2s>f  swap s>f s>f ;
: ?fs
    ?poswin
    fs @ newfs @ = ?exit
    display ALLEGRO_FULLSCREEN_WINDOW fs @ $1 and al_toggle_display_flag drop
    fs @ newfs !
    fs @ if
        #globalscale to #lastscale
        native xy@ 2s>f f/ 
        res xy@ 2s>f f/ f> if
            native y@ res y@ /
        else
            native x@ res x@ /
        then
            to #globalscale
    else
        #lastscale to #globalscale
    then
    FULLSCREEN_EVENT al-emit-user-event
;

: ?hidemouse  display oscursor @ if al_show_mouse_cursor else al_hide_mouse_cursor then ; 

: onto  ( bmp - )  dup display = if al_get_backbuffer then al_set_target_bitmap ;
: ?greybg  fs @ -exit  display onto  unmount  0.1e 0.1e 0.1e 1e al_clear_to_color ;
: (show)  me >r  'show try to showerr  r> to me ;
: show  ?greybg  mount  display onto  (show)  unmount  display onto  ?overlay  ;
: present  al_flip_display ;
: ?suppress  repl? if clearkb then ;
: step  me >r  ?suppress  'step try to steperr  1 +to frmctr  r> to me  ;
: /go  resetkb  false to breaking?   >display  false to alt?  false to ctrl? ;
: go/  eventq al_flush_event_queue  >ide  false to breaking?  ;
: show>  r>  to 'show ;  ( - <code> )  ( - )
: step>  r>  to 'step ;  ( - <code> )  ( - )
: pump>  r> to 'pump ;  ( - <code> )  ( - )
: get-next-event  eco @ if al_wait_for_event #1 else al_get_next_event then ;
: @event  ( - flag )  eventq evt get-next-event ;
: pump  repl? ?exit  'pump try to pumperr ;
: attend
    begin  @event  breaking? not and  while
        me >r  pump  standard-events  r> to me  ['] ?system catch throw
        eco @ ?exit
    repeat ;
: frame  show present attend poll step ?fs ?hidemouse ;
: go  /go    begin  frame  breaking? until  go/ ;

\ default demo: dark blue screen with bouncing white square
define internal
    variable x  variable vx  1 vx !
    variable y  variable vy  1 vy !
    :noname
	show>
        0e 0e 0.5e 1e al_clear_to_color
        x @ y @ over 50 + over 50 + 4s>f 1e 1e 1e 1e al_draw_filled_rectangle
        vx @ x +!  vy @ y +!
        vx @ 0< if  x @ 0 < if  vx @ negate vx !  then then
        vy @ 0< if  y @ 0 < if  vy @ negate vy !  then then
        vx @ 0> if  x @ res x@ 50 - >= if  vx @ negate vx !  then then
        vy @ 0> if  y @ res y@ 50 - >= if  vy @ negate vy !  then then
        ;  execute
only forth definitions

oscursor on

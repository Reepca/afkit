c-library allegro
    \c #include <allegro5/allegro.h>
    \c #include <allegro5/allegro_acodec.h>
    \c #include <allegro5/allegro_color.h>
    \c #include <allegro5/allegro_font.h>
    \c #include <allegro5/allegro_ttf.h>
    \c #include <allegro5/allegro_image.h>
    \c #include <allegro5/allegro_primitives.h>
    \c bool gforth_al_init(){ return al_init();}
    
    s" allegro"            add-lib
    s" allegro_audio"      add-lib
    s" allegro_acodec"     add-lib
    s" allegro_image"      add-lib
    s" allegro_primitives" add-lib
    s" allegro_font"       add-lib
    s" allegro_ttf"        add-lib
    c-function al_init gforth_al_init -- n
    include afkit/dep/allegro5/allegro-gforth.f
end-c-library

\ Aren't emacs keyboard macros great?
' ALLEGRO_TIMEOUT alias /ALLEGRO_TIMEOUT
' ALLEGRO_COLOR alias /ALLEGRO_COLOR
' _al_tagbstring alias /_al_tagbstring
' ALLEGRO_FILE_INTERFACE alias /ALLEGRO_FILE_INTERFACE
' ALLEGRO_LOCKED_REGION alias /ALLEGRO_LOCKED_REGION
' ALLEGRO_EVENT_SOURCE alias /ALLEGRO_EVENT_SOURCE
' ALLEGRO_ANY_EVENT alias /ALLEGRO_ANY_EVENT
' ALLEGRO_DISPLAY_EVENT alias /ALLEGRO_DISPLAY_EVENT
' ALLEGRO_JOYSTICK_EVENT alias /ALLEGRO_JOYSTICK_EVENT
' ALLEGRO_KEYBOARD_EVENT alias /ALLEGRO_KEYBOARD_EVENT
' ALLEGRO_MOUSE_EVENT alias /ALLEGRO_MOUSE_EVENT
' ALLEGRO_TIMER_EVENT alias /ALLEGRO_TIMER_EVENT
' ALLEGRO_TOUCH_EVENT alias /ALLEGRO_TOUCH_EVENT
' ALLEGRO_USER_EVENT alias /ALLEGRO_USER_EVENT
' ALLEGRO_EVENT alias /ALLEGRO_EVENT
' ALLEGRO_FS_ENTRY alias /ALLEGRO_FS_ENTRY
' ALLEGRO_FS_INTERFACE alias /ALLEGRO_FS_INTERFACE
' ALLEGRO_DISPLAY_MODE alias /ALLEGRO_DISPLAY_MODE
' ALLEGRO_JOYSTICK_STATE alias /ALLEGRO_JOYSTICK_STATE
' ALLEGRO_JOYSTICK_STATE_stick alias /ALLEGRO_JOYSTICK_STATE_stick
' ALLEGRO_KEYBOARD_STATE alias /ALLEGRO_KEYBOARD_STATE
' ALLEGRO_MOUSE_STATE alias /ALLEGRO_MOUSE_STATE
' ALLEGRO_TOUCH_STATE alias /ALLEGRO_TOUCH_STATE
' ALLEGRO_TOUCH_INPUT_STATE alias /ALLEGRO_TOUCH_INPUT_STATE
' ALLEGRO_MEMORY_INTERFACE alias /ALLEGRO_MEMORY_INTERFACE
' ALLEGRO_MONITOR_INFO alias /ALLEGRO_MONITOR_INFO
' ALLEGRO_TRANSFORM alias /ALLEGRO_TRANSFORM
' ALLEGRO_STATE alias /ALLEGRO_STATE
' ALLEGRO_SAMPLE_ID alias /ALLEGRO_SAMPLE_ID
' ALLEGRO_VERTEX_ELEMENT alias /ALLEGRO_VERTEX_ELEMENT
' ALLEGRO_VERTEX alias /ALLEGRO_VERTEX
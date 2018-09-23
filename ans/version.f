[undefined] [version] [if]
: packver  swap 8 lshift or swap 24 lshift or ;
: (checkver)  ( ver ver -- )
    over 0 = if 2drop exit then
    2dup
    swap $ff000000 and swap $ff000000 and <> abort" Incompatible major version!"
    swap $00ffffff and swap $00ffffff and 2dup > abort" Incompatible minor version and/or revision!"
    < if  cr  #2 attribute ." Warning: Potentially incompatible minor version and/or revision."
          #0 attribute  space tib #tib @ type   then
;
: .line  cr tib #tib @ type ;
: [version]  ( M m R -- <name> )  .line packver constant ;
: [checkver]  ( M m R packver -- )
    depth 4 < abort" Missing version spec!"
    >r packver r> (checkver) ;

[then]

\ versions are expressed as three values M = major, m = minor, R = revision
\ in documentation, they're expressed as M.m.r
\ Major versions are always source breaking
\ Minor versions are generally additions, but also sometimes deletions, renames, and semantic changes
\ Revisions are bugfixes, and benign tweaks such as dox and housekeeping



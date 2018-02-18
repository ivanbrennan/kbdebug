BEGIN {
    while (("xmodmap -pke" | getline) > 0) # read keymap table
        keysyms[$2]=$4 # e.g.         __   _
                       #     keycode  25 = w W w W
                       #              ‾‾   ‾
}

{
    event=$1" "$2
    printf "%-13s %s [%s]\n", event, $3, keysyms[$NF]
}

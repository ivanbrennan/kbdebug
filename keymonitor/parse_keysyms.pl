BEGIN {
    $"=","; # list-separator ","
    $|++;   # autoflush output after each print

    # keysyms table
    #  { keycode => keysym }
    open X, "-|", "xmodmap -pke";
    while (<X>) {
        if (/^keycode\s+(\d+) = (\w+)/) {
            $keysyms{$1} = $2
        }
    }

    # modifiers indexed by log₂ bitmask
    #  [ Shift              0 = log₂ 0x01
    #  , Caps_Lock          1 = log₂ 0x02
    #  , Controlck          2 = log₂ 0x04
    #  , Alt                3 = log₂ 0x08
    #  , Num_Lock           4 = log₂ 0x10
    #  , mod3               5 = log₂ 0x20
    #  , Super              6 = log₂ 0x40
    #  , ISO_Level3_Shift ] 7 = log₂ 0x80
    open X, "-|", "xmodmap -pm";
    <X>;<X>;
    while (<X>) {
        if (/^(\w+)\s+(\w*)/) {
            ($keysym = $2) =~s/_[LR]$//;
            $modsyms[$i++] = $keysym || $1
        }
    }
    close X;
}

if (/^EVENT type.*\((.*)\)/) {
    $event = $1
} elsif (/detail: (\d+)/) {
    $detail = $1
} elsif (/modifiers:.*effective: (.*)/) {
    $mask = $1;
    if ($event =~ /^Key/) {
        my @mods;
        for (0..$#modsyms) {
            if (hex($mask) & (1<<$_)) {
                push @mods, $modsyms[$_]
            }
        }
        printf "%-12s %3d %-11s %-3s [@mods]\n", $event, $detail, "[$keysyms{$detail}]", $mask
    }
}

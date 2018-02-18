# kbdebug

I'm using this script to monitor keyboard events in order to diagnose some buggy key-repeat behavior on my laptop's keyboard.

I have Caps_Lock mapped to Control, and pressing a Control-modified key occasionally triggers unwanted key-repeats. It's pretty infrequent, but still happens often enough to annoy me.

For example, I'm in a terminal and want to delete the previous word, so I type <kbd>Caps Lock</kbd>+<kbd>W</kbd>. The terminal receives a `^W` char as intended (deleting the previous word), followed by a series of `w` chars, as if I were holding down <kbd>W</kbd>.

# kbdebug

I'm using this script to monitor keyboard events while diagnosing buggy key-repeat behavior on my laptop's keyboard.

I have <kbd>Caps Lock</kbd> mapped to `Control`, and pressing a Control-modified key occasionally triggers unwanted key-repeats.
It happens pretty infrequently, but just often enough to annoy me.

For example, I'm in a terminal and want to delete the previous word.
I type <kbd>Caps Lock</kbd>+<kbd>W</kbd>.
Normally, the terminal receives a `^W` char and deletes the previous word.
But sometimes it receives a `^W` char followed by a series of `w` chars, as if I were holding down <kbd>W</kbd>.
This deletes the previous word and enters `wwwwwwwwwww...`.
The key-repeats continue until the next key-press (on any key).

## xinput

I'm using `xinput` to watch/log key events.
In one variation, I use `xinput test`, and in another I use `xinput test-xi2`, which provides additional information (e.g. raw events, modifier masks, etc.).

## case study

The following user actions generated one sequence of keyboard events in the normal case, and a different sequence in the key-repeat bug case.

User Actions:

* press <kbd>Caps Lock</kbd>
* press <kbd>W</kbd>
* release <kbd>Caps Lock</kbd>
* release <kbd>W</kbd>
* press <kbd>space</kbd>
* release <kbd>space</kbd>

Expected chars:
* `^W` (`0x17`)
* ` ` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(`0x20`)

### xinput test-xi2

These events were observed using the `xinput test-xi2` variation.

**Observed Keyboard Events [correct behavior]**
```
event-type    keycode  keysym   modifier-mask modifier-names flags
----------    ------- --------- ------------- -------------- -----
RawKeyPress      66   Caps_Lock
KeyPress         66   Caps_Lock      0             []
RawKeyPress      25       w
KeyPress         25       w         0x4         [Control]
RawKeyRelease    66   Caps_Lock
KeyRelease       66   Caps_Lock     0x4         [Control]
RawKeyRelease    25       w
KeyRelease       25       w          0             []
RawKeyPress      65     space
KeyPress         65     space        0             []
RawKeyRelease    65     space
KeyRelease       65     space        0             []
```

**Observed Keyboard Events [key-repeat bug]**
```
event-type    keycode  keysym   modifier-mask modifier-names flags
----------    ------- --------- ------------- -------------- -----
RawKeyPress      66   Caps_Lock
KeyPress         66   Caps_Lock      0             []
RawKeyPress      25       w
KeyPress         25       w         0x4         [Control]
RawKeyRelease    66   Caps_Lock
KeyRelease       66   Caps_Lock     0x4         [Control]
KeyPress         25       w          0             []        repeat
KeyPress         25       w          0             []        repeat
KeyPress         25       w          0             []        repeat
KeyPress         25       w          0             []        repeat
KeyPress         25       w          0             []        repeat
KeyPress         25       w          0             []        repeat
RawKeyRelease    25       w
KeyRelease       25       w          0             []
RawKeyPress      65     space
KeyPress         65     space        0             []
RawKeyRelease    65     space
KeyRelease       65     space        0             []
```

In the first case, releasing <kbd>W</kbd> caused `RawKeyRelease` and `KeyRelease` events to be received immediately.
In the second case, the `RawKeyRelease` and `KeyRelease` events for <kbd>W</kbd> were not immediately received.
Instead, repeated `KeyPress` events were received until I pressed <kbd>space</kbd>, at which point the `RawKeyRelease` and `KeyRelease` events for <kbd>W</kbd> were received, followed by the press/release evvents for <kbd>space</kbd>

Another thing to note is that the series of repeated `w` chars appears as a sequence of `KeyPress` events with not `KeyRelease` events intermixed.
This differs with what I observed when using `xinput test`, which showed alternating press/release events (see next section).

### xinput test-xi2

These events were observed using the `xinput test` variation. Unlike the `xinput test-xi2` variation, this reported alternating key press/release events during the bug behavior.

**Observed Keyboard Events [correct behavior]**
```
event-type   keycode  keysym
----------   ------- ---------
key press      66    Caps_Lock
key press      25        w
key release    66    Caps_Lock
key release    25        w
key press      65      space
key release    65      space
```

**Observed Keyboard Events [key-repeat bug]**
```
event-type   keycode  keysym
----------   ------- ---------
key press      66    Caps_Lock
key press      25        w
key release    66    Caps_Lock
key release    25        w
key press      25        w
key release    25        w
key press      25        w
key release    25        w
key press      25        w
key release    25        w
key press      25        w
key release    25        w
key press      25        w
key release    25        w
key press      25        w
key release    25        w
key press      65      space
key release    65      space
```

## rollover

The case-study above involved rollover, since <kbd>Caps Lock</kbd> was released before <kbd>W</kbd> was.
I also tested against a key-sequence with no rollover:

User Actions:

* press <kbd>Caps Lock</kbd>
* press <kbd>W</kbd>
* release <kbd>W</kbd>
* release <kbd>Caps Lock</kbd>
* press <kbd>space</kbd>
* release <kbd>space</kbd>

I've been unable to reproduce the bug when no rollover is involved, which could hint at the underlying cause.
For completeness, the keyboard events for the non-rollover case are documented below.

**Observed Keyboard Events (`xinput test-xi2`)**
```
event-type    keycode  keysym   modifier-mask modifier-names flags
----------    ------- --------- ------------- -------------- -----
RawKeyPress      66   Caps_Lock
KeyPress         66   Caps_Lock      0             []
RawKeyPress      25       w
KeyPress         25       w         0x4         [Control]
RawKeyRelease    25       w
KeyRelease       25       w         0x4         [Control]
RawKeyRelease    66   Caps_Lock
KeyRelease       66   Caps_Lock     0x4         [Control]
RawKeyPress      65     space
KeyPress         65     space        0             []
RawKeyRelease    65     space
KeyRelease       65     space        0             []
```

**Observed Keyboard Events (`xinput test`)**
```
event-type   keycode  keysym
----------   ------- ---------
key press      66    Caps_Lock
key press      25        w
key release    66    Caps_Lock
key release    25        w
key press      65      space
key release    65      space
```

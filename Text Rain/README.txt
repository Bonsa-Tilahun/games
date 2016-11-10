Bonsa Tilahun

First I decided to make velocity based on some kind of gravity approach. Basically,
every letter is bound to a constant downwards constant acceleration and its velocity
is reset upon contact. I tried implement a bouncing system but the difficulty of
reliably spotting collisions make it too inconsistent so I remove the system.

Then in order to make it so that some words can appear I choose to keep up a list of
"planned letters" that would be filled up with letters on specific positions that
make a word so that if every letter end up being chosen the word will appear. In
order for the rain to still look random when adding a new letter it would randomly
choose between adding a "planned letter" or a completely random one. Also words end
up in the same color which make them easier to spot.
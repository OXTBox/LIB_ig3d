# A-88: a game design document outline, from GameOverViewData's tabs

Opus, 15 Nov 2026. The owner asked: "Not sure what this is, but it sounds good. Explain it in one
paragraph with an example before building."

## What it is (one paragraph)

In 2008 iGame3D had a stack called **GameOverViewData**: a form with one tab for each part of a
game's plan (Overview, Philosophy, Goals, World Layout, Scheduled, Sounds, Music, Weapons, Camera).
Its save button never worked (typos), so nothing was ever kept. The idea for A-88 is to keep the
**outline**, not the stack. Every new game gets a short plain-text design document with those
headings, filled in **before** any code. It has three readers. You check that the game is the one
you meant. Spark or a model can draft it from a one-line idea. The builder (me, or a LIB_HOWTO
tutorial) works from it, so features don't drift. It is a text file next to the game script, so git
keeps its history. Later a small stack or the Status_Browser could show it as tabs again, if wanted.

## The outline (headings and what goes under each)

| Heading (GameOverViewData tab) | What to write |
|---|---|
| Overview | the game in 2 or 3 sentences: who, where, what you do |
| Philosophy | the feeling it is after, and what it teaches the player |
| Goals | how you win, lose and score; what keeps you playing |
| World Layout | the play space, the camera's view of it, how it changes |
| Scheduled | the phases or levels in order (also the build order) |
| Sounds | the effects and what each one tells you |
| Music | mood and tempo; when it changes |
| Weapons | here, whatever the player acts with (a ball, a tool, a skill) |
| Camera | the view, its moves, and what is always on screen |
| Controls *(added)* | every key and mouse action |
| Open questions *(added)* | what the owner must decide, each with a default |

## The example: VECTOR TOSS (from the owner's review of 15 Nov, 11:01)

**Overview.** PROMPT and GLAZE (Amazing Couple's heroes) face each other across an arena, one on
each side, PONG style. They throw a ball of vectors to each other and catch it. You play one of them;
**C** swaps to the companion.

**Philosophy.** First, play: easy tosses, gentle bounces, trails and particles, nothing to lose.
Then the same throw slowly gets dangerous. It teaches aiming with angle and power, reading a bounce
early, and moving to catch.

**Goals.** Points for each catch. A flat side-to-side throw scores zero (the first lesson). After
someone reaches about 5 points, a hit on the other side's floor breaks that tile. Bonus points for
every strike on the inside of a wall, and the most for keeping the ball bouncing between the two
walls. A fall into a hole costs you, unless you have hang time: one free hang every 2000 points
lets you catch the edge and climb out.

**World Layout.** A deep arena, seen at an angle (isometric, deeper than a fighting game) so there
is room to run and many angles to catch from. Side, top and bottom bounds bounce the ball. Then a
wall rises on each side: first close to the players (the ricochet is easier to read early), later
towards the centre (less time to react, and a stronger ball that wrecks floor tiles).

**Scheduled (also the build order).**
1. Core: the arena, the camera, both heroes, aim / power / throw / catch, gentle bounces, scores, C to swap.
2. Walls: they rise and close in; inside-wall bonus points; the TAB landing marker.
3. Hazards: floor tiles break, jumping over holes, hang time.
4. Polish: trails (repeating-image echoes), particles, sounds.

**Sounds.** A soft tock for each bounce (higher as the ball gets faster), a catch chime, a wall
crack, a tile crumble, a fall whoosh, a hang grunt.

**Music.** Easy and loose in the play rounds; tighter and faster once the walls rise.

**Weapons.** The ball only. Aim: click shows a ghost ball pulsing between 30% and 50% brightness;
click in the top or bottom part of the screen to set the angle; the mouse wheel sets the power;
click to throw. The ball grows more powerful as the walls close in.

**Camera.** Fixed isometric over the whole arena; both heroes always in view. On screen: both scores,
the hang-time count, and the power meter while aiming.

**Controls.** WASD run on your side; Space jump; mouse to aim, wheel to set power, click to throw;
C swap to the companion; TAB show or hide the landing marker (to test the advantage).

**Open questions (defaults in brackets).**
- Mocap: capture a ledge hang and climb-out? [yes when you can; until then a still pose].
- Does the companion play by itself while you hold the other one? [yes: it walks to where the ball will land and catches].
- What ends a game: a score, a time, or the floor running out? [first to 21, or the floor gone].

## Building it (only after the owner says so)
Text files `<Game>_GDD.md` next to each game script, made from this outline. Spark can draft one
from a game idea (LIB_SPARK); LIB_HOWTO can open each tutorial with one. No stack is needed for
that. A viewer with tabs comes later, if wanted.

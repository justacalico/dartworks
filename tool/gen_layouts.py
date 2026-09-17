#!/usr/bin/env python3
"""Dev tool: generates level layout maps for lib/src/data/levels/*.dart.

Each level is drawn on a canvas with rooms, walls, platforms and placed
entity glyphs, then merged into the matching dart file's `layout:` block.
Run: python3 tool/gen_layouts.py
"""
import re, sys

W, H = 88, 22


class Canvas:
    def __init__(self, w=W, h=H, fill='.'):
        self.w, self.h = w, h
        self.g = [[fill] * w for _ in range(h)]

    def set(self, x, y, ch):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.g[y][x] = ch

    def hline(self, x0, x1, y, ch='#'):
        for x in range(min(x0, x1), max(x0, x1) + 1):
            self.set(x, y, ch)

    def vline(self, x, y0, y1, ch='#'):
        for y in range(min(y0, y1), max(y0, y1) + 1):
            self.set(x, y, ch)

    def rect(self, x0, y0, x1, y1, ch='#'):
        self.hline(x0, x1, y0, ch)
        self.hline(x0, x1, y1, ch)
        self.vline(x0, y0, y1, ch)
        self.vline(x1, y0, y1, ch)

    def fill_rect(self, x0, y0, x1, y1, ch='#'):
        for y in range(y0, y1 + 1):
            self.hline(x0, x1, y, ch)

    def put(self, x, y, s):
        for i, ch in enumerate(s):
            self.set(x + i, y, ch)

    def rows(self):
        return [''.join(r) for r in self.g]

    def border(self, ch='#'):
        self.rect(0, 0, self.w - 1, self.h - 1, ch)


def floor_room(c, floor_y):
    """Solid ground + outer walls."""
    c.hline(0, c.w - 1, floor_y)
    c.hline(0, c.w - 1, c.h - 1)
    c.vline(0, 0, c.h - 1)
    c.vline(c.w - 1, 0, c.h - 1)


LEVELS = {}


def L(name):
    def deco(fn):
        LEVELS[name] = fn()
        return fn
    return deco


# ---------------------------------------------------------------- breakroom
@L('breakroom')
def _():
    c = Canvas(72, 18)
    c.border()
    floor_room(c, 16)
    # sorting chamber (left) separated by wall at x=20 with door D
    c.vline(20, 1, 15)
    c.set(20, 14, 'D')
    c.set(20, 15, 'D')
    # props to sort + player + archive bin + clipboard
    c.put(4, 15, 'P')
    c.put(6, 15, 'w')
    c.put(8, 15, 'v')
    c.put(10, 15, 'u')
    c.put(12, 15, 'i')
    c.put(14, 15, 'a')
    c.set(17, 15, 'A')
    c.set(8, 13, '*')
    # office side: clutter + second clipboard + exit
    c.put(30, 15, 'x.x')
    c.set(45, 15, 'l')
    c.set(58, 14, '*')
    c.set(68, 15, 'E')
    return c.rows()


# ------------------------------------------------------------------ museum
@L('museum')
def _():
    c = Canvas(88, 22)
    c.border()
    floor_room(c, 20)
    # hall dividers
    c.vline(28, 8, 19)
    c.set(28, 18, 'D'); c.set(28, 19, 'D')
    c.vline(58, 8, 19)
    c.set(58, 18, 'D'); c.set(58, 19, 'D')
    # hall 1: movement tutorial - steps + hop gap + clipboard
    c.set(4, 19, 'P')
    c.set(8, 19, '*')
    c.fill_rect(12, 18, 14, 19)
    c.fill_rect(16, 16, 18, 19)
    c.hline(21, 24, 15, '=')
    # hall 2: physics exhibit - crates, ball, monomat, bonebox
    c.put(32, 19, 'x.x')
    c.set(36, 18, 'x')
    c.set(40, 19, 'o')
    c.set(44, 19, 'w')  # basketball hoop prop
    c.set(48, 19, 'm')
    c.set(52, 19, 'b')  # gachapon bonebox
    c.set(50, 12, '*')
    c.hline(46, 54, 13, '=')
    # hall 3: reclamation exhibit - bin + museum_basement module
    c.set(62, 19, 'R')
    c.set(66, 19, '1')  # module:museum_basement pedestal
    c.set(70, 19, 'g')
    c.set(64, 16, '*')
    c.hline(62, 70, 17, '=')
    # hidden room: pushable wall H in ceiling corner -> blankbox module
    c.fill_rect(80, 2, 86, 6)
    c.set(80, 4, 'H')
    c.set(83, 4, '2')   # module:blankbox on a bonebox
    c.hline(76, 86, 7, '=')
    c.put(74, 18, 'x.x')
    # redacted module in the anomalous objects exhibit
    c.set(74, 19, '3')  # module:redacted_chamber
    c.set(85, 19, 'E')
    return c.rows()


# ----------------------------------------------------------------- streets
@L('streets')
def _():
    c = Canvas(88, 22)
    c.border()
    floor_room(c, 20)
    # alley drop-in
    c.set(3, 19, 'P')
    c.put(2, 18, 'x')
    # street canyon: platforms, dumpster, first nullbodies
    c.set(10, 19, 'n')
    c.set(14, 19, 'n')
    c.hline(16, 20, 17, '=')
    c.set(18, 16, '*')
    c.set(22, 19, 'w')   # crowbar
    c.set(26, 19, 'n')
    c.set(28, 19, 'r')
    # scaffold to rooftops
    c.hline(30, 34, 16, '=')
    c.hline(33, 37, 13, '=')
    c.set(35, 12, 'b')   # bonebox: turret gachapon (sculpture top)
    c.set(36, 19, 'v')   # baton
    # mid street: monomat + omni patrol + turret
    c.set(44, 19, 'm')
    c.set(48, 12, 'O')
    c.set(50, 19, 'c')
    c.set(54, 19, 'n')
    c.fill_rect(56, 18, 58, 19)
    c.set(57, 17, 't')
    # playroom section: elevated floor + balloon gun bonebox
    c.vline(62, 12, 19)
    c.set(62, 18, 'D'); c.set(62, 19, 'D')
    c.hline(64, 70, 14, '=')
    c.set(67, 13, 'b')   # bonebox: balloon gun
    c.set(69, 13, '*')
    c.set(66, 19, 'n')
    c.set(68, 19, 'r')
    c.set(72, 19, 'u')   # p350 first gun
    # exit through transit station 5
    c.fill_rect(78, 14, 80, 19)
    c.hline(78, 86, 13, '=')
    c.set(82, 12, '*')
    c.set(84, 19, 'n')
    c.set(86, 19, 'E')
    return c.rows()


# ------------------------------------------------------------------ runoff
@L('runoff')
def _():
    c = Canvas(88, 22)
    c.border()
    # drainage channel: lower waterline, upper walkways
    floor_room(c, 19)
    c.set(3, 18, 'P')
    c.set(6, 18, '*')
    c.set(9, 18, 'w')    # rifle (m16)
    # first drop: channel with zombish reveal
    c.set(16, 18, 'z')
    c.set(20, 18, 'r')
    # elevator puzzle: rising platform over a deep channel
    c.fill_rect(26, 14, 30, 18)  # ledge
    c.hline(26, 30, 13, '=')
    c.set(33, 18, 'q')   # vertical elevator
    c.fill_rect(38, 12, 42, 18)
    c.set(40, 11, '*')
    # monomat after the drop + zombish pack
    c.set(46, 18, 'm')
    c.set(50, 18, 'z')
    c.set(53, 18, 'z')
    c.set(56, 18, 'h')   # zombish thrower
    c.hline(48, 58, 15, '=')
    c.set(52, 14, 'v')   # uzi on the walkway
    # omni cleanup squad in the open trench
    c.set(62, 10, 'O')
    c.set(66, 18, 'z')
    c.set(70, 18, 'n')
    c.hline(64, 72, 14, '=')
    c.set(68, 13, 's')   # slow-time charge
    # bonebox: omniprojector gachapon under debris
    c.put(74, 18, 'xx')
    c.set(75, 17, 'b')
    # outfall climb + exit
    c.fill_rect(78, 16, 80, 18)
    c.hline(78, 86, 15, '=')
    c.set(84, 14, '*')
    c.set(86, 18, 'E')
    return c.rows()


# ------------------------------------------------------------------ sewers
@L('sewers')
def _():
    c = Canvas(88, 22)
    c.border()
    floor_room(c, 19)
    # dark tunnels - flashlight immediately at start
    c.set(3, 18, 'P')
    c.set(5, 18, 'F')
    c.set(7, 18, '*')
    # low pipe crawl
    c.fill_rect(12, 15, 22, 16)
    c.set(17, 18, 'r')
    c.set(20, 18, 'z')
    # junction: upper catwalk + lower channel
    c.hline(24, 34, 14, '=')
    c.set(28, 13, 'w')   # machete
    c.set(30, 18, 'c')
    c.set(33, 18, 'z')
    # melon growing zone (hidden gachapon)
    c.fill_rect(38, 10, 44, 12)
    c.set(41, 9, 'b')    # corrupted nullbody gachapon
    c.set(40, 18, 'u')   # melon prop
    c.set(42, 18, 'u')
    # corrupted nullbody ambush
    c.set(48, 18, 'N')
    c.set(52, 18, 'N')
    c.set(55, 18, 'z')
    c.hline(50, 58, 15, '=')
    c.set(54, 14, '*')
    # deep water section: platforms over hazard
    c.hline(60, 70, 18, '^')
    c.set(62, 17, '=')
    c.set(65, 16, '=')
    c.set(68, 17, '=')
    c.set(64, 18, 'j')   # junkie zombish
    c.set(70, 12, 'O')
    # monomat + climb out
    c.set(74, 18, 'm')
    c.fill_rect(78, 16, 80, 18)
    c.hline(78, 86, 15, '=')
    c.set(82, 14, 'v')   # shotgun-ish: combat knife fallback -> mp5k
    c.set(84, 18, 'N')
    c.set(86, 18, 'E')
    return c.rows()


# --------------------------------------------------------------- warehouse
@L('warehouse')
def _():
    c = Canvas(88, 22)
    c.border()
    floor_room(c, 20)
    c.set(3, 19, 'P')
    c.set(6, 19, '*')
    # shelf canyon: stacked crates form climbable walls
    c.put(10, 19, 'xxx')
    c.put(10, 18, 'xx')
    c.set(10, 17, 'x')
    c.set(15, 19, 'w')   # firefighter axe
    # warehouse 4B: the crablet nest
    c.vline(22, 8, 19)
    c.set(22, 18, 'D'); c.set(22, 19, 'D')
    c.put(26, 19, 'cc')
    c.put(30, 19, 'c.c')
    c.put(34, 19, 'C')
    c.put(28, 15, 'ooo')
    c.hline(26, 36, 14, '=')
    c.set(31, 13, '*')
    # container wall: moving platforms carry you over
    c.fill_rect(42, 10, 46, 19)  # the wall
    c.set(40, 12, 'Q')           # horizontal container lift
    c.set(48, 8, 'Q')
    # invisible barrier window gag
    c.set(52, 16, 'I')
    c.set(52, 17, 'I')
    c.set(52, 18, 'I')
    c.set(54, 19, 'n')
    # train + bonebox: crablet gachapon above
    c.hline(58, 66, 17, '=')
    c.put(58, 19, 'xx')
    c.set(62, 16, 'b')
    c.set(64, 19, 'v')   # sledgehammer
    # omni squad in the loading dock
    c.set(70, 10, 'O')
    c.set(72, 19, 'N')
    c.set(76, 19, 'm')
    c.set(80, 19, 'n')
    c.set(84, 19, '*')
    c.set(86, 19, 'E')
    return c.rows()


# --------------------------------------------------------- central station
@L('central_station')
def _():
    c = Canvas(88, 22)
    c.border()
    floor_room(c, 20)
    c.set(3, 19, 'P')
    # platform 1: turret gauntlet
    c.set(8, 19, 't')
    c.set(12, 19, 'z')
    c.hline(14, 20, 16, '=')
    c.set(17, 15, '*')
    # track trench 1
    c.hline(22, 26, 20, '.')
    c.set(22, 19, '.'); c.set(23, 19, '.'); c.set(24, 19, '.')
    c.set(25, 19, '.')
    c.hline(22, 25, 19, '=')
    # platform 2: maintenance tunnels
    c.set(28, 19, 'c')
    c.set(31, 19, 'Z')
    c.set(35, 19, 'm')
    c.vline(38, 14, 19)
    c.set(38, 18, 'D'); c.set(38, 19, 'D')
    # tunnel fight: omni vs zombish crossfire
    c.set(42, 19, 'h')
    c.set(46, 19, 'z')
    c.set(48, 12, 'O')
    c.set(50, 19, 'j')
    c.hline(44, 52, 15, '=')
    c.set(48, 14, 'w')   # mk18
    # track trench 2 with hazard
    c.hline(54, 58, 19, '^')
    c.set(55, 17, '=')
    c.set(57, 16, '=')
    # escalator ascent: stacked platforms
    c.hline(60, 64, 17, '=')
    c.hline(64, 68, 14, '=')
    c.hline(68, 72, 11, '=')
    c.set(70, 10, '*')
    c.set(66, 18, 'N')
    # last platform
    c.set(74, 19, 't')
    c.set(78, 19, 'Z')
    c.set(80, 19, 's')
    c.set(84, 19, '*')
    c.set(86, 19, 'E')
    return c.rows()


# ------------------------------------------------------------------- tower
@L('tower')
def _():
    c = Canvas(88, 22)
    c.border()
    floor_room(c, 20)
    c.set(3, 19, 'P')
    # mall atrium: zombish vs omni war
    c.set(8, 19, 'z')
    c.set(12, 12, 'O')
    c.set(14, 19, 'h')
    c.set(16, 19, 'm')
    # food court: first keycard behind the counter
    c.vline(20, 12, 19)
    c.set(20, 18, 'K'); c.set(20, 19, 'K')   # locked door
    c.set(24, 19, 'k')                        # keycard 1
    c.put(26, 19, 'x.x')
    c.set(30, 19, 'Z')
    c.hline(26, 34, 15, '=')
    c.set(30, 14, '*')
    # cinema level: second keycard up top
    c.hline(38, 44, 12, '=')
    c.set(41, 11, 'k')                        # keycard 2
    c.set(40, 19, 'j')
    c.set(44, 19, 'z')
    # atrium elevator shaft
    c.vline(50, 8, 19)
    c.set(50, 18, 'K'); c.set(50, 19, 'K')   # locked door 2
    c.set(52, 19, 'q')                       # elevator platform
    # upper plaza
    c.hline(56, 64, 10, '=')
    c.set(60, 9, 'w')                        # katana
    c.set(58, 19, 'h')
    c.set(62, 19, 'Z')
    c.set(64, 12, 'O')
    # ford vr junkie gachapon on the roof edge
    c.hline(70, 76, 7, '=')
    c.set(73, 6, 'b')
    c.set(72, 19, 'N')
    # final elevator to time tower
    c.set(78, 19, 'q')
    c.set(80, 19, 'm')
    c.set(83, 19, '*')
    c.set(86, 19, 'E')
    return c.rows()


# -------------------------------------------------------------- time tower
@L('time_tower')
def _():
    c = Canvas(88, 22)
    c.border()
    floor_room(c, 20)
    c.set(3, 19, 'P')
    # grand lobby: oval exhibits + gravity staff
    c.set(8, 19, 'w')    # gravity staff
    c.set(10, 19, '*')
    c.hline(12, 16, 16, '=')
    c.set(14, 15, 'g')   # duck season gachapon exhibit
    # gravity core chamber: nullmen worship the pyramid
    c.vline(24, 10, 19)
    c.set(24, 18, 'D'); c.set(24, 19, 'D')
    # the void pyramid (gravity field column)
    c.fill_rect(38, 4, 42, 6, 'G')
    c.set(40, 3, 'G')
    c.put(36, 19, 'nn')
    c.put(42, 19, 'nn')
    c.put(30, 19, 'N')
    c.put(48, 19, 'N')
    # four energy cores strewn about + four sockets
    c.set(28, 19, 'e')
    c.set(34, 19, 'e')
    c.set(46, 19, 'e')
    c.set(52, 19, 'e')
    c.set(30, 14, '0')
    c.set(36, 14, '0')
    c.set(44, 14, '0')
    c.set(50, 14, '0')
    c.hline(28, 52, 15, '=')
    # gravity wells: zero-g columns to reach sockets
    c.vline(31, 16, 18, 'G')
    c.vline(37, 16, 18, 'G')
    c.vline(45, 16, 18, 'G')
    c.vline(51, 16, 18, 'G')
    # crablet plus guard in the wall insets
    c.set(56, 8, 'b')    # crablet plus gachapon
    c.set(58, 19, 'C')
    # ascension to the void
    c.vline(62, 10, 19)
    c.set(62, 18, 'D'); c.set(62, 19, 'D')
    c.hline(66, 72, 16, '=')
    c.hline(72, 78, 13, '=')
    c.set(75, 12, '*')
    c.set(70, 19, 's')
    c.set(80, 19, 'N')
    c.set(86, 19, 'E')
    return c.rows()


# ----------------------------------------------------------------- dungeon
@L('dungeon')
def _():
    c = Canvas(88, 22)
    c.border()
    floor_room(c, 20)
    # gaol cells
    for x in (8, 14, 20):
        c.vline(x, 14, 19)
        c.set(x, 18, 'D')
    c.set(3, 19, 'P')
    c.set(6, 19, '*')
    c.set(11, 19, 'f')   # ford clone mimics
    c.set(17, 19, 'f')
    # cell block corridor
    c.set(24, 19, 'w')   # spiked club
    c.set(28, 19, 'f')
    c.set(32, 19, 'r')
    # climb shaft out of the gaol
    c.hline(36, 40, 16, '=')
    c.hline(40, 44, 13, '=')
    c.hline(44, 48, 10, '=')
    c.set(46, 9, 'b')    # ford clone gachapon above the exit gate
    c.set(42, 19, 'f')
    # dungeon proper: torch halls + cloning pits
    c.fill_rect(52, 14, 54, 19)   # pit wall
    c.set(50, 19, 'f')
    c.set(56, 19, 'f')
    c.set(60, 19, 'v')   # half sword
    c.hline(58, 66, 15, '=')
    c.set(62, 14, '*')
    c.set(64, 19, 'f')
    # lava crack
    c.hline(68, 72, 19, '^')
    c.set(69, 17, '=')
    c.set(71, 16, '=')
    # gaoler's walk + gate
    c.set(74, 19, 'f')
    c.set(78, 19, 'u')   # bastard sword
    c.fill_rect(80, 16, 82, 19)
    c.hline(80, 86, 15, '=')
    c.set(84, 14, 'f')
    c.set(86, 19, 'E')
    return c.rows()


# ------------------------------------------------------------------- arena
@L('arena')
def _():
    c = Canvas(88, 22)
    c.border()
    floor_room(c, 20)
    # the pit: open kill floor, weapons on racks
    c.set(4, 19, 'P')
    c.set(6, 19, 'w')    # norse axe
    c.set(8, 19, 'v')    # double axe
    c.set(10, 19, '*')
    c.set(12, 19, '*')
    # spectator terraces (spawn ledges for waves)
    c.hline(14, 24, 14, '=')
    c.hline(30, 40, 14, '=')
    c.hline(46, 56, 14, '=')
    c.hline(62, 72, 14, '=')
    c.hline(20, 34, 9, '=')
    c.hline(44, 58, 9, '=')
    c.set(27, 8, 's')
    c.set(51, 8, 's')
    # wave spawn markers on the terraces
    c.set(19, 13, 'X')
    c.set(35, 13, 'X')
    c.set(51, 13, 'X')
    c.set(67, 13, 'X')
    c.set(27, 8, 'X')
    c.set(51, 8, 'X')
    # center pit hazards
    c.hline(38, 44, 19, '^')
    c.set(40, 17, '=')
    c.set(42, 16, '=')
    # king's box high above
    c.fill_rect(78, 4, 86, 8)
    c.set(82, 7, 'B')    # king ford watches from his box
    # gatehouse exit
    c.set(80, 19, 'm')
    c.set(86, 19, 'E')
    return c.rows()


# ------------------------------------------------------------ throne room
@L('throne_room')
def _():
    c = Canvas(88, 22)
    c.border()
    floor_room(c, 20)
    # castle gardens approach
    c.set(4, 19, 'P')
    c.set(8, 19, '*')
    c.set(12, 19, 'f')   # cheering ford clones
    c.set(16, 19, 'f')
    # great hall pillars
    for x in (24, 30, 36):
        c.vline(x, 14, 19)
    c.set(27, 19, 'w')   # claymore
    c.set(33, 19, 'v')   # polearm spear
    # the throne: king ford + crown mechanic
    c.vline(44, 8, 19)
    c.set(44, 18, 'D'); c.set(44, 19, 'D')
    c.hline(48, 54, 16, '=')
    c.set(51, 15, 'B')   # king ford on his throne
    c.put(48, 19, 'f')
    c.put(54, 19, 'f')
    # backstage: unfinished offices + alora's message
    c.vline(60, 8, 19)
    c.set(60, 18, 'D'); c.set(60, 19, 'D')
    c.put(64, 19, 'xx')
    c.set(66, 19, '*')
    c.set(68, 19, 'y')   # battery for the garage elevator
    c.set(70, 19, '!')   # socket
    # chamber 02: bulkhead gated by the battery, then the void climb
    c.vline(74, 8, 19)
    c.set(74, 18, 'K'); c.set(74, 19, 'K')
    c.vline(78, 4, 18, 'G')   # void column
    c.vline(82, 4, 18, 'G')
    c.hline(78, 82, 18, '=')
    c.set(80, 6, '*')
    c.set(86, 19, 'E')
    return c.rows()


# --------------------------------------------------------- museum basement
@L('museum_basement')
def _():
    c = Canvas(88, 22)
    c.border()
    floor_room(c, 20)
    c.set(4, 19, 'P')
    c.set(6, 19, '*')
    # playroom quarter: gym shape parkour (red tiles)
    c.fill_rect(10, 17, 14, 19)
    c.hline(10, 14, 16, '=')
    c.fill_rect(16, 14, 19, 19)
    c.hline(21, 25, 12, '=')
    c.set(23, 11, 'w')   # basketball
    # sandbox machines + monomat + reclamation
    c.set(30, 19, 'm')
    c.set(34, 19, 'R')
    c.set(38, 19, 'o')
    c.put(40, 19, 'xx')
    # displays: reclaimed arsenal to play with
    c.set(46, 19, 'v')   # crowbar
    c.set(48, 19, 'u')   # p350
    c.set(50, 19, 'i')   # mp5
    c.set(52, 19, 'a')   # katana
    c.hline(44, 54, 15, '=')
    c.set(49, 14, 'g')
    # pedestal buttons: npc spawner + props
    c.set(58, 19, 'n')   # a lone test nullbody
    c.set(62, 19, 'c')
    c.set(66, 19, 'x')
    c.set(70, 19, 's')
    c.set(76, 19, 'l')   # noodledog
    c.set(82, 19, '*')
    c.set(86, 19, 'E')
    return c.rows()


# ---------------------------------------------------------------- blankbox
@L('blankbox')
def _():
    c = Canvas(88, 22)
    c.border()
    floor_room(c, 20)
    # a massive empty chamber: table, two machines, light switch
    c.set(4, 19, 'P')
    c.set(8, 19, '*')
    # the table
    c.hline(16, 22, 17, '=')
    c.set(18, 16, 'w')   # basketball on the table
    c.set(20, 16, 'v')   # takeaway cup
    # sandbox machines
    c.set(30, 19, 'm')
    c.set(34, 19, 'R')
    # a few props, otherwise nothing. that is the point.
    c.set(50, 19, 'x')
    c.set(54, 19, 'o')
    c.set(70, 19, 'i')   # utility gun
    c.set(86, 19, 'E')
    return c.rows()


# --------------------------------------------------------- redacted chamber
@L('redacted_chamber')
def _():
    c = Canvas(88, 22)
    c.border()
    floor_room(c, 20)
    c.set(4, 19, 'P')
    c.set(6, 19, '*')
    # the desk: three hinged targets that must all be down at once
    c.set(14, 19, 'T')
    c.set(18, 19, 'T')
    c.set(22, 19, 'T')
    c.set(16, 19, 'w')   # spear to weigh one down
    c.set(20, 19, 'u')   # p350 to shoot one
    # hanging crate on ceiling rails with the battery
    c.hline(30, 40, 8, '=')
    c.set(35, 9, 'y')    # battery in the crate
    c.set(34, 19, 'x')
    c.hline(32, 38, 14, '=')
    c.set(34, 13, '*')
    # battery socket + lever opens the bulkhead
    c.set(44, 19, '!')
    c.set(48, 19, 'o')
    # the bulkhead: locked door K
    c.vline(52, 8, 19)
    c.set(52, 18, 'K'); c.set(52, 19, 'K')
    # corridor of crablets beyond
    c.set(56, 19, 'c')
    c.set(60, 19, 'c')
    c.set(64, 19, 'C')
    c.set(68, 19, 'v')   # sledgehammer
    # handgun range module at the end
    c.set(74, 19, '1')   # module:handgun_range
    c.set(78, 19, 'g')
    c.set(82, 19, '*')
    c.set(86, 19, 'E')
    return c.rows()


# ------------------------------------------------------------ handgun range
@L('handgun_range')
def _():
    c = Canvas(88, 22)
    c.border()
    floor_room(c, 20)
    c.set(4, 19, 'P')
    c.set(6, 19, 'u')    # P350 rack
    c.set(8, 19, 'u')
    c.set(10, 19, '*')
    # the course: targets at varied heights and ranges
    c.set(20, 19, 'T')
    c.hline(26, 30, 15, '=')
    c.set(28, 14, 'T')
    c.set(34, 19, 'T')
    c.hline(38, 42, 11, '=')
    c.set(40, 10, 'T')
    c.fill_rect(46, 16, 48, 19)   # barrier to shoot around
    c.set(52, 19, 'T')
    c.hline(56, 60, 14, '=')
    c.set(58, 13, 'T')
    c.set(64, 19, 'T')
    c.set(70, 19, 'T')
    # tuscany module on a box past the last target
    c.fill_rect(74, 17, 76, 19)
    c.set(75, 16, '1')   # module:tuscany
    c.set(80, 19, '*')
    c.set(86, 19, 'E')
    return c.rows()


# ----------------------------------------------------------------- tuscany
@L('tuscany')
def _():
    c = Canvas(88, 22)
    c.border()
    floor_room(c, 20)
    # the villa: terracotta terraces and a wine cellar
    c.set(4, 19, 'P')
    c.set(6, 19, '*')
    c.hline(12, 20, 16, '=')
    c.set(16, 15, 'w')   # melon
    c.hline(24, 32, 12, '=')
    c.set(28, 11, 'v')   # another melon
    # villa walls
    c.vline(38, 10, 19)
    c.set(38, 18, 'D'); c.set(38, 19, 'D')
    c.put(42, 19, 'xx')
    c.set(46, 19, 'u')   # wine... melon
    c.hline(42, 50, 14, '=')
    c.set(46, 13, '*')
    # courtyard garden
    c.set(56, 19, 'w')
    c.set(60, 19, 'o')
    c.hline(58, 66, 16, '=')
    c.set(62, 15, 'g')
    # sunset terrace exit
    c.hline(70, 78, 12, '=')
    c.set(74, 11, '*')
    c.set(80, 19, 'i')   # basketball
    c.set(86, 19, 'E')
    return c.rows()


# --------------------------------------------------------- zombie warehouse
@L('zombie_warehouse')
def _():
    c = Canvas(88, 22)
    c.border()
    floor_room(c, 20)
    # fortified shop floor
    c.set(6, 19, 'P')
    c.set(8, 19, 'w')    # board gun
    c.set(10, 19, '*')
    c.set(12, 19, 'm')   # monomat 1
    # boarding points: windows the horde pours through
    c.vline(22, 12, 19)
    c.set(22, 14, 'X'); c.set(22, 15, 'X'); c.set(22, 16, 'X')
    c.hline(24, 30, 15, '=')
    c.set(27, 14, 'g')
    c.set(44, 10, 'X')
    c.set(58, 13, 'X')
    c.set(80, 12, 'X')
    # kill floor
    c.set(34, 19, 'x')
    c.set(38, 19, 'o')
    c.hline(36, 44, 16, '=')
    # second monomat + key door to the back rooms
    c.set(48, 19, 'm')
    c.vline(52, 12, 19)
    c.set(52, 18, 'K'); c.set(52, 19, 'K')
    c.set(46, 19, 'k')
    # back rooms: more space to hold
    c.put(56, 19, 'xx')
    c.set(60, 19, 'v')   # firefighter axe
    c.hline(58, 66, 14, '=')
    c.set(62, 13, 's')
    c.set(68, 19, 'u')   # uzi
    c.set(72, 19, 'R')
    # last stand corner
    c.set(78, 19, 'x')
    c.set(82, 19, 'o')
    c.set(84, 19, '*')
    c.set(86, 19, 'E')
    return c.rows()


# ------------------------------------------------------------ fantasy arena
@L('fantasy_arena')
def _():
    c = Canvas(88, 22)
    c.border()
    floor_room(c, 20)
    c.set(4, 19, 'P')
    c.set(6, 19, 'w')    # claymore
    c.set(8, 19, 'v')    # norse axe
    c.set(10, 19, '*')
    # dusk pit: wider terraces, void sky
    c.hline(16, 28, 15, '=')
    c.hline(34, 48, 15, '=')
    c.hline(54, 68, 15, '=')
    c.hline(24, 40, 10, '=')
    c.hline(46, 62, 10, '=')
    c.set(32, 9, 's')
    c.set(54, 9, 's')
    # wave spawn markers
    c.set(22, 14, 'X')
    c.set(41, 14, 'X')
    c.set(61, 14, 'X')
    c.set(54, 9, 'X')
    # center hazard pit
    c.hline(40, 48, 19, '^')
    c.set(43, 17, '=')
    c.set(45, 16, '=')
    c.set(60, 19, 'm')
    c.set(70, 19, 'u')   # katana rack
    c.set(80, 19, '*')
    c.set(86, 19, 'E')
    return c.rows()


# ------------------------------------------------------------------- merge
def main():
    import os
    only = sys.argv[1:] if len(sys.argv) > 1 else None
    for name, rows in LEVELS.items():
        if only and name not in only:
            continue
        path = f'lib/src/data/levels/{name}.dart'
        if not os.path.exists(path):
            print(f'SKIP {name}: no file')
            continue
        src = open(path).read()
        block = '  layout: [\n' + ''.join(
            f"    '{r}',\n" for r in rows) + '  ],'
        src = re.sub(r'  layout: \[.*?\],', block, src, flags=re.S)
        open(path, 'w').write(src)
        print(f'WROTE {name} ({len(rows[0])}x{len(rows)})')


if __name__ == '__main__':
    main()

/// A collectible Clipboard / MonoChat lore note.
class NoteInfo {
  const NoteInfo({
    required this.id,
    required this.levelId,
    required this.title,
    required this.author,
    required this.body,
  });

  final String id;

  /// Level this note is found in. `menu` for notes outside any level.
  final String levelId;
  final String title;
  final String author;
  final String body;
}

/// Every clipboard scattered through the game. Bodies are original writing
/// in the tone of Monogon internal memos and MonoChat exchanges.
const List<NoteInfo> kNotes = [
  // -- Breakroom ----------------------------------------------------------
  NoteInfo(
    id: 'breakroom_1',
    levelId: 'breakroom',
    title: 'SORTING PROTOCOL',
    author: 'MONOGON OPS',
    body:
        'REMINDER: anomalous objects go in the ARCHIVE bin, not the break '
        'room fridge. Last week someone stored a Bolt Pupper next to the '
        'lunches. It ate three yoghurts and a stapler.',
  ),
  NoteInfo(
    id: 'breakroom_2',
    levelId: 'breakroom',
    title: 're: headset',
    author: 'HAYES M.',
    body:
        'Ford, your Gammon unit is still flagged for that firmware flash. '
        'IT keeps asking me why a security director needs kernel access to '
        'a VR headset. What did you do to it?',
  ),

  // -- Museum -------------------------------------------------------------
  NoteInfo(
    id: 'museum_1',
    levelId: 'museum',
    title: 'ORIENTATION NOTICE',
    author: 'MUSEUM STAFF',
    body:
        'Welcome to the Museum of Technical Demonstration. Please do not '
        'climb on the exhibits, feed the robotic arms, or attempt to '
        'reclaim the building itself. Yes, someone tried.',
  ),
  NoteInfo(
    id: 'museum_2',
    levelId: 'museum',
    title: 'RECLAMATION POLICY',
    author: 'SHIPPING SYSTEMS',
    body:
        'Anything thrown into a Reclamation Bin is copied to your Sandbox '
        'inventory permanently. The bins run forever, or until the nullmen '
        'decide they have feelings. Whichever comes first.',
  ),
  NoteInfo(
    id: 'museum_3',
    levelId: 'museum',
    title: 'STAFF ONLY',
    author: 'ARCHIVAL STAFF',
    body:
        'The panel on the second floor is not a load-bearing wall. It is '
        'not a wall at all, technically. Stop asking what is behind it. '
        'What is behind it is behind it.',
  ),

  // -- Streets ------------------------------------------------------------
  NoteInfo(
    id: 'streets_1',
    levelId: 'streets',
    title: 'LOCKDOWN BULLETIN',
    author: 'MYTHOS CITY ALERT',
    body:
        'ALL DISTRICTS: simulation lockdown in effect. Nullman work crews '
        'are unresponsive. Do not approach, do not engage, do not ask them '
        'about the void. Report to your nearest evacuation kiosk.',
  ),
  NoteInfo(
    id: 'streets_2',
    levelId: 'streets',
    title: 'MONOMAT MAINTENANCE',
    author: 'VENDOR TECH 12',
    body:
        'Unit 4 keeps dispensing an extra Apollo for free. Management says '
        'leave it, it improves morale. Tender is still magazines only. '
        'Stop shoving garbage in the slot.',
  ),
  NoteInfo(
    id: 'streets_3',
    levelId: 'streets',
    title: 're: ford',
    author: 'ALORA B.',
    body:
        'I traced the boot signature. Whoever froze the sim is still '
        'inside it, and they are walking around in your body, Arthur. '
        'We need to talk.',
  ),

  // -- Runoff -------------------------------------------------------------
  NoteInfo(
    id: 'runoff_1',
    levelId: 'runoff',
    title: 'DRAINAGE WORK ORDER',
    author: 'CIVIC MAINTENANCE',
    body:
        'Transit Station 5 runoff line is clogging again. Elevator '
        'pressure valve sticks. Send a null crew, they do not complain '
        'about the smell. They did not used to complain, anyway.',
  ),
  NoteInfo(
    id: 'runoff_2',
    levelId: 'runoff',
    title: 're: cleanup crew',
    author: 'HAYES M.',
    body:
        'Monogon sent the Omniprojectors in. They are not here to rescue '
        'anyone, Ford. They sweep, they sterilise, and you are on the '
        'list. Keep moving.',
  ),
  NoteInfo(
    id: 'runoff_3',
    levelId: 'runoff',
    title: 'DRAIN INCIDENT 12',
    author: 'CIVIC MAINTENANCE',
    body:
        'Worker reports "a sick coworker" shambling in the lower channel. '
        'Description matches employee Arthur Ford. Ford is accounted for '
        'at his desk. Ticket closed as a prank. Do not investigate.',
  ),

  // -- Sewers -------------------------------------------------------------
  NoteInfo(
    id: 'sewers_1',
    levelId: 'sewers',
    title: 'LIGHTING MEMO',
    author: 'CIVIC MAINTENANCE',
    body:
        'Half the tunnel lights below District 09 are dead and procurement '
        'is frozen. Crews are advised to bring personal flashlights and to '
        'stop writing about "whispering" in the incident reports.',
  ),
  NoteInfo(
    id: 'sewers_2',
    levelId: 'sewers',
    title: 'MELON GROWING ZONE',
    author: 'UNKNOWN',
    body:
        'the melons grow where the clock cannot see. the nullmen guard '
        'them now. take only what you can carry. do not look at the big '
        'one for too long',
  ),

  // -- Warehouse ----------------------------------------------------------
  NoteInfo(
    id: 'warehouse_1',
    levelId: 'warehouse',
    title: 'SHIPMENT 4B',
    author: 'SHIPPING SYSTEMS',
    body:
        'Container wall is over quota again. If the crane ghosts keep '
        'stacking overnight, that is fine, they are cheaper than the day '
        'shift. Report crablet infestations BEFORE they nest.',
  ),
  NoteInfo(
    id: 'warehouse_2',
    levelId: 'warehouse',
    title: 're: the window trick',
    author: 'MONOCHAT LOG',
    body:
        'DAVE: the glass on the mezzanine looks empty but it is solid. '
        'walked straight into it\n'
        'PETRA: did you shoot it first\n'
        'DAVE: why would I shoot a window\n'
        'PETRA: to see if it is a window, dave',
  ),
  NoteInfo(
    id: 'warehouse_3',
    levelId: 'warehouse',
    title: 'CRABLET MEMO',
    author: 'SHIFT LEAD',
    body:
        'The nest in 4B is past "report before they nest" territory. The '
        'big one threw a forklift at me. I am logging this from inside a '
        'shipping container. Send help or send a forklift back.',
  ),

  // -- Central Station ----------------------------------------------------
  NoteInfo(
    id: 'central_1',
    levelId: 'central_station',
    title: 'LINE CLOSURES',
    author: 'TRANSIT AUTHORITY',
    body:
        'Lines 2 and 7 are closed until the cleanup sweep ends. '
        'Maintenance tunnels remain open to staff. If a platform turret '
        'flags you, hold still and recite your employee number.',
  ),
  NoteInfo(
    id: 'central_2',
    levelId: 'central_station',
    title: 're: you',
    author: 'ALORA B.',
    body:
        'I know what you are doing, Ford. Immortality via void lattice. '
        'For the record I had the idea first. Keep the gateway open and '
        'I never saw you. Deal?',
  ),
  NoteInfo(
    id: 'central_3',
    levelId: 'central_station',
    title: 'TURRET CALIBRATION',
    author: 'TRANSIT AUTHORITY',
    body:
        'Platform turrets now default to LETHAL on unrecognised targets. '
        'Employees should carry badges visibly. If flagged anyway, '
        'apologise to the turret and move briskly out of its arc.',
  ),

  // -- Tower --------------------------------------------------------------
  NoteInfo(
    id: 'tower_1',
    levelId: 'tower',
    title: 'TENANT NOTICE',
    author: 'PLAZA MANAGEMENT',
    body:
        'The food court is closed, the cinema is closed, and whatever is '
        'fighting in the atrium between the zombies and the cleanup crew '
        'is NOT covered by building insurance. Keys are with floor '
        'wardens.',
  ),
  NoteInfo(
    id: 'tower_2',
    levelId: 'tower',
    title: 're: they found you',
    author: 'HAYES M.',
    body:
        'Ford. Monogon triangulated your rig. Real world. Agents are '
        'already moving on the server room. Whatever you are doing in '
        'there, do it faster.',
  ),

  // -- Time Tower ---------------------------------------------------------
  NoteInfo(
    id: 'time_tower_1',
    levelId: 'time_tower',
    title: 'SYSTEM CLOCK DOCTRINE',
    author: 'VOIDMIND OPS',
    body:
        'The System Clock keeps MythOS coherent. The Gravity Core keeps '
        'the Clock wound. If the cores ever disconnect, do NOT let four '
        'nullmen and a pyramid-shaped hole in reality handle the repair.',
  ),
  NoteInfo(
    id: 'time_tower_2',
    levelId: 'time_tower',
    title: 'FINAL MESSAGE',
    author: 'HAYES M.',
    body:
        'They are breaching your door. I am sorry, Ford. Whatever is on '
        'the other side of that clock, I hope it was worth it. Do not '
        'reply to this. Just go.',
  ),

  // -- Dungeon ------------------------------------------------------------
  NoteInfo(
    id: 'dungeon_1',
    levelId: 'dungeon',
    title: 'GAOLER\'S LEDGER',
    author: 'RIVERSIDE KEEPER',
    body:
        'New arrivals: one (1) Ford. Same as the other Fords. They all '
        'say they are the real one. They all mime each other now. It is '
        'deeply unsettling and I want a transfer.',
  ),
  NoteInfo(
    id: 'dungeon_2',
    levelId: 'dungeon',
    title: 'scratched into the wall',
    author: 'A FORD',
    body:
        'day ??? - the king keeps the good crown for himself. if a new '
        'ford falls in here tell him: the arena is rigged, hit the king, '
        'take the crown, get to chamber 02. dont trust the doors',
  ),

  // -- Arena --------------------------------------------------------------
  NoteInfo(
    id: 'arena_1',
    levelId: 'arena',
    title: 'PIT RULES',
    author: 'KING FORD',
    body:
        'RULE ONE: entertain the court. RULE TWO: the King decides when '
        'you are done. RULE THREE: there is no rule three, the King '
        'forgot to write one. FIGHT.',
  ),
  NoteInfo(
    id: 'arena_2',
    levelId: 'arena',
    title: 're: the crown',
    author: 'A FORD',
    body:
        'word of advice, new guy. the king does not care about the fight. '
        'he cares about the crown. want to skip the duel? take the hat. '
        'worked for the last three of us',
  ),

  // -- Throne Room --------------------------------------------------------
  NoteInfo(
    id: 'throne_1',
    levelId: 'throne_room',
    title: 'CORONATION MEMO',
    author: 'COURT SCRIBE',
    body:
        'By decree of King Ford: whoever beats the King gets the crown, '
        'the castle, the army of Fords and full responsibility for '
        'leading them into the void. No refunds on kingship.',
  ),
  NoteInfo(
    id: 'throne_2',
    levelId: 'throne_room',
    title: 're: goodbye',
    author: 'ALORA B.',
    body:
        'Last one, Ford. I held up my end - I never told them which room. '
        'They figured it out anyway. See you in the void. Try to leave '
        'the gateway intact.',
  ),
  NoteInfo(
    id: 'throne_3',
    levelId: 'throne_room',
    title: 'CHAMBER 02 MANIFEST',
    author: 'UNKNOWN',
    body:
        'One (1) panic room. One (1) security director, real-world issue. '
        'One (1) executive with a void for a face. Contents may settle '
        'during transit. This is not a warning. This is a record.',
  ),

  // -- Sandbox chain ------------------------------------------------------
  NoteInfo(
    id: 'basement_1',
    levelId: 'museum_basement',
    title: 'SANDBOX ORIENTATION',
    author: 'MUSEUM STAFF',
    body:
        'Everything you have reclaimed lives down here. Spawn it, stack '
        'it, break it. The gym shapes are indestructible. The interns '
        'are not.',
  ),
  NoteInfo(
    id: 'basement_2',
    levelId: 'museum_basement',
    title: 'PLAYROOM RULES',
    author: 'MUSEUM STAFF',
    body:
        'Red floor means playroom. Gym shapes go back on the rack when '
        'you are done. The test nullbody is allowed to stay mad. We '
        'earned it.',
  ),
  NoteInfo(
    id: 'redacted_1',
    levelId: 'redacted_chamber',
    title: '[REDACTED]',
    author: '[REDACTED]',
    body:
        'This chamber was cut for lacking "natural cohesion". The targets '
        'still want to be knocked down. The bulkhead still wants a '
        'battery. Some things survive the cut.',
  ),
  NoteInfo(
    id: 'redacted_2',
    levelId: 'redacted_chamber',
    title: 'TARGET PROTOCOL',
    author: 'RANGE OFFICER',
    body:
        'The three desk targets trip their lights when downed, but only '
        'the bulkhead cares if all three stay down AT ONCE. Weigh one '
        'down, stand on one, shoot one. You know the drill.',
  ),
  NoteInfo(
    id: 'redacted_3',
    levelId: 'redacted_chamber',
    title: 'RAIL SCHEDULE',
    author: 'CIVIC MAINTENANCE',
    body:
        'The ceiling crate ferries the battery between platforms on a '
        'valve pull. Knock the crate loose, take the battery, mind the '
        'crablets that nested in the corridor since the cut.',
  ),
  NoteInfo(
    id: 'range_1',
    levelId: 'handgun_range',
    title: 'RANGE SAFETY',
    author: 'RANGE OFFICER',
    body:
        'P350 course rules: muzzle down range, finger off the trigger '
        'until the timer starts, and no, you cannot take the gachapon '
        'targets home. They are reclaimed. You know the rules.',
  ),
  NoteInfo(
    id: 'range_2',
    levelId: 'handgun_range',
    title: 'COURSE RECORD',
    author: 'RANGE OFFICER',
    body:
        'Fastest clean run of the eight-target course: one of the Fords, '
        'who cheated by being in three places at once. Disqualified. '
        'Record stands at "good enough". The box at the end is yours.',
  ),
  NoteInfo(
    id: 'tuscany_1',
    levelId: 'tuscany',
    title: 'FIELD TRIP',
    author: 'DEV NOTE',
    body:
        'Someone ported a villa from the old devkit demos into the sim. '
        'Nobody claimed it. The wine is not real but the sunset almost '
        'is.',
  ),
  NoteInfo(
    id: 'tuscany_2',
    levelId: 'tuscany',
    title: 'GARDEN DUTY',
    author: 'GROUNDSKEEPER',
    body:
        'Terraces get watered, cellar stays locked, and if the melons '
        'start rolling downhill on their own, that is between them and '
        'the void. I do not get paid enough for sentient fruit.',
  ),
  NoteInfo(
    id: 'tuscany_3',
    levelId: 'tuscany',
    title: 'POSTCARD',
    author: 'A WANDERER',
    body:
        'wish you were here. the light through the pergola does something '
        'the renderer should not be able to do. staying one more cycle. '
        'do not tell monogon the gate is still warm',
  ),
  NoteInfo(
    id: 'zombiewarehouse_1',
    levelId: 'zombie_warehouse',
    title: 'LAST SHIFT',
    author: 'WAREHOUSE FOREMAN',
    body:
        'They keep coming through the dock doors. Board everything. Buy '
        'what you need from the Monomat, it still takes magazines. If '
        'anyone reads this: the boards were my idea. Tell my wife.',
  ),
  NoteInfo(
    id: 'zombiewarehouse_2',
    levelId: 'zombie_warehouse',
    title: 'ROUND LOG',
    author: 'LAST SURVIVOR',
    body:
        'Round 4 broke us. The throwers aimed for the boards, not us. '
        'They are learning. The big one in round 5 is worse. Board high, '
        'shoot first, keep the Monomat fed.',
  ),
  NoteInfo(
    id: 'blankbox_1',
    levelId: 'blankbox',
    title: 'EDGE CASES',
    author: 'QA INTERN',
    body:
        'This room exists for the things that broke every other room. '
        'If it compiles in here, it compiles anywhere. Please stop '
        'reporting the walls as a bug. The walls are the point.',
  ),
  NoteInfo(
    id: 'fantasyarena_1',
    levelId: 'fantasy_arena',
    title: 'PIT LEDGER',
    author: 'COURT SCRIBE',
    body:
        'The new king reopened the pit. Same rules, better seating. '
        'Fords fight, Fords cheer, one Ford somewhere is probably '
        'keeping score. The void above is very pretty tonight.',
  ),
  NoteInfo(
    id: 'fantasyarena_2',
    levelId: 'fantasy_arena',
    title: 'scratched under a seat',
    author: 'A FORD',
    body:
        'four rounds. that is the magic number. survive four and the '
        'pit lets you leave, nobody knows why. it is the arena now. '
        'the arena is the law',
  ),

  // -- Meta ---------------------------------------------------------------
  NoteInfo(
    id: 'menu_1',
    levelId: 'menu',
    title: 'EMPLOYEE HANDBOOK',
    author: 'MONOGON INDUSTRIES',
    body:
        'Congratulations on your position at the edge of reality. '
        'Remember: the Voidway is not a perk, immortality is not a '
        'benefit, and your employee badge does not work in Fantasy Land.',
  ),
];

NoteInfo? noteById(String id) {
  for (final note in kNotes) {
    if (note.id == id) return note;
  }
  return null;
}

List<NoteInfo> notesForLevel(String levelId) =>
    kNotes.where((n) => n.levelId == levelId).toList();

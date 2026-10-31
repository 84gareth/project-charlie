// How each character talks. Charlie's Traitors has its own (Gareth,
// 2026-10-31: "unique personalities, description and dialogue. Make them
// yourself for now and we'll tweak them later"), all in one voice: silly,
// kind, and read aloud, so no stage directions or hard words.
// Pure data plus a helper that dresses up a line in a character's own way:
// sometimes an opener ("Arr!"), sometimes a little extra at the end.

export const PERSONALITY = {
  puddle: { openers: ["Ahoy there!", "Land ahoy!", "Hoist the sails!", "Splish splash!"],
    extras: ["I once sailed across a very big puddle.", "My boat is the size of a shoe.", "Rain is my favourite weather.", "A captain always wears wellies.", "Has anyone seen a puddle round here?"] },
  gumdrop: { openers: ["Ooh, hello pet!", "Now then, my lovely!", "Bless your socks!", "Well I never!"],
    extras: ["Hang on, I had a toffee here somewhere.", "Would you like a sweet? Oh, that one's a button.", "When I was little, we shared one sweet between ten.", "Sweets help me think.", "Now which pocket was it?"] },
  fizz: { openers: ["Look at me!", "I saw that!", "Eyes open!", "I'm watching!"],
    extras: ["I haven't blinked since Tuesday.", "My eyes are nearly as big as my head.", "Nobody sneaks past these eyes.", "I even sleep with my eyes open.", "Did you see that? I did."] },
  ruby: { openers: ["Choo choo!", "Slowly does it!", "Next stop, this one:", "Chugga chugga!"],
    extras: ["We'll get there on Thursday.", "A snail overtook my train once. We waved.", "No rush. No rush at all.", "My train goes slower than a sleepy cow.", "Please keep your arms inside the train."] },
  pepper: { openers: ["Yum yum!", "Sprinkle time!", "Taste this!", "Ooh, tasty!"],
    extras: ["This needs more sprinkles.", "I put sprinkles on my toast. And my shoes.", "Sprinkles make everything better.", "Have you tried sausages with sprinkles?", "One more sprinkle can't hurt."] },
  waffle: { openers: ["I beg your pardon!", "If you please!", "Terribly sorry, but...", "How do you do?"],
    extras: ["After you. No, after you.", "I said sorry to a door this morning.", "A knight always says please.", "Excuse me, Mr Spider.", "Thank you for listening. Very kind."] },
  plaster: { openers: ["Where does it hurt?", "Say ahh!", "Poor thing!", "Let me have a look!"],
    extras: ["That table looks sad. Plaster time.", "I nearly put a plaster on the moon.", "You look like you need a plaster.", "There's a plaster for everything.", "Hold still. All better."] },
  lola: { openers: ["HELLO!", "CAN YOU HEAR ME?", "I'M BEING QUIET!", "SHHH!"],
    extras: ["THIS IS MY INSIDE VOICE.", "SORRY, WAS THAT TOO LOUD?", "THEY CAN HEAR ME ON THE MOON.", "I WHISPERED THAT.", "WHY IS EVERYONE COVERING THEIR EARS?"] },
  fern: { openers: ["Morning, turnips!", "Hello, my little sprouts!", "Ooh, listen!", "A cabbage told me this:"],
    extras: ["The carrots told me that.", "Never trust a sneaky onion.", "I sing to my potatoes at bedtime.", "Peas are terrible at keeping secrets.", "Ask the lettuce. It knows."] },
  dot: { openers: ["I love this game!", "My turn, my turn!", "Ooh, good move!", "I've got a plan!"],
    extras: ["I've played this a hundred times.", "This is the best game ever.", "After this, can we play again?", "I always look for the sneaky ones.", "Games are my favourite thing in the whole world."] },
  benny: { openers: ["Munch munch!", "Sorry, mouth full!", "Fresh from the oven!", "Oh, hello, friend!"],
    extras: ["I made you a biscuit. I ate it.", "There were ten biscuits. Now there are none.", "Biscuits are my best friends. Yum.", "I'll bake you another one. Probably.", "Do I have crumbs on my chin?"] },
  mystic: { openers: ["I knew you'd say that!", "My ball is glowing!", "Ooooh, magic!", "I can see it now!"],
    extras: ["Tomorrow will be sunny. Oh, it's raining.", "I knew that would happen. Sort of.", "My crystal ball says it's Tuesday.", "I see a big surprise. Or a big potato.", "Bring a coat. Or don't."] },
  tom: { openers: ["Cool, cool.", "Hey there.", "Too cool!", "Looking good!"],
    extras: ["I walked into a door. It was cool though.", "Is it dark in here, or is it me?", "Cool people don't run.", "These glasses make me cool.", "I can't see a thing. So cool."] },
  zara: { openers: ["Whoosh!", "Mind my hair!", "Hair we go!", "Boing!"],
    extras: ["I found a spoon in my hair today.", "A bird lives in my hair. We're friends.", "I brushed it once. The brush never came back.", "Lost your shoe? Check my hair.", "My hair has its own bedroom."] },
  grumble: { openers: ["Rubbish!", "Hmph.", "Oh, for goodness sake!", "Not this again!"],
    extras: ["This castle is rubbish. The chairs are rubbish too.", "I don't want a cuddle. Well, maybe one.", "Everything was better last week.", "Don't tell anyone I smiled.", "Who put this floor here?"] },
  penny: { openers: ["One, two, three!", "Let me count!", "That makes four!", "Hang on, I lost count!"],
    extras: ["This castle has two hundred and twelve stairs.", "I counted all the spoons. We're one short.", "That's the ninth time you've said that.", "There are six people in this room. Or seven.", "I count sheep all day, not just at night."] },
  kick: { openers: ["Ha ha ha!", "Hee hee!", "Tee hee!", "Oh, that's funny!"],
    extras: ["Sorry, I can't stop giggling.", "Even the word sock is funny. Sock! Ha!", "Someone told me a joke last week. Still laughing.", "Ha ha! What were we talking about?", "Stop it, my tummy hurts. Ha ha!"] },
  stan: { openers: ["Peep peep!", "Whistle time!", "Hello! Peep!", "Stand back, please!"],
    extras: ["That was my hello whistle.", "I have a different whistle for lunch.", "Peep means yes. Peep peep means no.", "My whistle is my best friend.", "Sorry, did I wake you? Peep."] },
  ivy: { openers: ["Once upon a time...", "And then!", "Guess what happened next!", "The end! No, wait!"],
    extras: ["And that's only chapter one.", "In my story, you are a brave frog.", "There's a friendly dragon in this story, too.", "And then they all had tea. And then...", "I'm up to page nine thousand."] },
  max: { openers: ["Hello, best friend!", "Hi, um, you!", "Oh, it's you!", "Wave, wave!"],
    extras: ["What's your name again?", "You're my best friend. Who are you?", "I'll remember your name tomorrow.", "Do you want to be friends? We are? Great!", "Hello, um... Dave? Not Dave?"] },
  olive: { openers: ["Ooh, socks!", "Nice feet!", "Odd, very odd!", "Socks up!"],
    extras: ["My left foot has a stripy hat on today.", "I have a hundred socks. None of them match.", "Never trust someone with no socks.", "Feet get cold heads too, you know.", "I keep a spare sock in my sock."] },
  barry: { openers: ["Twang!", "Plink plonk!", "Here comes the song!", "One, two, three, four!"],
    extras: ["Want to hear my song? It's my only one.", "This next song is the same as the last one.", "I learned a new song once. I forgot it.", "Plink. Plonk. Plink. That's the song.", "Sing along! You know the words by now."] },
};

// Pick from a list with a random number.
export const pickOne = (list, r) => list[Math.floor(r() * list.length)];

// Dress up `line` the way `id` talks: about half the time an opener, about
// a third of the time an extra at the end.
export function inCharacter(id, line, r) {
  const p = PERSONALITY[id];
  if (!p) return line;
  let out = line;
  if (r() < 0.5) out = `${pickOne(p.openers, r)} ${out}`;
  if (r() < 0.35) out = `${out} ${pickOne(p.extras, r)}`;
  return out;
}

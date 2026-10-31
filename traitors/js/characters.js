// The 22 characters, from Project Sam (Sam approved them on 2026-10-24)
// (docs/characters.md). Pure data: no page code.
// `picture`: assets/characters/<id>.jpg. In Charlie's Traitors these start
// as made-up placeholders (tools/placeholders/), replaced by Charlie's own
// drawings as he does them (docs/characters.md).
// Without one, the game shows a coloured circle with their initials.

export const CHARACTERS = [
  { id: "puddle", name: "Captain Puddle", about: "Sails a tiny boat in puddles. Thinks every puddle is the sea.", colour: "#2f6fb3",
    picture: "assets/characters/puddle.jpg" },
  { id: "gumdrop", name: "Granny Gumdrop", about: "Keeps a sweet in every pocket, but forgets which pocket.", colour: "#d4548e",
    picture: "assets/characters/gumdrop.jpg" },
  { id: "fizz", name: "Zeer", about: "Has the biggest eyes in the castle, and never ever blinks.", colour: "#7a4fc9",
    picture: "assets/characters/fizz.jpg" },
  { id: "ruby", name: "Ruby Rails", about: "Drives the slowest train ever. Says it's never late.", colour: "#c0392b",
    picture: "assets/characters/ruby.jpg" },
  { id: "pepper", name: "Chef Pepper", about: "A chef who puts sprinkles on everything. Even soup.", colour: "#e67e22",
    picture: "assets/characters/pepper.jpg" },
  { id: "waffle", name: "Sir Reginald Waffle", about: "A very polite knight who says sorry to spiders.", colour: "#7f8c8d",
    picture: "assets/characters/waffle.jpg" },
  { id: "plaster", name: "Doctor Plaster", about: "Puts a plaster on anything that looks sad. Even chairs.", colour: "#16a085",
    picture: "assets/characters/plaster.jpg" },
  { id: "lola", name: "Lola Loud", about: "Thinks shouting is whispering. It is very, very loud.", colour: "#e84393",
    picture: "assets/characters/lola.jpg" },
  { id: "fern", name: "Farmer Fern", about: "Talks to the vegetables. Says the carrots tell secrets.", colour: "#3f8f3a",
    picture: "assets/characters/fern.jpg" },
  { id: "dot", name: "Zoe", about: "Likes playing games like Traitors!", colour: "#6f55b5",
    picture: "assets/characters/dot.jpg" },
  { id: "benny", name: "Benny Biscuit", about: "Bakes a biscuit for every friend, then eats them all.", colour: "#b9770e",
    picture: "assets/characters/benny.jpg" },
  { id: "mystic", name: "Madame Mystic", about: "Can see the future, but always gets the weather wrong.", colour: "#6c3483",
    picture: "assets/characters/mystic.jpg" },
  { id: "tom", name: "Tendo", about: "Wears sunglasses indoors, and thinks that is very cool.", colour: "#1abc9c",
    picture: "assets/characters/tom.jpg" },
  { id: "zara", name: "Zeebee", about: "Has the wildest hair in the castle. Things get lost in it.", colour: "#f1c40f",
    picture: "assets/characters/zara.jpg" },
  { id: "grumble", name: "Mr Grumble", about: "Says everything is rubbish. Secretly loves a cuddle.", colour: "#5d6d7e",
    picture: "assets/characters/grumble.jpg" },
  { id: "penny", name: "Penny Pockets", about: "Counts everything. Knows how many stairs the castle has.", colour: "#d4ac0d",
    picture: "assets/characters/penny.jpg" },
  { id: "kick", name: "Coby", about: "Laughs at everything. Even when nothing is funny.", colour: "#27ae60",
    picture: "assets/characters/kick.jpg" },
  { id: "stan", name: "Stationmaster Stan", about: "Blows a whistle to say hello. And goodbye. And everything.", colour: "#1f3a5f",
    picture: "assets/characters/stan.jpg" },
  { id: "ivy", name: "Ivy Inkwell", about: "Turns everything into a story. The stories never end.", colour: "#2e86c1",
    picture: "assets/characters/ivy.jpg" },
  { id: "max", name: "Max", about: "Wants to be everyone's best friend, but forgets their names.", colour: "#3b82c4",
    picture: "assets/characters/max.jpg" },
  { id: "olive", name: "Olive Oddsocks", about: "Thinks socks are tiny hats for feet. Owns one hundred.", colour: "#808b38",
    picture: "assets/characters/olive.jpg" },
  { id: "barry", name: "Barry Banjo", about: "Only knows one song. Plays it all day, every day.", colour: "#ca6f1e",
    picture: "assets/characters/barry.jpg" },
];

// "Chef Pepper" -> "CP"; one-word names give one letter.
export function initials(name) {
  return name.split(" ").filter((w) => w.length > 0).map((w) => w[0]).join("").slice(0, 2);
}

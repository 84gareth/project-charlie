// Sizes of the city street, in world units (the Godot game's pixels). The
// street is three Godot screens (1600 wide) long and 900 tall; the iPad
// shows a 4:3 slice of it that slides along with the hero.

export const WORLD_WIDTH = 4800;
export const WORLD_HEIGHT = 900;

// Where the buildings stop and the pavement starts.
export const PAVEMENT_TOP = 560;
// Where the pavement stops and the road starts.
export const ROAD_TOP = 720;

// Where feet may go: the pavement and the road.
export const WALK_AREA = { x: 80, y: 600, w: WORLD_WIDTH - 160, h: 270 };

export const HERO_START = { x: 420, y: 730 };

// The view always shows the whole street top to bottom, and at least this
// much of it left to right; a wide screen sees more, never less.
export const VIEW_MIN_WIDTH = 1200;

export const clamp = (v, lo, hi) => Math.min(hi, Math.max(lo, v));

// A point kept inside an area {x, y, w, h}.
export function keepIn(p, area) {
  return { x: clamp(p.x, area.x, area.x + area.w), y: clamp(p.y, area.y, area.y + area.h) };
}

// How to fit the world on a screen of w x h: the scale (screen px per world
// unit), how much street shows across, and the gap above and below when
// the screen is taller than the street.
export function view(w, h) {
  const scale = Math.min(h / WORLD_HEIGHT, w / VIEW_MIN_WIDTH);
  return { scale, width: w / scale, top: (h - WORLD_HEIGHT * scale) / 2 };
}

// Where the camera's left edge goes: the hero in the middle, never past
// either end of the street.
export function cameraX(heroX, viewWidth) {
  return clamp(heroX - viewWidth / 2, 0, Math.max(0, WORLD_WIDTH - viewWidth));
}

#!/usr/bin/env bash
# Puts Charlie's drawings into Charlie's Traitors: cuts each photo out of
# its paper and makes the puppet (320 tall) and card (440 x 700). Each line
# holds the outline of the paper in that photo. Add a line for each new one:
#   character <photo in drawings/> <id in characters.js> <cutout.gd options>
set -euo pipefail
cd "$(dirname "$0")/../.."
GODOT="${GODOT:-$HOME/Downloads/Godot.app/Contents/MacOS/Godot}"
TMP="$(mktemp -d)"
run() { "$GODOT" --headless --path tools/image-fix --script "res://$1.gd" -- "${@:2}" >/dev/null 2>&1; }
cut() { run cutout "$PWD/drawings/traitors_$1.jpg" "$2" "${@:3}"; }
character() {
  local photo="$1" id="$2"; shift 2
  cut "$photo" "$TMP/$id.png" "$@" height=700
  run card "$TMP/$id.png" "$PWD/traitors/assets/characters/$id.jpg"
  cut "$photo" "$PWD/traitors/assets/puppets/$id.png" "$@" height=320
  echo "$photo -> $id"
}
character zoe dot "keep=775,468;1098,455;1098,735;1082,905;985,962;672,982;652,640;685,508"
character max max "keep=800,728;870,730;940,775;1030,960;990,1055;900,1120;820,1112;780,1060;775,960;738,930;738,860;770,820;790,760" "erase=770,1020;797,1020;797,1060;770,1060"
character zeebee zara "keep=592,672;800,662;935,662;984,682;958,900;922,1172;502,1172;448,895;492,800" "erase=480,1125;590,1125;590,1172;480,1172" "erase=795,1125;930,1125;930,1172;795,1172" sat=0.2
character coby kick "keep=664,860;988,908;996,928;958,1090;858,1178;742,1188;642,1124;656,1000" sat=0.15
character zeer fizz "keep=970,832;1010,1085;990,1170;890,1280;800,1010;765,832" sat=0.15
character tendo tom "keep=578,700;650,708;788,776;763,900;773,1040;675,1083;590,1040;570,1000;572,850;572,780" sat=0.15
cut dagger "$PWD/traitors/assets/dagger.png" "keep=592,560;838,570;833,870;883,1100;798,1326;735,1318;680,1240;640,1120;547,1010;542,950;582,850" height=240
cut shield "$PWD/traitors/assets/shield.png" "keep=627,804;856,812;893,960;886,1010;808,1173;752,1158;692,1060;637,850" height=240
# The castle: a whole page photographed at an angle.
run straighten "$PWD/drawings/traitors_castle.jpg" "$PWD/traitors/assets/castle.jpg" 1376 973 470,285 1833,350 1820,1358 240,1215
run icon "$PWD/traitors/assets/castle.jpg" "$PWD/traitors/assets/icons/apple-touch-icon.png"
echo done

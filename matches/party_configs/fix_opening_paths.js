const fs = require("fs")
const path = require("path")

const topStart = [14, 3]
const bottomStart = [14, 4]

const tupleToVector2 = (tuple) => {
  return `Vector2(${tuple[0]}, ${tuple[1]})`;
}

function main() {
  const file = fs.readFileSync(
    path.resolve(
      __dirname,
      "./computer_party_config_raw.tres"
    ),
    "utf-8"
  );

  const lines = file.split("\n");

  const fixedLines = lines.map((line, i) => {
    if (line.startsWith("opening_grid_path")) {
      const capture = line.match(/Vector2\((?<x>-?\d*), (?<y>-?\d*)\)/)
      const x = parseInt(capture.groups.x);
      const y = parseInt(capture.groups.y);

      if (x === 6) {
        // we're looking at pawns
        const positions = [
          capture[0]
        ]
        if (y < 4) {
          // top half of the board
          const intermediatePosition = [6, 3];
          positions.unshift(tupleToVector2(intermediatePosition));
          const startX = topStart[0] + y
          const startPosition = [
            startX,
            topStart[1]
          ]
          positions.unshift(tupleToVector2(startPosition));
        } else {
          // bottom half of the board
          const intermediatePosition = [6, 4];
          positions.unshift(tupleToVector2(intermediatePosition));
          const startX = bottomStart[0] + 3 - (y % 4);
          const startPosition = [
            startX,
            bottomStart[1]
          ]
          positions.unshift(tupleToVector2(startPosition));
        }
        const fixed = line.replace(capture[0], positions.join(", "))
        return fixed
      } else {
        const capture = line.match(/Vector2\((?<x>-?\d*), (?<y>-?\d*)\)/)

        const positions = [
          capture[0]
        ];

        if (y < 4) {
          // top half of the board
          const intermediatePosition = [7, 3];
          positions.unshift(tupleToVector2(intermediatePosition));
          const startX = topStart[0] + y + 4
          const startPosition = [
            startX,
            topStart[1]
          ]
          positions.unshift(tupleToVector2(startPosition));

        } else {
          const intermediatePosition = [7, 4];
          positions.unshift(tupleToVector2(intermediatePosition));
          const startX = bottomStart[0] + 3 - (y % 4) + 4;
          const startPosition = [
            startX,
            bottomStart[1]
          ]
          positions.unshift(tupleToVector2(startPosition));
        }

        const fixed = line.replace(capture[0], positions.join(", "))

        return fixed
        // we're looking at everything else
      }
      return "";
    } else {
      return line;
    }
  });
  console.log(fixedLines)
  fs.writeFileSync(
    path.resolve(
      __dirname,
      "./computer_party_config.tres"
    ),
    fixedLines.join("\n")
  )
}

main();


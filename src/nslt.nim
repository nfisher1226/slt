import math, parseopt, strformat
from strutils import parsefloat

var length,depth: float64 = 16.0
var offset: float64 = 0.0
var xflag = false

proc compute_sine(index: float64): int64 =
  let hypotenuse = (depth - 1) / 2
  let radsPerIndex = (2 * PI) / length
  let rads = index * radsPerIndex
  let value = (sin(rads) * hypotenuse) + hypotenuse
  return int(round(value, 0))

proc main() =
  for kind, key, val in getopt():
    case kind:
    of cmdEnd: doAssert(false)
    of cmdShortOption, cmdLongOption:
      case key
      of "l", "length":
        length = parsefloat(val)
      of "d", "depth":
        depth = parsefloat(val)
      of "o", "offset":
        offset = parsefloat(val)
      of "x", "hex":
        if val == "":
          xflag = true
        else:
          echo "slt: invalid parameter for ", key, " -- '", val, "'"
          quit()
      else:
        echo "slt: invalid option -- '", key, "'"
        quit()
    of cmdArgument:
      echo "slt: invalid flag --'", key, "'"

  stdout.write "\n{"
  for i in 0 ..< int(length):
    if (i mod 12 == 0):
      stdout.write "\n    "
    let entry = compute_sine(float(i))
    if (xflag):
      stdout.write fmt"{entry:#X}"
    else:
      stdout.write entry
    if (i < int(length) - 1):
      stdout.write ", "
  echo "\n};"

when isMainModule:
  main()

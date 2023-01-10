import illwill
#langs 
const langs = ["Nim", "Go", "Python", "C++", "D", "Haxe", "Odin", "Rust"]
var index = 1 #index to choose lang

#exit proc when doing ctrl+c
proc exit() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

#frame update to update prompt
proc update(buf: var TerminalBuffer) =
  buf.clear()
  buf.setForegroundColor(fgWhite, true)
  buf.drawRect(0, 0, 53, 35, false)
  buf.write(1, 0, "Use the Up and Down keys to change your selection.")
  for i, v in langs:
    if i == index - 1:
      buf.setForegroundColor(fgCyan)
      if i == 0:
        buf.write(2,  3, "> " & v & " <")
      else:
        buf.write(2, 3 + 2 * i, "> " & v & " <")
    else:
      buf.setForegroundColor(fgYellow)
      if i == 0:
        buf.write(2,  3, v)
      else:
        buf.write(2, 3 + 2 * i, v)
      #buf.write(2, 3 + 2 * i, v)

#init before doing anything
proc init(): TerminalBuffer =
  illwillInit(true, false)
  setControlCHook(exit)
  hideCursor()
  return newTerminalBuffer(terminalWidth(), terminalHeight())

#main process
proc main(buf: var TerminalBuffer) =
  buf.setForegroundColor(fgWhite, true)
  #buf.setBackgroundColor(bgBlack)
  #buf.drawRect(0, 0, 53, 35, false)
  #buf.write(1, 0, "Use the Up and Down keys to change your selection.")
  update(buf)

var buffer = init()
main(buffer)

#main loop for managing input and updates
while true:
  var key = getKey()

  case key:
  of Key.Up:
    if index != 1:
      index -= 1
    else:
      index = langs.len
    echo index
  of Key.Down:
    if index != langs.len:
      index += 1
    else:
      index = 1
    echo index
  else:
    discard

  update(buffer)
  buffer.display()
import illwill
#langs 
#const langs = ["Nim", "Go", "Python", "C++", "D", "Haxe", "Odin", "Rust", "NodeJS"]
var index = 1 #index to choose lang
var choosing = true
#exit proc when doing ctrl+c
proc forceExit() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

#exit proc after enter
proc exit() =
  illwillDeinit()
  showCursor()

#frame update to update prompt
proc update(buf: var TerminalBuffer, q: string, opt: seq[string]) =
  #resets the tui and redraws the rect
  buf.clear()
  buf.setForegroundColor(fgGreen, true)
  #draw the question
  buf.write(3, 2, q)
  buf.setForegroundColor(fgWhite, true)
  #draw rect and tip
  buf.drawRect(0, 0, 53, 30, false)
  buf.write(1, 0, "Use the Up and Down keys to change your selection.")
  #redraws the selections and options
  for i, v in opt:
    if i == index - 1:
      buf.setForegroundColor(fgCyan)
      buf.write(2, if i == 0: 4 else: 4 + 2 * i, "> " & v & " <")
    else:
      buf.setForegroundColor(fgYellow)
      buf.write(2, if i == 0: 4 else: 4 + 2 * i, v)
      #buf.write(2, 3 + 2 * i, v)

#init before doing anything
proc init(): TerminalBuffer =
  illwillInit(false, false)
  setControlCHook(forceExit)
  hideCursor()
  var buf = newTerminalBuffer(terminalWidth(), terminalHeight())
  buf.setForegroundColor(fgWhite, true)
  return buf

proc prompt*(q: string, options: seq[string]): string =
  var buffer = init()
  update(buffer, q, options)

  #main loop for managing input and updates
  while choosing:
    buffer = newTerminalBuffer(terminalWidth(), terminalHeight())
    var key = getKey()

    case key:
    of Key.Up:
      if index != 1:
        index -= 1
      else:
        index = options.len
      echo index
    of Key.Down, Key.Tab:
      if index != options.len:
        index += 1
      else:
        index = 1
      echo index
    of Key.Enter:
      choosing = false
    else:
      discard

    buffer.update(q, options)
    buffer.display()
  exit()
  echo "\n"
  return options[index-1]
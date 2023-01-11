import prompt, download
import strutils, os
from illwill import illwillInit

const langs = @["Nim", "Haxe", "Odin", "D", "Rust", "C", "C++", "NodeJS", "Go", "Python"]
const singular = @["Nim", "Haxe", "Odin", "Rust", "NodeJS", "Go"]

proc install() =
    var resp = prompt("What language toolchain would you like to install?", langs)

    if resp in singular:
        download(resp, true)
        echo "singular"

proc uninstall() =
    var resp = prompt("What language toolchain would you like to uninstall?", langs)
    var cwd = getCurrentDir()
    setCurrentDir(getHomeDir() / ".local/bin")
    for f in walkDir("."):
        if f.kind != pcLinkToFile:
            return
        var file = f.path.splitPath().tail
        var info = file.expandSymlink()
        if ".local/share/coopy" / resp in info:
            removeFile(file)
    setCurrentDir(getHomeDir() / ".local/share/coopy")
    removeDir(resp)
    setCurrentDir(cwd)

illwillInit(false, false)
#TODO 2 figure out how to move to next prompt and fix uninstall
var resp = prompt("What action would you like to do?", @["Install language", "Uninstall language", "Update language", "Exit"]).toLower()

if resp == "install language":
    install()
elif resp == "uninstall language":
    uninstall()
elif resp == "update language":
    echo "not yet young padawan"
    quit(0)
else:
    echo "Exiting."
    quit(0)
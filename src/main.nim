import prompt, download
import strutils, os
from illwill import illwillInit

const langs = @["Nim", "Haxe", "Odin", "D", "Rust", "C", "C++", "NodeJS", "Go", "Python"]
const singular = @["Nim", "Haxe", "Odin", "Rust", "NodeJS", "Go"]

proc install() =
    var resp = prompt("What language toolchain would you like to install?", langs)
    for f in walkDir(getHomeDir() / ".local/share/coopy"):
        if f.path.splitPath().tail == resp:
            echo resp & " is already installed."
            quit(0)

    if resp in singular:
        download(resp, true)

proc uninstall() =
    var resp = prompt("What language toolchain would you like to uninstall?", langs)
    let bin = getHomeDir() / ".local/bin"
    let share = getHomeDir() / ".local/share/coopy"
    for f in walkDir(bin):
        if f.kind != pcLinkToFile:
            continue
        var info = f.path.expandSymlink()
        if share / resp in info:
            removeFile(f.path) #TODO 2 doesnt remove haxe symlinks

    removeDir(share / resp)
    echo "Uninstalled " & resp

var resp = prompt("What action would you like to do?", @["Install language", "Uninstall language", "Update language", "Exit"]).toLower()

if resp == "install language":
    install()
elif resp == "uninstall language":
    uninstall()
elif resp == "update language":
    echo "not yet young padawan"
    quit()
else:
    echo "Exiting."
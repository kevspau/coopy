import prompt, download
import strutils, os
from illwill import illwillInit

const langs = @["Nim", "Haxe", "Odin", "D", "LLVM", "Go"]

proc install(l = "") =
    var resp = if (l == ""): prompt("What language toolchain would you like to install?", langs) else: l
    for f in walkDir(getHomeDir() / ".local/share/coopy"): #checks if directory already exists
        if f.path.splitPath().tail == resp:
            echo resp & " is already installed."
            quit(0)

    if resp in langs:
        download(resp, true)

proc uninstall(l = "") =
    var resp = if (l == ""):  prompt("What language toolchain would you like to uninstall?", langs) else: l

    let bin = getHomeDir() / ".local/bin"
    let langDir = getHomeDir() / ".local/share/coopy" / resp
    for f in walkDir(bin):
        if f.kind != pcLinkToFile:
            continue
        var info = f.path.expandSymlink()
        if langDir in info: #info should be a file in the directory or a subdirectory
            removeFile(f.path)

    removeDir(langDir)
    echo "Uninstalled " & resp

proc update() = #lazy update
    var resp = prompt("What language toolchain would you like to update?", langs)
    uninstall(resp)
    install(resp)
    echo "updated " & resp
    

var resp = prompt("What action would you like to do?", @["Install language", "Uninstall language", "Update language", "Exit"]).toLower()

if resp == "install language":
    install()
elif resp == "uninstall language":
    uninstall()
elif resp == "update language":
    update()
else:
    echo "Exiting"
    quit(0)
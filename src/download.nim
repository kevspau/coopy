import httpclient, strutils, os, tables, osproc
import spinny

const links = {"nim": "https://nim-lang.org/download/nim-1.6.10-linux_x64.tar.xz", "haxe": "https://github.com/HaxeFoundation/haxe/releases/download/4.2.5/haxe-4.2.5-linux64.tar.gz", "odin": "https://github.com/odin-lang/Odin/releases/download/dev-2022-12/odin-ubuntu-amd64-dev-2022-12.zip", "rust": "https://static.rust-lang.org/dist/rust-1.66.0-aarch64-unknown-linux-gnu.tar.gz", "nodejs": "https://nodejs.org/dist/v19.4.0/node-v19.4.0-linux-x64.tar.xz", "go": "https://go.dev/dl/go1.19.5.linux-amd64.tar.gz"}.toTable()
let bin = getHomeDir() / ".local/bin"
let share = getHomeDir() / ".local/share/coopy"

proc download*(lang: string, singlesrc: bool) =
    var client = newHttpClient()
    var l: string
    if singlesrc:
        l = links[lang.toLower()]
    var name = l.splitPath().tail
    createDir(getAppDir() / "temp")
    let temp = getAppDir() / "temp"

    var dlSpin = newSpinny("Downloading " & lang, skDots)
    dlSpin.start()

    client.downloadFile(l, "temp" / name)
    dlSpin.success("Successfully downloaded.")
    let cwd = getCurrentDir()
    let ext = name.splitFile().ext
    let cmd = if ext == ".zip": "unzip " else: "tar -xf "
    var filename = ""

    var extSpin = newSpinny("Extracting and installing", skDots)
    extSpin.start()

    setCurrentDir(temp)
    discard execCmd(cmd & name) #runs uncompress with system exes 
    setCurrentDir(cwd)

    for f in walkDir(temp):#checks for the decompressed dir and give the dir name
        if f.kind == pcDir and lang.toLowerAscii() in f.path.splitPath().tail.toLowerAscii():
            filename = f.path.splitPath().tail
            break
    
    copyDirWithPermissions(temp / filename, share / lang)
    removeDir(temp)

    #[var founddir = false
    var dir = share / lang / "bin"
    for f in walkDirRec(share / lang):
        if f.getFileInfo().kind == pcDir and f.splitPath().tail.toLowerAscii() == "bin":
            founddir = true
            dir = f]#
    #adds sumlinks
    var langBin = ""
    for f in walkDirRec(share / lang):
        if f.splitPath().tail.toLower() == "bin" and f.getFileInfo().kind == pcDir:
            langBin = f #!fails for some reason, check out
            break
    echo langBin
    #TODO do recursive search for bin/ dir because langs like rust have multiple
    if langBin != "":# checks if bin exists, makes symlinks for files in bin/ or base dir if bin/ doesnt exist
        for f in walkDirRec(langBin):
            if f.getFileInfo().kind != pcDir:#makes sure the exe isnt a folder
                echo f
                f.createSymlink(bin / f.splitPath().tail)
    else:
        for f in walkDir(share / lang): #every executable in base dir
            if fpUserExec in getFilePermissions(share / lang / f.path.splitPath().tail) and f.path.getFileInfo().kind != pcDir: #if its an executable
                f.path.createSymlink(bin / f.path.splitPath().tail)
            if f.path.splitFile().ext == ext: #makes sure the tarball/zip/etc isnt in the file
                removeFile(f.path)
    extSpin.success("Successfully installed.")
    return
    

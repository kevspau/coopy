import httpclient, strutils, os, tables, osproc
import spinny

const links = {"nim": "https://nim-lang.org/download/nim-1.6.10-linux_x64.tar.xz", "haxe": "https://github.com/HaxeFoundation/haxe/releases/download/4.2.5/haxe-4.2.5-linux64.tar.gz", "odin": "https://github.com/odin-lang/Odin/releases/download/dev-2022-12/odin-ubuntu-amd64-dev-2022-12.zip", "d": "https://github.com/ldc-developers/ldc/releases/download/v1.31.0/ldc2-1.31.0-linux-x86_64.tar.xz", "llvm": "https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.7/clang+llvm-15.0.7-powerpc64le-linux-ubuntu-18.04.tar.xz", "nodejs": "https://nodejs.org/dist/v19.4.0/node-v19.4.0-linux-x64.tar.xz", "go": "https://go.dev/dl/go1.19.5.linux-amd64.tar.gz"}.toTable()
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
    #adds symlinks
    var foundBin = false
    for f in walkDir(share / lang):
        var dir = f.path;
        if dir.splitPath().tail.toLower() == "bin" and f.kind == pcDir:
            for ff in walkDir(dir):
                let v = ff.path;
                if ff.kind == pcFile and fpUserExec in v.getFilePermissions():
                    v.createSymlink(bin / v.splitPath().tail)
                    echo "symlink made for " & v
            foundBin = true

    if not foundBin:
        for f in walkDir(share / lang): #every executable in base dir
            if fpUserExec in getFilePermissions(share / lang / f.path.splitPath().tail) and f.path.getFileInfo().kind != pcDir: #if its an executable
                f.path.createSymlink(bin / f.path.splitPath().tail)
            if f.path.splitFile().ext == ext: #makes sure the tarball/zip/etc isnt in the file
                removeFile(f.path)
    extSpin.success("Successfully installed.")
    return
    

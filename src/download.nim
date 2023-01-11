import httpclient, strutils, os, tables, osproc, strformat


const links = {"nim": "https://nim-lang.org/download/nim-1.6.10-linux_x64.tar.xz", "haxe": "https://haxe.org/download/file/4.2.5/haxe-4.2.5-linux64.tar.gz", "odin": "https://github.com/odin-lang/Odin/releases/download/dev-2022-12/odin-ubuntu-amd64-dev-2022-12.zip", "rust": "https://static.rust-lang.org/dist/rust-1.66.0-aarch64-unknown-linux-gnu.tar.gz", "nodejs": "https://nodejs.org/dist/v19.4.0/node-v19.4.0-linux-x64.tar.xz", "go": "https://go.dev/dl/go1.19.5.linux-amd64.tar.gz"}.toTable()


proc download*(lang: string, singlesrc: bool) =
    var client = newHttpClient()
    var l: string
    if singlesrc:
        l = links[lang.toLower()]
    var name = l.splitPath().tail
    createDir(getAppDir() / "temp")
    client.downloadFile(l, "temp" / name)

    var cwd = getCurrentDir()
    var ext = name.splitFile().ext
    var cmd: string

    setCurrentDir(getAppDir() / "temp")
    if ext == ".zip":
        cmd = "unzip "
    else:
        cmd = "tar -xf "
    discard execCmd(cmd & name)
    #TODO rename folder and move it to .local/share, then make symlinks from bin to .local/bin
    

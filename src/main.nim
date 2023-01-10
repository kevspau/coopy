import prompt, download
import strutils

const langs = @["Nim", "Haxe", "Odin", "D", "Rust", "C", "C++", "NodeJS", "Go", "Python"]
const singular = @["Nim", "Haxe", "Odin", "Rust", "NodeJS", "Go"]

var resp = prompt("What language toolchain would you like to update?", langs)

if resp in singular:
    #download(resp, true)
    echo "sinuglar"
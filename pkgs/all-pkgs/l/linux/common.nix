{ stdenv }:
let
  inherit (stdenv.lib)
    head;
in
{
  kernelArch = with stdenv.lib.platforms;
    if stdenv.targetSystem == head x86_64-linux then
      "x86_64"
    else if stdenv.targetSystem == head i686-linux then
      "i386"
    else
      throw "Could not detect the kernel arch.";
}

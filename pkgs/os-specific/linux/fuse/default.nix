{ stdenv, fetchurl, utillinux }:

stdenv.mkDerivation rec {
  name = "fuse-2.9.4";
  
  builder = ./builder.sh;
  
  src = fetchurl {
    url = "https://github.com/libfuse/libfuse/releases/download/${stdenv.lib.replaceStrings ["-" "."] ["_" "_"] name}/${name}.tar.gz";
    sha256 = "1qbwp63a2bp0bchabkwiyzszi9x5krlk2pwk2is6g35gyszw1sbb";
  };
  
  configureFlags = "--disable-kernel-module";
  
  buildInputs = [ utillinux ];
  
  inherit utillinux;

  meta = with stdenv.lib; {
    homepage = http://fuse.sourceforge.net/;
    description = "Kernel module and library that allows filesystems to be implemented in user space";
    platforms = platforms.linux;
    maintainers = [ maintainers.mornfall ];
  };
}

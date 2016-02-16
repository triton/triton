{ stdenv, fetchurl }:

let
  pname = "icu4c";
  version = "56.1";
in
stdenv.mkDerivation {
  name = pname + "-" + version;

  src = fetchurl {
    url = "http://download.icu-project.org/files/${pname}/${version}/${pname}-"
      + (stdenv.lib.replaceChars ["."] ["_"] version) + "-src.tgz";
    sha256 = "05j86714qaj0lvhvyr2s1xncw6sk0h2dcghb3iiwykbkbh8fjr1s";
  };

  postUnpack = ''
    sourceRoot=''${sourceRoot}/source
    echo Source root reset to ''${sourceRoot}
  '';

  preConfigure = ''
    sed -i -e "s|/bin/sh|${stdenv.shell}|" configure
  '';

  configureFlags = "--disable-debug" +
    stdenv.lib.optionalString (stdenv.isFreeBSD) " --enable-rpath";

  meta = with stdenv.lib; {
    description = "Unicode and globalization support library";
    homepage = http://site.icu-project.org/;
    maintainers = with maintainers; [ raskin urkud ];
    platforms = platforms.all;
  };
}

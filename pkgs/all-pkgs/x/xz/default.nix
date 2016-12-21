{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "xz-5.2.2";

  src = fetchurl {
    url = "http://tukaani.org/xz/${name}.tar.xz";
    multihash = "QmR7egaexND8eJXdMCzzxf4FK7u9ya3V777ZCA1LuCvWhK";
    sha256 = "f341b1906ebcdde291dd619399ae944600edc9193619dd0c0110a5f05bfcc89e";
  };

  # In stdenv-linux, prevent a dependency on bootstrap-tools.
  preConfigure = ''
    unset CONFIG_SHELL
  '';

  postInstall = ''
    rm -rf $out/share/doc
  '';

  dontDisableStatic = true;

  meta = with stdenv.lib; {
    homepage = http://tukaani.org/xz/;
    description = "XZ, general-purpose data compression software, successor of LZMA";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

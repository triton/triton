{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "xz-5.2.3";

  src = fetchurl {
    url = "http://tukaani.org/xz/${name}.tar.xz";
    multihash = "QmRoqsqhx11SwkwKokd3gkYsxNtfRwG7eRYnT21rx6KodS";
    sha256 = "7876096b053ad598c31f6df35f7de5cd9ff2ba3162e5a5554e4fc198447e0347";
  };

  # In stdenv-linux, prevent a dependency on bootstrap-tools.
  preConfigure = ''
    unset CONFIG_SHELL
  '';

  postInstall = ''
    rm -rf $out/share/doc
  '';

  disableStatic = false;

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

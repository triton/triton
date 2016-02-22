{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "xz-5.2.2";

  src = fetchurl {
    url = "http://tukaani.org/xz/${name}.tar.bz2";
    sha256 = "1da071wyx921pyx3zkxlnbpp14p6km98pnp66mg1arwi9dxgbxbg";
  };

  # We need this for static linking
  NIX_CFLAGS_COMPILE = "-fPIC";

  # In stdenv-linux, prevent a dependency on bootstrap-tools.
  preConfigure = ''
    unset CONFIG_SHELL
  '';

  doCheck = true;

  postInstall = ''
    rm -rf $out/share/doc
  '';

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

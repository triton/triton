{ stdenv
, fetchurl
, gettext
, which

, curl
, expat
, libssh
, zlib
}:

stdenv.mkDerivation rec {
  name = "exiv2-0.26";

  src = fetchurl {
    url = "http://www.exiv2.org/builds/${name}-trunk.tar.gz";
    multihash = "QmYcP4u3oBrQy899PAA9caNCxzrbsGeXuaZvoLkwoX58G2";
    sha256 = "0c625cbeb494aa1b9221280a5b053b54d0c9720d48fa9120cef7c6f93efd4dc3";
  };

  nativeBuildInputs = [
    gettext
    which
  ];

  buildInputs = [
    curl
    expat
    libssh
    zlib
  ];

  postPatch = ''
    patchShebangs src/svn_version.sh
  '';

  configureFlags = [
    "--enable-video"
    "--enable-webready"
  ];

  meta = with stdenv.lib; {
    description = "A library and command-line utility to manage image metadata";
    homepage = http://www.exiv2.org/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

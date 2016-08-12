{ stdenv
, fetchurl

, atk
, glibmm
, libsigcxx

, channel
}:

let
  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "atkmm-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/atkmm/${channel}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/atkmm/${channel}/${name}.sha256sum";
    inherit (source) sha256;
  };

  buildInputs = [
    atk
    glibmm
    libsigcxx
  ];

  configureFlags = [
    "--enable-deprecated-api"
    "--disable-documentation"
    "--without-libstdc-doc"
    "--without-libsigc-doc"
    "--without-glibmm-doc"
  ];

  meta = with stdenv.lib; {
    description = "C++ interface for the ATK library";
    homepage = http://www.gtkmm.org;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

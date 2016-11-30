{ stdenv
, fetchurl
, gettext

, ceph_lib
, glib
, libdbi
, libpng
, libxml2
, pango
}:

let
  inherit (stdenv.lib)
    optionals;
in
stdenv.mkDerivation rec {
  name = "rrdtool-1.6.0";

  src = fetchurl {
    url = "https://oss.oetiker.ch/rrdtool/pub/${name}.tar.gz";
    multihash = "Qmf54Ys2NcVmiKtnZhEDPKZ2VmVnQC4HosT2kX9FShhKFp";
    sha256 = "cd948e89cd2d8825fab4a6fb0323f810948d934af7d92c9ee8b5e9e1350e52d7";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    ceph_lib
    glib
    libdbi
    libpng
    libxml2
    pango
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-docs"
    "--disable-examples"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

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
  name = "rrdtool-1.7.0";

  src = fetchurl {
    url = "https://oss.oetiker.ch/rrdtool/pub/${name}.tar.gz";
    multihash = "QmNscVByZWVLBZMsr1GjSEGpqKKaPnrA7qMKov26cPBjzs";
    sha256 = "f97d348935b91780f2cd80399719e20c0b91f0a23537c0a85f9ff306d4c5526b";
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

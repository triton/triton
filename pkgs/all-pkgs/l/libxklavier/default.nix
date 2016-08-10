{ stdenv
, fetchurl
, gettext

, glib
, iso-codes
, libxml2
, xorg
}:

stdenv.mkDerivation rec {
  name = "libxklavier-${version}";
  version = "5.4";

  src = fetchurl rec {
    url = "http://pkgs.fedoraproject.org/repo/pkgs/libxklavier/${name}.tar.bz2/${md5Confirm}/${name}.tar.bz2";
    md5Confirm = "13af74dcb6011ecedf1e3ed122bd31fa";
    sha256 = "17a34194df5cbcd3b7bfd0f561d95d1f723aa1c87fca56bc2c209514460a9320";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    glib
    iso-codes
    libxml2
    xorg.libX11
    xorg.libXi
    xorg.xkbcomp
  ];

  meta = with stdenv.lib; {
    description = "Library providing high-level API for X Keyboard Extension known as XKB";
    homepage = http://freedesktop.org/wiki/Software/LibXklavier;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}


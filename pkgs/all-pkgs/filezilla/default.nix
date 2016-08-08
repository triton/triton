{ stdenv
, fetchurl
, gettext

, dbus
, gnutls
, libfilezilla
, nettle
, pugixml
, sqlite
, wxGTK
, xdg-utils
}:

let
  version = "3.20.0";

  baseFileUrl = "mirror://sourceforge/project/filezilla/FileZilla_Client/${version}/FileZilla_${version}";
in
stdenv.mkDerivation rec {
  name = "filezilla-${version}";

  src = fetchurl {
    url = "${baseFileUrl}_src.tar.bz2";
    multihash = "QmWo5ztPNoZ8r16nJ3PbYHzpxWfWyMX52h7ovcSaKWkXNu";
    sha256 = "4af1db6104e72fb1212ab71c2329dab747809a29b5132aa7e00025668ce08e32";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    dbus
    gnutls
    libfilezilla
    nettle
    pugixml
    sqlite
    wxGTK
    xdg-utils
  ];

  configureFlags = [
    "--disable-manualupdatecheck"
  ];

  meta = with stdenv.lib; {
    description = "Graphical FTP, FTPS and SFTP client";
    homepage = http://filezilla-project.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

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
  version = "3.22.1";

  baseFileUrl = "mirror://sourceforge/filezilla/FileZilla_Client/${version}/FileZilla_${version}";
in
stdenv.mkDerivation rec {
  name = "filezilla-${version}";

  src = fetchurl {
    url = "${baseFileUrl}_src.tar.bz2";
    sha256 = "2ea8a0d613e062c34c01b0a1c0860e1328bb8247eb02aa73ef4597d984e4285f";
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

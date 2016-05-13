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
  version = "3.17.0.1";
  baseFileUrl = "mirror://sourceforge/project/filezilla/FileZilla_Client/${version}/FileZilla_${version}";
in

stdenv.mkDerivation rec {
  name = "filezilla-${version}";

  src = fetchurl {
    url = "${baseFileUrl}_src.tar.bz2";
    multihash = "Qmeu6A6gwxguD36eHg8mprR8wVadLRqVKC5mRQBBqNs1tf";
    sha256 = "47914f9c8935e5497871642540b250a09b7e4ea4f6944d37add20fed2d50232a";
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
    homepage = http://filezilla-project.org/;
    description = "Graphical FTP, FTPS and SFTP client";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

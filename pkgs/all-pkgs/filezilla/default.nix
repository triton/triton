{ stdenv
, fetchurl
, gettext

, dbus
, gnutls
, libfilezilla
, pugixml
, sqlite
, wxGTK
, xdg-utils
}:

let
  version = "3.16.1";
  baseFileUrl = "mirror://sourceforge/project/filezilla/FileZilla_Client/${version}/FileZilla_${version}";
in
stdenv.mkDerivation rec {
  name = "filezilla-${version}";

  src = fetchurl {
    url = "${baseFileUrl}_src.tar.bz2";
    sha512Url = "${baseFileUrl}.sha512";
    sha256 = "3b046f854cea17f9c14d6a12aa5d2e027908c6535f44a068cfed5da9eddddda8";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    dbus
    gnutls
    libfilezilla
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

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

stdenv.mkDerivation rec {
  name = "filezilla-${version}";
  version = "3.16.0";

  src = fetchurl {
    url = "mirror://sourceforge/project/filezilla/FileZilla_Client/${version}/FileZilla_${version}_src.tar.bz2";
    sha256 = "0ilv4xhgav4srx6iqn0v0kv8rifgkysyx1hb9bnm45dc0skmbgbx";
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

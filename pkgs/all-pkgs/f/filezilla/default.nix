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
  version = "3.22.2.2";

  file = "FileZilla_${version}_src.tar.bz2";
in
stdenv.mkDerivation rec {
  name = "filezilla-${version}";

  src = fetchurl {
    urls = [
      "mirror://sourceforge/filezilla/FileZilla_Client/${version}/${file}"
    ];
    sha256 = "bb7117e587ff05544c24eb7925e89c27afdd43ef6c0ce2e623c021d4479802c0";
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

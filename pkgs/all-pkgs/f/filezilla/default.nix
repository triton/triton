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
  version = "3.24.1";

  file = "FileZilla_${version}_src.tar.bz2";
in
stdenv.mkDerivation rec {
  name = "filezilla-${version}";

  src = fetchurl {
    urls = [
      "mirror://sourceforge/filezilla/FileZilla_Client/${version}/${file}"
    ];
    sha256 = "e6dd748c7ec067c1165683ebe81325ce6c561f4725963a9515494af346a30c2a";
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

  # Allow newer wxGTK
  postPatch = ''
    awk -i inplace '
      {
        if (/if.*WX_VERSION.*3.1/) {
          dontPrint = 1;
        }
        if (!dontPrint) {
          print $0;
        }
        if (/fi/) {
          dontPrint = 0;
        }
      }
    ' configure
  '';

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

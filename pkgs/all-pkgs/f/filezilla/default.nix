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
  version = "3.26.2";

  file = "FileZilla_${version}_src.tar.bz2";
in
stdenv.mkDerivation rec {
  name = "filezilla-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/filezilla/FileZilla_Client/${version}/${file}";
    sha256 = "c234cb566ae7ceca46d5fa72dbf8be085a1a3ed589dccbe90978ddb9420bac7f";
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

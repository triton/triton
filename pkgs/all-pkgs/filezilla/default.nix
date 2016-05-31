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
  version = "3.18.0";
  baseFileUrl = "mirror://sourceforge/project/filezilla/FileZilla_Client/${version}/FileZilla_${version}";
in

stdenv.mkDerivation rec {
  name = "filezilla-${version}";

  src = fetchurl {
    url = "${baseFileUrl}_src.tar.bz2";
    multihash = "QmU8dDAiNCtt1XwyLoSp9h9v5v65JhHk5vC25k1NsVHVoE";
    sha256 = "37646c7198b9a98806069a32d785c58f51695589cec0d86812251364445fd7e2";
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

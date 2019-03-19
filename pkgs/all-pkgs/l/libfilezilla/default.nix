{ stdenv
, fetchurl

, gmp
, nettle
}:

let
  version = "0.15.1";
in
stdenv.mkDerivation rec {
  name = "libfilezilla-${version}";

  src = fetchurl {
    url = "mirror://filezilla/libfilezilla/${name}.tar.bz2";
    sha256 = "9e68a35b23423d95e40126cadce6b07f1e82db3721227d577450f358d5482317";
  };

  buildInputs = [
    gmp
    nettle
  ];

  configureFlags = [
    "--disable-doxygen-doc"
  ];

  meta = with stdenv.lib; {
    homepage = "https://lib.filezilla-project.org/index.php";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

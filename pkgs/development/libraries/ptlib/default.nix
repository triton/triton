{ stdenv, fetchurl, fetchTritonPatch, bison, flex, unixODBC
, openssl, openldap, cyrus_sasl, kerberos, expat, SDL, libdv, libv4l, alsaLib }:

stdenv.mkDerivation rec {
  name = "ptlib-2.10.11";

  src = fetchurl {
    url = "mirror://gnome/sources/ptlib/2.10/${name}.tar.xz";
    sha256 = "3a17f01d66301663f76130b425d93c2730f2a33df666982165166ff4653dc2c9";
  };

  nativeBuildInputs = [ bison flex ];
  buildInputs = [ unixODBC openssl openldap cyrus_sasl kerberos expat SDL libdv libv4l alsaLib ];

  enableParallelBuilding = true;

  patches = [
    (fetchTritonPatch {
      rev = "8660acdfaea1949156bd461c4f03f26dde78bfa9";
      file = "ptlib/ptlib-2.10.11-bison_fixes-1.patch";
      sha256 = "11027b21f568b2ab84f9c25775e5a697a15304b39aaab6380922ed609aac63b9";
    })
  ];
      
  meta = with stdenv.lib; {
    description = "Portable Tools from OPAL VoIP";
    maintainers = [ maintainers.raskin ];
    platforms = platforms.linux;
  };

  passthru = {
    updateInfo = {
      downloadPage = "http://ftp.gnome.org/sources/ptlib/";
    };
  };
}


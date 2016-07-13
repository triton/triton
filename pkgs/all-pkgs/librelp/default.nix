{ stdenv
, fetchurl

, gnutls
, zlib
}:

stdenv.mkDerivation rec {
  name = "librelp-1.2.12";

  src = fetchurl {
    url = "http://download.rsyslog.com/librelp/${name}.tar.gz";
    sha256 = "1mvvxqfsfg96rb6xv3fw7mcsqmyfnsb74sc53gnhpcpp4h2p6m83";
  };

  buildInputs = [
    gnutls
    zlib
  ];

  meta = with stdenv.lib; {
    homepage = http://www.librelp.com/;
    description = "a reliable logging library";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

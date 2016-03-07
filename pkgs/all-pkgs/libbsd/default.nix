{ stdenv
, fetchurl

, openssl
}:

stdenv.mkDerivation rec {
  name = "libbsd-0.8.2";

  src = fetchurl {
    url = "http://libbsd.freedesktop.org/releases/${name}.tar.xz";
    sha256 = "02i5brb2007sxq3mn862mr7yxxm0g6nj172417hjyvjax7549xmj";
  };

  buildInputs = [
    openssl
  ];

  postPatch = ''
    sed \
      -e "s,/usr,$out,g" \
      -e 's,{exec_prefix},{prefix},g' \
      -i Makefile.in
  '';

  meta = with stdenv.lib; {
    description = "Common functions found on BSD systems";
    homepage = http://libbsd.freedesktop.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

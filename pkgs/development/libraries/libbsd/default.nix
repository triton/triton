{ stdenv, fetchurl, openssl }:

stdenv.mkDerivation rec {
  name = "libbsd-0.8.2";

  src = fetchurl {
    url = "http://libbsd.freedesktop.org/releases/${name}.tar.xz";
    sha256 = "02i5brb2007sxq3mn862mr7yxxm0g6nj172417hjyvjax7549xmj";
  };

  buildInputs = [ openssl ];

  patchPhase = ''
    substituteInPlace Makefile \
      --replace "/usr" "$out" \
      --replace "{exec_prefix}" "{prefix}"
  '';

  meta = with stdenv.lib; {
    description = "Common functions found on BSD systems";
    homepage = http://libbsd.freedesktop.org/;
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}

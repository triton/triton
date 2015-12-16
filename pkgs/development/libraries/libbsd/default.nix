{ stdenv, fetchurl, openssl }:

stdenv.mkDerivation rec {
  name = "libbsd-0.8.1";

  src = fetchurl {
    url = "http://libbsd.freedesktop.org/releases/${name}.tar.xz";
    sha256 = "1c7r58y3jz0251y7l54jcyik4xr4y2lki7v8kf9ww2vjmn0qgg5d";
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

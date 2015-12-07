{ stdenv, fetchurl, openssl }:

stdenv.mkDerivation rec {
  name = "libbsd-0.8.0";

  src = fetchurl {
    url = "http://libbsd.freedesktop.org/releases/${name}.tar.xz";
    sha256 = "1373fdj6m57fz0pjnipyqq62k3p9bf3sr2k8ig3y8q6r9c435dzv";
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

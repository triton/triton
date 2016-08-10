{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "spice-protocol-0.12.11";

  src = fetchurl {
    url = "http://www.spice-space.org/download/releases/${name}.tar.bz2";
    sha256 = "0c33kg3vdz3nnl2wjfbgmszz5hbjbvsw6map35dj9hxnpwwf9fi2";
  };

  postInstall = ''
    mkdir -p $out/lib
    ln -sv ../share/pkgconfig $out/lib/pkgconfig
  '';

  meta = with stdenv.lib; {
    description = "Protocol headers for the SPICE protocol";
    homepage = http://www.spice-space.org;
    license = licenses.bsd3;
    maintainers = with maintainers; [ bluescreen303 ];
    platforms = platforms.linux;
  };
}

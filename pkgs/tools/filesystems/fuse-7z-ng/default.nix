{ stdenv, fetchFromGitHub, fuse, p7zip, autoconf, automake, pkgconfig, makeWrapper }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "fuse-7z-ng";
  version = "git-2014-06-08";

  src = fetchFromGitHub {
    owner = "kedazo";
    repo = pname;
    rev = "eb5efb1f304c2b7bc2e0389ba06c9bf2ac4b932c";
    sha256 = "17v1gcmg5q661b047zxjar735i4d3508dimw1x3z1pk4d1zjhp3x";
  };

  buildInputs = [ fuse autoconf automake pkgconfig makeWrapper ];

  preConfigure = "./autogen.sh";

  libs = stdenv.lib.makeLibraryPath [ p7zip ]; # 'cause 7z.so is loaded manually
  postInstall = ''
    wrapProgram $out/bin/${pname} --suffix LD_LIBRARY_PATH : "${libs}/p7zip"

    mkdir -p $out/share/doc/${pname}
    cp TODO README NEWS COPYING ChangeLog AUTHORS $out/share/doc/${pname}/
  '';

  meta = with stdenv.lib; {
    inherit version;
    inherit (src.homepage);
    description = "A FUSE-based filesystem that uses the p7zip library";
    platforms = platforms.linux;
    license = licenses.gpl3Plus;
  };
}

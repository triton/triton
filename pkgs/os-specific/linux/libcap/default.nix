{ stdenv, fetchurl, attr, perl }:

stdenv.mkDerivation rec {
  name = "libcap-${version}";
  version = "2.25";
  
  src = fetchurl {
    url = "mirror://kernel/linux/libs/security/linux-privs/libcap2/${name}.tar.xz";
    sha256 = "0qjiqc5pknaal57453nxcbz3mn1r4hkyywam41wfcglq3v2qlg39";
  };
  
  nativeBuildInputs = [ perl ];
  propagatedBuildInputs = [ attr ];

  preConfigure = "cd libcap";

  makeFlags = "lib=lib prefix=$(out)";

  passthru = {
    postinst = n : ''
      mkdir -p $out/share/doc/${n}
      cp ../License $out/share/doc/${n}/License
    '';
  };

  postInstall = passthru.postinst name;

  meta = {
    description = "Library for working with POSIX capabilities";
    platforms = stdenv.lib.platforms.linux;
  };
}

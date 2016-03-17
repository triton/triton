{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "man-pages-4.05";

  src = fetchurl {
    url = "mirror://kernel/linux/docs/man-pages/${name}.tar.xz";
    sha256 = "460051b94c2a0a4d158276e5d3f68e7114cb5782a050d878645e33b81f56a60d";
  };

  preBuild = ''
   makeFlagsArray+=("MANDIR=$out/share/man")
  '';

  preferLocalBuild = true;

  meta = with stdenv.lib; {
    description = "Linux development manual pages";
    homepage = http://www.kernel.org/doc/man-pages/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

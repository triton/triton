{ stdenv
, fetchurl
, help2man
, gnum4
, makeWrapper
}:

stdenv.mkDerivation rec {
  name = "libtool-2.4.6";
  
  src = fetchurl {
    url = "mirror://gnu/libtool/${name}.tar.gz";
    sha256 = "1qq61k6lp1fp75xs398yzi6wvbx232l7xbyn3p13cnh27mflvgg3";
  };
  
  nativeBuildInputs = [
    help2man
    gnum4.bin
    makeWrapper
  ];

  prefix = placeholder "bin";

  postInstall = ''
    mkdir -p "$dev"
    mv -v "$bin"/{include,lib} "$dev"

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  preFixup = ''
    wrapProgram $bin/bin/libtoolize \
      --prefix PATH : "${gnum4.bin}/bin"
  '';

  postFixup = ''
    mkdir -p "$bin"/share2/libtool
    mv -v "$bin"/share/aclocal "$bin"/share2
    mv -v "$bin"/share/libtool/build-aux "$bin"/share2/libtool
    rm -rv "$bin"/share
    mv "$bin"/share2 "$bin"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
    "man"
  ];

  meta = with stdenv.lib; {
    description = "Generic library support script";
    homepage = http://www.gnu.org/software/libtool/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

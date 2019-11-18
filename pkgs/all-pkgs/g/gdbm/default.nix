{ stdenv
, fetchurl

, ncurses
, readline
}:

let
  version = "1.18.1";

  tarballUrls = version: [
    "mirror://gnu/gdbm/gdbm-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "gdbm-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "86e613527e5dba544e73208f42b78b7c022d4fa5a6d5498bf18c8d6f745b91dc";
  };

  buildInputs = [
    ncurses
    readline
  ];

  configureFlags = [
    "--localedir=${placeholder "bin"}/share/locale"
  ];

  postInstall = ''
    mkdir -p "$bin"
    mv "$dev"/bin "$bin"

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  postFixup = ''
    rm -rv "$dev"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
    "man"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.18.1";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "325F 650C 4C2B 6AD5 8807  327A 3602 B07F 55D0 C732";
      };
      inherit (src) outputHashAlgo;
      outputHash = "86e613527e5dba544e73208f42b78b7c022d4fa5a6d5498bf18c8d6f745b91dc";
    };
  };

  meta = with stdenv.lib; {
    description = "GNU dbm key/value database library";
    homepage = http://www.gnu.org/software/gdbm/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

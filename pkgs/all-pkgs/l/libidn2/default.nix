{ stdenv
, cc
, fetchurl
, hostcc
, lib

, libunistring
}:

let
  version = "2.3.0";

  inherit (lib)
    filter;

  tarballUrls = version: [
    "mirror://gnu/libidn/libidn2-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "libidn2-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "e1cb1db3d2e249a6a3eb6f0946777c2e892d5c5dc7bd91c74394fc3a01cab8b5";
  };

  nativeBuildInputs = [
    cc
    hostcc
  ];

  buildInputs = [
    libunistring
  ];

  configureFlags = [
    "--localedir=${placeholder "bin"}/share/locale"
    "--disable-doc"
  ];

  postInstall = ''
    mkdir -p "$bin"
    mv -v "$dev"/bin "$bin"

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
  ];

  outputChecks = {
    dev.allowedReferences = [ "dev" "lib" ]
      ++ filter (n: n != null) (map (n: n.dev or null) (buildInputs ++ cc.inputs));
    bin.allowedReferences = [ "bin" "lib" ]
      ++ filter (n: n != null) (map (n: n.lib or null) (buildInputs ++ cc.inputs));
    lib.allowedReferences = [ "lib" ]
      ++ filter (n: n != null) (map (n: n.lib or null) (buildInputs ++ cc.inputs));
  };

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.3.0";
      inherit (src) outputHashAlgo;
      outputHash = "e1cb1db3d2e249a6a3eb6f0946777c2e892d5c5dc7bd91c74394fc3a01cab8b5";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "1CB2 7DBC 9861 4B2D 5841  646D 0830 2DB6 A267 0428";
      };
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/libidn/;
    description = "Library for internationalized domain names";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}

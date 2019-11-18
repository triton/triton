{ stdenv
, fetchurl
, lib
}:

let
  tarballUrls = version: [
    "mirror://savannah/attr/attr-${version}.tar.gz"
  ];

  version = "2.4.48";
in
stdenv.mkDerivation rec {
  name = "attr-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "5ead72b358ec709ed00bbf7a9eaef1654baad937c001c044fe8b74c57f5324e7";
  };

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--localedir=${placeholder "bin"}/share/locale"
  ];

  preInstall = ''
    installFlagsArray+=("sysconfdir=$dev/etc")
  '';

  postInstall = ''
    mkdir -p "$bin"
    mv -v "$dev"/bin "$bin"

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib*
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
      urls = tarballUrls "2.4.48";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprints = [
        "600C D204 FBCE A418 BD2C  A74F 1543 4326 0542 DF34"
        # Mike Frysinger
        "B902 B527 1325 F892 AC25  1AD4 4163 3B9F E837 F581"
      ];
      inherit (src) outputHashAlgo;
      outputHash = "5ead72b358ec709ed00bbf7a9eaef1654baad937c001c044fe8b74c57f5324e7";
    };
  };

  meta = with lib; {
    description = "Library and tools for manipulating extended attributes";
    homepage = http://savannah.nongnu.org/projects/attr/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

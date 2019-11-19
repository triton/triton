{ stdenv
, fetchTritonPatch
, fetchurl

, findXMLCatalogs
, icu
, readline
, xz
, zlib
}:

let
  version = "2.9.10";

  tarballUrls = version: [
    "http://xmlsoft.org/sources/libxml2-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "libxml2-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmPWcjgfiucBtkhxoWqJjHcKDXuj7QTmj5qnrCRfxgBJXj";
    hashOutput = false;
    sha256 = "aafee193ffb8fe0c82d4afef6ef91972cbaf5feea100edc2f262750611b4be1f";
  };

  buildInputs = [
    icu
    readline
    xz
    zlib
  ];

  postPatch = ''
    find . -name Makefile.in -exec sed -i '/^SUBDIRS /s, \(doc\|example\),,g' {} \;
  '';

  configureFlags = [
    "--with-history"
    "--with-icu"
    "--with-readline=${readline}"
  ];

  postInstall = ''
    mkdir -p "$bin"/bin
    mv -v "$dev"/bin/* "$bin"/bin
    mv -v "$bin"/bin/*-config "$dev"/bin

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib

    mkdir -p "$dev"/nix-support "$bin"/nix-support
    echo '${icu}' >"$dev"/nix-support/propagated-native-build-inputs
    echo '${findXMLCatalogs}' >"$bin"/nix-support/propagated-native-build-inputs
  '';

  postFixup = ''
    mkdir -p "$dev"/share2
    mv -v "$dev"/share/aclocal "$dev"/share2
    rm -rv "$dev"/share
    mv "$dev"/share2 "$dev"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
    "man"
  ];

  passthru = {
    inherit version;
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.9.10";
      inherit (src) outputHashAlgo;
      outputHash = "aafee193ffb8fe0c82d4afef6ef91972cbaf5feea100edc2f262750611b4be1f";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") urls;
        pgpKeyFingerprint = "C744 15BA 7C9C 7F78 F02E  1DC3 4606 B8A5 DE95 BC1F";
      };
    };
  };

  meta = with stdenv.lib; {
    homepage = http://xmlsoft.org/;
    description = "An XML parsing library for C";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

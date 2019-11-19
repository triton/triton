{ stdenv
, fetchTritonPatch
, fetchurl

, findXMLCatalogs
, libgcrypt
, libxml2
}:

let
  tarballUrls = version: [
    "http://xmlsoft.org/sources/libxslt-${version}.tar.gz"
  ];

  version = "1.1.34";
in
stdenv.mkDerivation rec {
  name = "libxslt-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    #multihash = "QmfQAJ5t9uqJjmNvGmSi2dLRwbp3iQfSiQauygZdqGxsRT";
    hashOutput = false;
    sha256 = "98b1bd46d6792925ad2dfe9a87452ea2adebf69dcb9919ffd55bf926a7f93f7f";
  };

  buildInputs = [
    libgcrypt
    libxml2
  ];

  propagatedBuildInputs = [
    findXMLCatalogs
  ];

  configureFlags = [
    "--with-libxml-prefix=${libxml2}"
    "--without-python"
    "--with-crypto"
    "--without-debug"
    "--without-mem-debug"
    "--without-debugger"
  ];

  postPatch = ''
    sed -i 's,^\(LIBXSLT_DEFAULT_PLUGINS_PATH=\).*,\1${placeholder "lib"}/lib/libxslt-plugins,' configure
  '';

  postInstall = ''
    mkdir -p "$bin"/bin
    mv -v "$dev"/bin/* "$bin"/bin
    mv -v "$bin"/bin/*-config "$dev"/bin

    mkdir -p "$lib"/lib
    mv "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  postFixup = ''
    mv -v "$dev"/nix-support "$bin"
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
      urls = tarballUrls "1.1.34";
      inherit (src) outputHashAlgo;
      outputHash = "98b1bd46d6792925ad2dfe9a87452ea2adebf69dcb9919ffd55bf926a7f93f7f";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") urls;
        pgpKeyFingerprint = "C744 15BA 7C9C 7F78 F02E  1DC3 4606 B8A5 DE95 BC1F";
      };
    };
  };

  meta = with stdenv.lib; {
    homepage = http://xmlsoft.org/XSLT/;
    description = "A C library and tools to do XSL transformations";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

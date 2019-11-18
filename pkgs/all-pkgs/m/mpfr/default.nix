{ stdenv
, fetchurl

, gmp
}:

let
  patchSha256s = import ./patches.nix;

  tarballUrls = version: [
    "mirror://gnu/mpfr/mpfr-${version}.tar.xz"
  ];

  version = "4.0.2";

  inherit (stdenv.lib)
    flip
    length
    mapAttrsToList;
in
stdenv.mkDerivation rec {
  name = "mpfr-${version}-p${toString (length patches)}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "1d3be708604eae0e42d578ba93b390c2a145f17743a744d8f3f8c2ad5855a38a";
  };

  buildInputs = [
    gmp
  ];

  patches = flip mapAttrsToList patchSha256s (n: { multihash, sha256 }: fetchurl {
    name = "mpfr-${version}-${n}";
    url = "http://www.mpfr.org/mpfr-${version}/${n}";
    inherit
      multihash
      sha256;
  });

  # Only build the library
  postPatch = ''
    grep -q '^SUBDIRS = ' Makefile.in
    sed -i 's,^SUBDIRS = .*$,SUBDIRS = src,' Makefile.in
  '';

  configureFlags = [
    "--with-pic"
  ];

  # Only provides some doc files
  postInstall = ''
    rm -r "$dev"/share

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  outputs = [
    "dev"
    "lib"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "4.0.2";
      inherit (src) outputHashAlgo;
      outputHash = "1d3be708604eae0e42d578ba93b390c2a145f17743a744d8f3f8c2ad5855a38a";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "07F3 DBBE CC1A 3960 5078  094D 980C 1976 98C3 739D";
      };
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.mpfr.org/;
    description = "Library for multiple-precision floating-point arithmetic";
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

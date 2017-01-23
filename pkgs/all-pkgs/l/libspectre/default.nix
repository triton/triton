{ stdenv
, fetchTritonPatch
, fetchurl

, ghostscript
}:

stdenv.mkDerivation rec {
  name = "libspectre-0.2.8";

  src = fetchurl rec {
    url = "https://libspectre.freedesktop.org/releases/${name}.tar.gz";
    multihash = "Qmc2K1pgGFZYw5WLdUxdwUgcfYBbQKS9P3nkxUWxo1yHgv";
    hashOutput = false;
    sha256 = "65256af389823bbc4ee4d25bfd1cc19023ffc29ae9f9677f2d200fa6e98bc7a8";
  };

  buildInputs = [
    ghostscript
  ];

  patches = [
    # Fix compatibility with newer versions of ghostscript
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "libspectre/libspectre-0.2.7-ghostscript-9.18.patch";
      sha256 = "2db97f45f539d7e89d3cb555825d54cdb2c78f1f8d024f5d28c33e7d394d136a";
    })
  ];

  configureFlags = [
    "--disable-asserts"
    "--disable-checks"
    # Tests require Cairo, but Cairo depends on libspectre
    "--disable-test"
    "--disable-iso-c"
  ];

  doCheck = false;

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha1Urls = map (n: "${n}.sha1.asc") src.urls;
      pgpKeyFingerprint = "E5E3 7500 1A75 9F58 1AC5  6C31 8F10 4E6A 523E 6462";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "PostScript rendering library";
    homepage = https://libspectre.freedesktop.org/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

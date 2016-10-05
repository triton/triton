{ stdenv
, fetchurl
, m4

, bzip2
, linux-headers_4-6
, xz
, zlib
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;

  tarballUrls = version: [
    "https://fedorahosted.org/releases/e/l/elfutils/${version}/elfutils-${version}.tar.bz2"
  ];

  version = "0.167";
in
stdenv.mkDerivation rec {
  name = "elfutils-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmTUVjSnPLPmYQmDFKb5Twfb3AQxv9Rx7FcLwjoQPfa6My";
    hashOutput = false;
    sha256 = "3f300087c42b6f35591163b48246b4098ce39c4c6f5d55a83023c903c5776553";
  };

  nativeBuildInputs = [
    m4
  ];

  buildInputs = [
    bzip2
    xz
    zlib
  ];

  configureFlags = [
    "--enable-deterministic-archives"
    # This is probably desireable but breaks things
    "--disable-sanitize-undefined"
  ];

  # Fix an issue where we are missing new enough headers to compile BPF
  # Moving this outside of preBuild would cause a mass rebuild
  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${linux-headers_4-6}/include"
  '';

  passthru = {
    inherit version;

    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "0.167";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "47CC 0331 081B 8BC6 D0FD  4DA0 8370 665B 5781 6A6A";
      inherit (src) outputHashAlgo;
      outputHash = "3f300087c42b6f35591163b48246b4098ce39c4c6f5d55a83023c903c5776553";
    };
  };

  meta = with stdenv.lib; {
    description = "Libraries/utilities to handle ELF objects";
    homepage = https://fedorahosted.org/elfutils/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

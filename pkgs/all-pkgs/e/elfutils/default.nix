{ stdenv
, fetchurl
, m4

, bzip2
, xz
, zlib
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;

  tarballUrls = version: [
    "https://sourceware.org/elfutils/ftp/${version}/elfutils-${version}.tar.bz2"
  ];

  version = "0.174";
in
stdenv.mkDerivation rec {
  name = "elfutils-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmcDZDRV4yAp6uNwNWHPWJypzhK6UeFbkW9eYLqzZ5mvGv";
    hashOutput = false;
    sha256 = "cdf27e70076e10a29539d89e367101d516bc4aa11b0d7777fe52139e3fcad08a";
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

  passthru = {
    inherit version;

    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "0.174";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "47CC 0331 081B 8BC6 D0FD  4DA0 8370 665B 5781 6A6A";
      inherit (src) outputHashAlgo;
      outputHash = "1f844775576b79bdc9f9c717a50058d08620323c1e935458223a12f249c9e066";
    };
  };

  meta = with stdenv.lib; {
    description = "Libraries/utilities to handle ELF objects";
    homepage = https://sourceware.org/elfutils/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

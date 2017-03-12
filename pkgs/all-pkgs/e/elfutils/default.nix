{ stdenv
, fetchurl
, m4

, bzip2
, linux-headers_4-9
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

  version = "0.168";
in
stdenv.mkDerivation rec {
  name = "elfutils-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "Qme24e4zaT3nZXnsPBpiMpb9RNAWBYuSrWDVsXqfx7SJfa";
    hashOutput = false;
    sha256 = "b88d07893ba1373c7dd69a7855974706d05377766568a7d9002706d5de72c276";
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
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${linux-headers_4-9}/include"
  '';

  passthru = {
    inherit version;

    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "0.168";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "47CC 0331 081B 8BC6 D0FD  4DA0 8370 665B 5781 6A6A";
      inherit (src) outputHashAlgo;
      outputHash = "b88d07893ba1373c7dd69a7855974706d05377766568a7d9002706d5de72c276";
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

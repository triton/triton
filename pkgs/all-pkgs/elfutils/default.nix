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
    "https://fedorahosted.org/releases/e/l/elfutils/${version}/elfutils-${version}.tar.bz2"
    "mirror://gentoo/elfutils-${version}.tar.bz2"
  ];
in

stdenv.mkDerivation rec {
  name = "elfutils-${version}";
  version = "0.166";

  src = fetchurl {
    urls = tarballUrls version;
    allowHashOutput = false;
    sha256 = "3c056914c8a438b210be0d790463b960fc79d234c3f05ce707cbff80e94cba30";
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
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "0.166";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "47CC 0331 081B 8BC6 D0FD  4DA0 8370 665B 5781 6A6A ";
      inherit (src) outputHashAlgo;
      outputHash = "3c056914c8a438b210be0d790463b960fc79d234c3f05ce707cbff80e94cba30";
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

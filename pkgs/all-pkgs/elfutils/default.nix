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
in

stdenv.mkDerivation rec {
  name = "elfutils-${version}";
  version = "0.166";

  src = fetchurl {
    urls = [
      "https://fedorahosted.org/releases/e/l/elfutils/${version}/${name}.tar.bz2"
      "mirror://gentoo/${name}.tar.bz2"
    ];
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

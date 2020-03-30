{ stdenv
, docbook-xsl
, doxygen
, fetchurl
, graphviz
, lib
, libxslt
, xmlto

, expat
, libffi
, libxml2

, enableDocumentation ? false
}:

let
  inherit (lib)
    boolEn
    optionals;

  version = "1.18.0";
in
stdenv.mkDerivation rec {
  name = "wayland-${version}";

  src = fetchurl {
    url = "https://wayland.freedesktop.org/releases/${name}.tar.xz";
    multihash = "QmdjFt36YJut4mKY8ciymC5EPBXnuoNwVxkJqFVaAZeku8";
    hashOutput = false;
    sha256 = "4675a79f091020817a98fd0484e7208c8762242266967f55a67776936c2e294d";
  };

  nativeBuildInputs = [ ]
    ++ optionals enableDocumentation [
      docbook-xsl
      doxygen
      graphviz
      libxslt
      xmlto
    ];

  buildInputs = [
    expat
    libffi
    libxml2
  ];

  configureFlags = [
    "--enable-libraries"
    "--${boolEn enableDocumentation}-documentation"
  ];

  passthru = {
    inherit version;

    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "C006 6D7D B8E9 AC68 44D7  2871 5E54 498E 697F 11D7";
      };
    };
  };

  meta = with lib; {
    description = "Reference implementation of the wayland protocol";
    homepage = https://wayland.freedesktop.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

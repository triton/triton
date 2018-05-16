{ stdenv
, docbook-xsl
, doxygen
, fetchurl
, graphviz
, libxslt
, xmlto

, expat
, libffi
, libxml2

, enableDocumentation ? false
}:

let
  inherit (stdenv.lib)
    boolEn
    optionals;

  version = "1.15.0";
in
stdenv.mkDerivation rec {
  name = "wayland-${version}";

  src = fetchurl {
    url = "https://wayland.freedesktop.org/releases/${name}.tar.xz";
    multihash = "QmSgwmWbnThrBc9s42b9bHtDraxcrBXZnNV4VC5gguZe6A";
    hashOutput = false;
    sha256 = "eb3fbebb8559d56a80ad3753ec3db800f587329067962dbf65e14488b4b7aeb0";
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
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "C006 6D7D B8E9 AC68 44D7  2871 5E54 498E 697F 11D7";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
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

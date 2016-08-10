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
    enFlag
    optionals;

  version = "1.11.0";
in
stdenv.mkDerivation rec {
  name = "wayland-${version}";

  src = fetchurl {
    url = "http://wayland.freedesktop.org/releases/${name}.tar.xz";
    allowHashOutput = false;
    sha256 = "9540925f7928becfdf5e3b84c70757f6589bf1ceef09bea78784d8e4772c0db0";
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
    (enFlag "documentation" enableDocumentation null)
  ];

  passthru = {
    inherit version;

    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "C722 3EBE 4EF6 6513 B892  5989 11A3 0156 E0E6 7611";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Reference implementation of the wayland protocol";
    homepage = http://wayland.freedesktop.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

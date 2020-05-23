{ stdenv
, fetchurl

, pcre

, channel
}:

let
  inherit (builtins.getAttr channel (import ./sources.nix))
    sha256
    version;
in

stdenv.mkDerivation rec {
  name = "swig-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/swig/swig/${name}/${name}.tar.gz";
    inherit sha256;
  };

  buildInputs = [
    pcre
  ];

  configureFlags = [
    "--with-pcre"
    "--disable-ccache"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      failEarly = true;
      insecureHashOutput = true;
      fullOpts = { };
    };
  };

  meta = with stdenv.lib; {
    description = "Interface compiler that connects C/C++ & high-level languages";
    homepage = http://swig.org/;
    # Licensing: http://www.swig.org/Release/LICENSE .
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

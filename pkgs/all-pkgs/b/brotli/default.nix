{ stdenv
, fetchurl
}:

let
  version = "0.4.0";
in
stdenv.mkDerivation rec {
  name = "brotli-${version}";

  src = fetchurl {
    url = "https://github.com/google/brotli/releases/download/v${version}/Brotli-${version}.tar.gz";
    sha256 = "d6a06624eece91f54e4b22b8088ce0090565c7d3f121386dc007b6d2723397ac";
  };

  postPatch = ''
    cd tools
  '';

  installPhase = ''
    install -D -m 755 -v 'bro' "$out/bin/bro"
    ln -sv "$out/bin/bro" "$out/bin/brotli"
  '';

  passthru = {
    inherit version;
  };

  meta = with stdenv.lib; {
    description = "A generic-purpose lossless compression algorithm and tool";
    homepage = https://github.com/google/brotli;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}


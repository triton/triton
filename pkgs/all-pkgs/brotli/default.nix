{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "brotli-${version}";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "google";
    repo = "brotli";
    rev = "v" + version;
    sha256 = "ff59abd8c28851b2233b31b4408a45c88505bf6196acdcab77a26963533d0108";
  };

  postUnpack = ''
    sourceRoot="$sourceRoot/tools"
  '';

  installPhase = ''
    install -D -m 755 -v 'bro' "$out/bin/bro"
    ln -sv "$out/bin/bro" "$out/bin/brotli"
  '';

  meta = with stdenv.lib; {
    description = "A generic-purpose lossless compression algorithm and tool";
    homepage = https://github.com/google/brotli;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}


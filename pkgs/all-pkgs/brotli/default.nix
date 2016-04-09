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
    sha256 = "cfcc35ca06f2c1b465b04999a6e84e6d6f855bceb49896b822c8b06779a18d49";
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


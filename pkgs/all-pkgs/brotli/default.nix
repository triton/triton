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
    sha256 = "88fa102a80a42bcf40bcafffa4457734ef5bd9f3bab42a9282246c640dc665b6";
  };

  postUnpack = ''
    sourceRoot="$sourceRoot/tools"
  '';

  installPhase = ''
    install -D -m 755 -v 'bro' "$out/bin/bro"
  '';

  meta = with stdenv.lib; {
    description = "A generic-purpose lossless compression algorithm and tool";
    homepage = https://github.com/google/brotli;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}


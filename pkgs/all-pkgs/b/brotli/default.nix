{ stdenv
, fetchurl
}:

let
  version = "0.5.2";
in
stdenv.mkDerivation rec {
  name = "brotli-${version}";

  src = fetchurl {
    url = "https://github.com/google/brotli/releases/download/v${version}/Brotli-${version}.tar.gz";
    sha256 = "60453b0d24a7dbff802b92c6e1d244d986ea517b3edb9eb71c39aa53f05cb144";
  };

  # Only ships with cmake / bazel now but it simple enough to build our own
  buildPhase = ''
    readarray -t cfiles < <(find . -name \*.c)
    args=()
    for cfile in "''${cfiles[@]}"; do
      ( set -x; gcc -O2 -c -o "''${cfile%.c}.o" "$cfile" ) &
      args+=("''${cfile%.c}.o")
    done
    wait
    ( set -x; gcc -o bro "''${args[@]}" -lm )
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


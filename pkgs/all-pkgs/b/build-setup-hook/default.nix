{ stdenv
}:

{ name
, src
}:

stdenv.mkDerivation {
  name = "setup-hook-${name}";

  inherit src;

  configurePhase = ''
    if [ -x "src" ]; then
    fi
    if [ -x "test" ]; then
      export doCheck=1
    fi
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

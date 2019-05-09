{ stdenv
, lib
, oath-toolkit
}:

stdenv.mkDerivation rec {
  name = "liboath-${oath-toolkit.version}";

  inherit (oath-toolkit)
    src
    patches;

  postPatch = ''
    cd liboath
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

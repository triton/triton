{ stdenv
, fetchurl
, lib
}:

let
  inherit (lib)
    ;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "chromium-${channel}-${source.version}";

  meta = with lib; {
    description = "";
    homepage = ;
    license = licenses.;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

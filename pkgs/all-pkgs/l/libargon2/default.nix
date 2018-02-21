{ stdenv
, fetchFromGitHub
}:

let
  date = "2017-12-27";
  rev = "670229c849b9fe882583688b74eb7dfdc846f9f6";
in
stdenv.mkDerivation {
  name = "libargon2-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "P-H-C";
    repo = "phc-winner-argon2";
    inherit rev;
    sha256 = "eb80bfece331bc4e657826e114dfd178e676376d1b2d9af19a97aa84520daaa6";
  };

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  postInstall = ''
    mkdir -p "$out"/lib/pkgconfig
    sed libargon2.pc \
      -e "s,^prefix=.*,prefix=$out,g" \
      -e 's,@HOST_MULTIARCH@,,g' \
      -e 's,@UPSTREAM_VER@,${date},' \
      >"$out"/lib/pkgconfig/libargon2.pc
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

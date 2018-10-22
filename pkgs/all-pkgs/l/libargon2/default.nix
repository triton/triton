{ stdenv
, fetchFromGitHub
}:

let
  date = "2018-08-19";
  rev = "b31aa322566a8559403d419b2e9cd3f57957e394";
in
stdenv.mkDerivation {
  name = "libargon2-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "P-H-C";
    repo = "phc-winner-argon2";
    inherit rev;
    sha256 = "1cb3f9a1ae3180960f0141cb854021bb78b8cd7ed2ed09754f4d10b672568d98";
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

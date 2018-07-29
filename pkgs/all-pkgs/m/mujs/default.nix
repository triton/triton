{ stdenv
, fetchFromGitHub
, lib
}:

let
  version = "1.0.3";
in
stdenv.mkDerivation {
  name = "mujs-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "ccxvii";
    repo = "mujs";
    rev = "${version}";
    sha256 = "aa94d2c17ecdb2494b5832cc6b5930f2b915e8be3d0aff4a48516b68cbec01de";
  };

  makeFlags = [
    # If building from an arbitrary commit, this still needs to
    # be a semantic version for the pkgconfig file.
    "VERSION=${version}"
  ];

  preInstall = ''
    installFlagsArray+=("prefix=$out")
  '';

  meta = with lib; {
    license = licenses.agpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

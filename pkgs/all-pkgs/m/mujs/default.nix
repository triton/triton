{ stdenv
, fetchFromGitHub
, lib
}:

let
  version = "1.0.2";
in
stdenv.mkDerivation {
  name = "mujs-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "ccxvii";
    repo = "mujs";
    rev = "${version}";
    sha256 = "cfa27ac2572549b7cfe03fe8305e134dcbc7cba76bf2b90022bfa4eca1d63836";
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

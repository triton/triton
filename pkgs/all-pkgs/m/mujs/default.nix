{ stdenv
, fetchFromGitHub
, lib

, readline
}:

let
  version = "1.0.5";
in
stdenv.mkDerivation {
  name = "mujs-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "ccxvii";
    repo = "mujs";
    rev = "${version}";
    sha256 = "a0a87db8c06d147c9285695728226468bb1dce3ab4bf84af1d82434808bc0b5c";
  };

  buildInputs = [
    readline
  ];

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

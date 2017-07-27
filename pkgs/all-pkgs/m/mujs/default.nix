{ stdenv
, fetchFromGitHub
, lib
}:

let
  version = "1.0.1";
in
stdenv.mkDerivation {
  name = "mujs-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "ccxvii";
    repo = "mujs";
    rev = "${version}";
    sha256 = "06b16cf2340790f57e525915b36e4b032ae20599e84266a056423f2f0cfa19e1";
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

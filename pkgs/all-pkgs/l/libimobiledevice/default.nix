{ stdenv
, lib
, autoreconfHook
, fetchFromGitHub
, python2Packages

, libplist
, libusbmuxd
, openssl
}:

let
  date = "2017-08-12";
  rev = "5a85432719fb3d18027d528f87d2a44b76fd3e12";
in
stdenv.mkDerivation rec {
  name = "libimobiledevice-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "libimobiledevice";
    repo = "libimobiledevice";
    inherit rev;
    sha256 = "16be281669bf9e1ae62a8725fc839e50cb1c561733c50c209bb00a16493a7f93";
  };

  nativeBuildInputs = [
    autoreconfHook
    python2Packages.cython
    python2Packages.python
  ];

  buildInputs = [
    libplist
    libusbmuxd
    openssl
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

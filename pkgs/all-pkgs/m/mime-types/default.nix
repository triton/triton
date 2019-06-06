{ stdenv
, fetchFromGitLab
, lib
}:

let
  date = "2019-04-26";
  rev = "7909e878851a569515e7b53e328d7d569eb75b50";
in
stdenv.mkDerivation {
  name = "mime-types-${date}";

  src = fetchFromGitLab {
    version = 6;
    host = "https://salsa.debian.org";
    owner = "debian";
    repo = "mime-support";
    inherit rev;
    multihash = "QmQNUW6DjRvBwepdeAmYdFopkj9PaSoaqXVE3XXViheCmP";
    sha256 = "64406875391b0d37a19b5f9bc25fb5f0112194bf8591b497dbbc01544d6b0abf";
  };

  installPhase = ''
    install -D -m644 -v mime.types "$out"/etc/mime.types
  '';

  meta = with lib; {
    description = "Provides /etc/mime.types file";
    homepage = https://salsa.debian.org/debian/mime-support;
    license = licenses.free;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

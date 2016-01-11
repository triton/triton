{ stdenv, fetchFromGitHub, nodejs, which, python2, utillinux }:

let
  version = "17.1"; # see ${src}/util/version/Version.h
in
stdenv.mkDerivation {
  name = "cjdns-${version}";

  src = fetchFromGitHub {
    owner = "cjdelisle";
    repo = "cjdns";
    rev = "cjdns-v${version}";
    sha256 = "0q9d7ll912lvv0z67mhw83vxkbv9kbajh9ngqdj937my08i9yq6c";
  };

  nativeBuildInputs = [ which python2 nodejs ];
  buildInputs = stdenv.lib.optional stdenv.isLinux [ utillinux ];

  buildPhase = ''
    bash do
  '';

  installPhase = ''
    installBin cjdroute makekeys privatetopublic publictoip6
    mkdir -p $out/share/cjdns
    cp -R contrib tools node_build node_modules $out/share/cjdns/
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/cjdelisle/cjdns;
    description = "Encrypted networking for regular people";
    license = licenses.gpl3;
    maintainers = with maintainers; [ viric ehmry ];
    platforms = platforms.unix;
  };
}

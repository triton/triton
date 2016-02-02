{ stdenv, fetchFromGitHub, nodejs, which, python2, utillinux }:

let
  version = "17.3"; # see ${src}/util/version/Version.h
in
stdenv.mkDerivation {
  name = "cjdns-${version}";

  src = fetchFromGitHub {
    owner = "cjdelisle";
    repo = "cjdns";
    rev = "cjdns-v${version}";
    sha256 = "19d792xd8210siirckjrnwl37c3qx0imn506zr87nkcb6g7vil65";
  };

  nativeBuildInputs = [ which python2 nodejs ];
  buildInputs = [ utillinux ];

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

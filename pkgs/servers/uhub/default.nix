{ stdenv, fetchurl, cmake, pkgconfig
, sqlite, systemd, openssl
, stresstestSupport ? false
}:

let
  mkFlag = optset: flag: if optset then "-D${flag}=ON" else "-D${flag}=OFF";
in

stdenv.mkDerivation rec {
  name = "uhub-${version}";
  version = "0.5.0";

  src = fetchurl {
    url = "https://github.com/janvidar/uhub/archive/${version}.tar.gz";
    sha256 = "0ai6fvv075nk64al79piqj5i26ll2cq7wlzbrh6caigw9v59l5lf";
  };

  patchPhase = ''
    # Install plugins to $out/lib/plugins/ instead of /usr/lib/uhub/
    sed -e 's,/usr/lib/uhub/,lib/plugins/,' -i CMakeLists.txt
    # Install example configs to $out/share/doc/ instead of /etc/uhub
    sed -e 's,/etc/uhub,doc/,' -i CMakeLists.txt
  '';

  cmakeFlags = [
    "-DSSL_SUPPORT=ON"
    "-DUSE_OPENSSL=ON"
    "-DSYSTEMD_SUPPORT=ON"
    (mkFlag stresstestSupport "ADC_STRESS")
  ];

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [ openssl sqlite systemd ];

  postInstall = ''
    # Remove unsupported plugins
    # This build uses sqlite as a backend and does not support plain-text storage
    rm -f $out/lib/plugins/mod_auth_simple.so
    rm -f $out/lib/plugins/mod_chat_history.so
    # Example plugin does nothing
    rm -f $out/lib/plugins/mod_example.so
  '';

  meta = with stdenv.lib; {
    description = "High performance ADC (DC++) hub for peer-to-peer networks";
    homepage = https://www.uhub.org/;
    license = licenses.gpl3;
    maintainers = with maintainers; [ codyopel emery ];
    platforms = platforms.unix;
  };
}
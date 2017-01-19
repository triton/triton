{ stdenv
, fetchurl
, file
}:

stdenv.mkDerivation rec {
  name = "keyutils-1.5.9";

  src = fetchurl {
    url = "https://people.redhat.com/dhowells/keyutils/${name}.tar.bz2";
    multihash = "QmR3wkaD2VRBm4Mkruzpuf2QCiseCWJNgcoMdZqxZ8p29J";
    sha256 = "1bl3w03ygxhc0hz69klfdlwqn33jvzxl1zfl2jmnb2v85iawb8jd";
  };

  nativeBuildInputs = [
    file
  ];

  patchPhase = ''
    sed \
      -e "s,/usr/bin/make,$(type -P make)," \
      -e "s, /usr, ," \
      -e "s,\$(LNS) \$(LIBDIR)/\$(SONAME),\$(LNS) \$(SONAME)," \
      -i Makefile
  '';

  preInstall = ''
    installFlagsArray+=("DESTDIR=$out")
  '';

  meta = with stdenv.lib; {
    homepage = http://people.redhat.com/dhowells/keyutils/;
    description = "Tools used to control the Linux kernel key management system";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

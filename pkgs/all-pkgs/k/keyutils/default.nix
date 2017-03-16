{ stdenv
, fetchurl
, file
}:

stdenv.mkDerivation rec {
  name = "keyutils-1.5.10";

  src = fetchurl {
    url = "https://people.redhat.com/dhowells/keyutils/${name}.tar.bz2";
    multihash = "QmU7esZtorARS6QNwsL8v2nm4kkVyT8tYLGzgicp1KyYZp";
    sha256 = "115c3deae7f181778fd0e0ffaa2dad1bf1fe2f5677cf2e0e348cdb7a1c93afb6";
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

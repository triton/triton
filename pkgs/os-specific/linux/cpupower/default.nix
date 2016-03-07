{ stdenv
, fetchurl
, gettext

, coreutils
, kernel
, pciutils
}:

stdenv.mkDerivation {
  name = "cpupower-${kernel.version}";

  src = kernel.src;

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    pciutils
  ];

  postPatch = ''
    cd tools/power/cpupower

    # Patch the build to use the correct tooling
    grep -q '/bin/true' Makefile
    grep -q '/bin/pwd' Makefile
    grep -q '/usr/bin/install' Makefile
    sed \
      -e 's,/bin/true,${coreutils}/bin/true,g' \
      -e 's,/bin/pwd,${coreutils}/bin/pwd,g' \
      -e 's,/usr/bin/install,${coreutils}/bin/install,g' \
      -i Makefile
  '';


  preInstall = ''
    installFlagsArray+=(
      "bindir=$out/bin"
      "sbindir=$out/sbin"
      "mandir=$out/share/man"
      "includedir=$out/include"
      "libdir=$out/lib"
      "localedir=$out/share/locale"
      "docdir=$out/share/doc/cpupower"
      "confdir=$out/etc"
    )
  '';

  installTargets = [
    "install"
    "install-man"
  ];

  meta = with stdenv.lib; {
    description = "Tool to examine and tune power saving features";
    homepage = https://www.kernel.org.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

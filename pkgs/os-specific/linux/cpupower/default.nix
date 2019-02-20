{ stdenv
, lib
, fetchurl
, gettext

, coreutils
, kernel
, pciutils
}:

let
  inherit (lib)
    optionalString
    versionOlder;
in
stdenv.mkDerivation {
  name = "cpupower-${kernel.version}";

  src = kernel.src;

  patches = kernel.patches;

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
  '' + optionalString (versionOlder kernel.version "4.15") ''
    grep -q '/bin/pwd' Makefile
  '' + ''
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
      "docdir=$TMPDIR"
      "confdir=$out/etc"
      "bash_completion_dir=$out/share/bash-completion/completions"
    )
  '';

  installTargets = [
    "install"
    "install-man"
  ];

  meta = with lib; {
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

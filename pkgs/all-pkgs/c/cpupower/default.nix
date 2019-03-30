{ stdenv
, lib
, fetchurl
, gettext

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

    grep -q '/usr/bin/install' Makefile
    sed -i "s,/usr/bin/install,install,g" Makefile
  '';

  makeFlags = [
    "DEBUG=false"
  ];

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

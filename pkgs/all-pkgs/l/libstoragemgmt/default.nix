{ stdenv
, fetchurl
, python2Packages

, glib
, libconfig
, libxml2
, openssl
, sqlite
, systemd_lib
, yajl
}:

let
  version = "1.4.0";
in
stdenv.mkDerivation rec {
  name = "libstoragemgmt-${version}";

  src = fetchurl {
    url = "https://github.com/libstorage/libstoragemgmt/releases/download/${version}/${name}.tar.gz";
    sha256 = "a820f6bf987dc72498f25cd0bfa226a922ccdfa9a445c1c7c430e3a4cd29d7ee";
  };

  nativeBuildInputs = [
    python2Packages.python
  ];

  buildInputs = [
    glib
    libconfig
    libxml2
    openssl
    python2Packages.pyudev
    python2Packages.pywbem
    sqlite
    systemd_lib
    yajl
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemdsystemunitdir=$out/etc/systemd/system"
    )
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--without-test"
    "--without-mem-leak-test"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIR"
      "bashcompletiondir=$out/etc/bash_completion.d"
    )
  '';

  NIX_CFLAGS_COMPILE = [
    "-Wno-format-overflow"
    "-Wno-implicit-fallthrough"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, fetchurl
, lib
, perl

, glib
, libconfig
, libxml2
, openssl
, python3Packages
, sqlite
, systemd_lib
, yajl
}:

let
  version = "1.8.1";
in
stdenv.mkDerivation rec {
  name = "libstoragemgmt-${version}";

  src = fetchurl {
    url = "https://github.com/libstorage/libstoragemgmt/releases/download/${version}/${name}.tar.gz";
    sha256 = "ad917d94c39d822235c75d87685ec1e23b669b758330fb92b59c74b4d3b8549a";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    glib
    libconfig
    libxml2
    openssl
    python3Packages.python
    python3Packages.pywbem
    python3Packages.six
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
    "--with-python3"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIR"
      "bashcompletiondir=$out/etc/bash_completion.d"
    )
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

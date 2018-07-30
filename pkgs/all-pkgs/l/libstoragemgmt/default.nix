{ stdenv
, fetchurl
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
  version = "1.6.2";
in
stdenv.mkDerivation rec {
  name = "libstoragemgmt-${version}";

  src = fetchurl {
    url = "https://github.com/libstorage/libstoragemgmt/releases/download/${version}/${name}.tar.gz";
    sha256 = "2b5e6156caeb96567ce0c165303959e328c5aaca77fbb9616c80c81751fb08eb";
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

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

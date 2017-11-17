{ stdenv
, fetchurl
, perl
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
  version = "1.6.1";
in
stdenv.mkDerivation rec {
  name = "libstoragemgmt-${version}";

  src = fetchurl {
    url = "https://github.com/libstorage/libstoragemgmt/releases/download/${version}/${name}.tar.gz";
    sha256 = "89d48eefe8981e8484e21f2dd9bebabeaffb18635b25f2d31dfc3a6e431b4cde";
  };

  nativeBuildInputs = [
    perl
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

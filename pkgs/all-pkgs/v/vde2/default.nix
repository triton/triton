{ stdenv
, fetchurl
, python

, libpcap
, openssl
}:

let
  version = "2.3.2";
in
stdenv.mkDerivation rec {
  name = "vde2-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/vde/vde2/${version}/${name}.tar.bz2";
    sha256 = "cbea9b7e03097f87a6b5e98b07890d2275848f1fe4b9fcda77b8994148bc9542";
  };

  nativeBuildInputs = [
    python
  ];

  buildInputs = [
    libpcap
    openssl
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-kernel-switch"
  ];

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc")
  '';

  # Dependencies are not fully specified
  buildParallel = false;
  installParallel = false;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

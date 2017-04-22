{ stdenv
, fetchFromGitHub

, openssl
}:

let
  date = "2017-01-03";
  rev = "94e3bc9dc524cf481387964b22e80f97557e6e27";
in
stdenv.mkDerivation rec {
  name = "open-isns-${date}";

  src = fetchFromGitHub {
    version = 2;
    owner = "open-iscsi";
    repo = "open-isns";
    inherit rev;
    sha256 = "2c6e6c990c5c570889764ed479abef0a4c358c2cf909a6bca783851e4f663af1";
  };

  buildInputs = [
    openssl
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-shared"
    "--with-security"
    #"--with-slp"  # TODO: Maybe enable for service discovery
  ];

  preInstall = ''
    installFlagsArray+=(
      "etcdir=$out/etc"
      "vardir=$TMPDIR"
    )
  '';

  installTargets = [
    "install"
    "install_hdrs"
    "install_lib"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

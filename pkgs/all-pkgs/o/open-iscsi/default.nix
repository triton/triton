{ stdenv
, autoconf
, automake
, fetchFromGitHub
, libtool

, open-isns
, openssl
, util-linux_lib
}:

let
  version = "2.0.874";
in
stdenv.mkDerivation rec {
  name = "open-iscsi-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "open-iscsi";
    repo = "open-iscsi";
    rev = version;
    sha256 = "3d7662f52ac9a112e46afe4e222056cec9460bc0cb717d4820001958696e5e81";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
  ];

  buildInputs = [
    open-isns
    openssl
    util-linux_lib
  ];

  preBuild = ''
    makeFlagsArray+=(
      "prefix=$out"
      "exec_prefix=$out"
    )
  '';

  buildFlags = [
    "user"
  ];

  preInstall = ''
    installFlagsArray+=(
      "etcdir=$out/etc"
    )
  '';

  installTargets = [
    "install_user"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

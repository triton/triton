{ stdenv
, fetchFromGitHub
, makeWrapper
, perl

, dmidecode
, kmod
, sysfsutils
}:

stdenv.mkDerivation {
  name = "edac-utils-2015-07-11";

  src = fetchFromGitHub {
    version = 1;
    owner = "grondo";
    repo = "edac-utils";
    rev = "556ebce6e1a5a8ad8c07090979a36be7a2276e2e";
    sha256 = "7ec7c190afbe475d978a572743c16572126f2a5c813cc2672c4edd2665a9f7f8";
  };

  nativeBuildInputs = [
    makeWrapper
    perl
  ];

  buildInputs = [
    sysfsutils
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc")
  '';

  postInstall = ''
    wrapProgram "$out/sbin/edac-ctl" \
      --set PATH : "" \
      --prefix PATH : "${dmidecode}/bin" \
      --prefix PATH : "${kmod}/bin"
  '';

  meta = with stdenv.lib; {
    description = "Handles the reporting of hardware-related memory errors";
    homepage = http://github.com/grondo/edac-utils;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

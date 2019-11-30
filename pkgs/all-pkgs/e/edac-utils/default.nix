{ stdenv
, fetchFromGitHub
, makeWrapper
, perl

, dmidecode
, kmod
, sysfsutils
}:

stdenv.mkDerivation {
  name = "edac-utils-2015-06-11";

  src = fetchFromGitHub {
    version = 6;
    owner = "grondo";
    repo = "edac-utils";
    rev = "556ebce6e1a5a8ad8c07090979a36be7a2276e2e";
    sha256 = "0850c3a01494bb2dcfd894c3839f086fbd97446e2825e361202edb498f7cbfe5";
  };

  nativeBuildInputs = [
    makeWrapper
    perl
  ];

  buildInputs = [
    sysfsutils
  ];

  postPatch = ''
    patchShebangs configure
  '';

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

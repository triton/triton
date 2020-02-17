{ stdenv
, fetchurl
, makeWrapper

, coreutils_small
}:

stdenv.mkDerivation rec {
  name = "openresolv-3.10.0";

  src = fetchurl {
    url = "mirror://roy/openresolv/${name}.tar.xz";
    multihash = "QmPjFYUCSsbNKFDr2VeWsmuQoVdu1XJegR4vKGLw6FNZ7A";
    sha256 = "4078bc52dee022f4a1c7594045e724af9da5ef16d670e0c08444d1830033ba06";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preInstall = ''
    installFlagsArray+=("SYSCONFDIR=$out/etc")
  '';

  preFixup = ''
    # Scripts calls rm, cat & other executables
    wrapProgram "$out/sbin/resolvconf" \
      --prefix PATH : "${coreutils_small}/bin"
  '';

  meta = with stdenv.lib; {
    description = "A program to manage /etc/resolv.conf";
    homepage = http://roy.marples.name/projects/openresolv;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

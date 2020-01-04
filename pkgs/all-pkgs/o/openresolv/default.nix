{ stdenv
, fetchurl
, makeWrapper

, coreutils_small
}:

stdenv.mkDerivation rec {
  name = "openresolv-3.9.2";

  src = fetchurl {
    url = "mirror://roy/openresolv/${name}.tar.xz";
    multihash = "QmXXyAWmxtiprbaQ5hRaHesJnh3eSTxNqfP2zXGASn4bm8";
    sha256 = "14d7e241682e5566f6b8bf4c7316c86d7a9b8e7ed48e1de4967dbf1ea84ed373";
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

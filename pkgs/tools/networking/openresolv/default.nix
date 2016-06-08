{ stdenv
, fetchurl
, makeWrapper

, coreutils
}:

stdenv.mkDerivation rec {
  name = "openresolv-3.8.1";

  src = fetchurl {
    url = "mirror://roy/openresolv/${name}.tar.xz";
    sha256 = "0hqxvrhc4r310hr59bwi1vbl16my27pdlnbrnbqqihiav67xfnfj";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  configureFlags = [
    "--sysconfdir=/etc"
  ];

  preInstall = ''
    installFlagsArray+=("SYSCONFDIR=$out/etc")
  '';

  postInstall = ''
    wrapProgram "$out/sbin/resolvconf" --set PATH "${coreutils}/bin"
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

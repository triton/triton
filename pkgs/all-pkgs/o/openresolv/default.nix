{ stdenv
, fetchurl
, makeWrapper

, coreutils_small
}:

stdenv.mkDerivation rec {
  name = "openresolv-3.9.1";

  src = fetchurl {
    url = "mirror://roy/openresolv/${name}.tar.xz";
    multihash = "QmPr6tHpbDnfpZ4HYNtYJymzo4yctEm998P6cCVQwT4gZP";
    sha256 = "38b8e7e131a39b1c0d4e5688618b8572adf92a5bf757ae9f272e9f81108a9ff2";
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

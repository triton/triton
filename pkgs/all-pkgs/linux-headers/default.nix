{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "linux-headers-${version}";
  version = "3.18.14";

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v3.x/linux-${version}.tar.xz";
    sha256 = "1xh0vvn1l2g1kkg54f0mg0inbpsiqs24ybgsakksmcpcadjgqk1i";
  };

  buildFlags = [
    "defconfig"
  ];

  preInstall = ''
    installFlagsArray+=("INSTALL_HDR_PATH=$out")
  '';

  installTargets = "headers_install";

  preFixup = ''
    # Cleanup some unneeded files
    find $out/include \( -name .install -o -name ..install.cmd \) -delete
  '';

  meta = with stdenv.lib; {
    description = "Header files and scripts for Linux kernel";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux
      ++ i686-linux;
  };
}

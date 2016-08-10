{ stdenv
, cmake
, fetchpatch
, fetchurl
, ninja

, openssl
, sqlite
, systemd_lib

, stresstestSupport ? false
}:

let
  inherit (stdenv.lib)
    cmFlag;
in

stdenv.mkDerivation rec {
  name = "uhub-${version}";
  version = "0.5.0";

  src = fetchurl {
    url = "https://github.com/janvidar/uhub/archive/${version}.tar.gz";
    sha256 = "8e169aca4efc45c50ccceb537e3013941a118bc4f1a6431531d39603f676262a";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    openssl
    sqlite
    systemd_lib
  ];

  patches = [
    /* Commits to master since 0.5.0 */
    # Remove invalid assertion as \n has length 0
    (fetchpatch {
      url = "https://github.com/janvidar/uhub/commit/"
          + "3f2641595b5f865b2766e4ebd21d10d35485f66a.patch";
      sha256 = "eeb6e00b5c781daeeca5f90277ad973beff21abe050d18e74593048ced41e297";
    })
    # Fix: Chat history sqlite truncating long messages
    (fetchpatch {
      url = "https://github.com/janvidar/uhub/commit/"
          + "5e63ab2ccd1823a9a07c39bd16e562c541938c19.patch";
      sha256 = "88695941c124faf264d073d6fb1ed4fcd53f3dd19bada6a2eb484f63b2ddbef3";
    })
    # Added sqlite VACUUM to cleanup commands
    (fetchpatch {
      url = "https://github.com/janvidar/uhub/commit/"
          + "96cc46117fc5fa11f1f40f94609e91383a1888fe.patch";
      sha256 = "3a9f1f4e124a445a07a970536610dfa3d727b609e54dd7437c25cec8e903f87b";
    })
    # Fixed compilation on systemd > 210
    (fetchpatch {
      url = "https://github.com/janvidar/uhub/commit/"
          + "70f2a43f676cdda5961950a8d9a21e12d34993f8.patch";
      sha256 = "1dbd6c8116cad5dcb5a99006c561f509c6b4729f95a011f3996dc2ef9c1e6b24";
    })
  ];

  postPatch =
    /* Install plugins to $out/lib/uhub/ instead of /usr/lib/uhub/ */ ''
      sed -i CMakeLists.txt \
        -e 's,/usr/lib/uhub/,lib/uhub/,'
    '' +
    /* Install example configs to $out/share/doc/ instead of /etc/uhub */ ''
      sed -i CMakeLists.txt \
        -e 's,/etc/uhub,doc/,'
    '';

  cmakeFlags = [
    "-DSSL_SUPPORT=ON"
    "-DUSE_OPENSSL=ON"
    "-DSYSTEMD_SUPPORT=ON"
    (cmFlag "ADC_STRESS" stresstestSupport)
  ];

  postInstall =
    /* Remove unsupported plugins
     * This build uses sqlite as a backend and does not support
     * plain-text storage */ ''
      rm -fv $out/lib/uhub/mod_auth_simple.so
      rm -fv $out/lib/uhub/mod_chat_history.so
    '' +
    /* Example plugin does nothing */ ''
      rm -fv $out/lib/uhub/mod_example.so
    '';

  meta = with stdenv.lib; {
    description = "High performance ADC (DC++) hub for peer-to-peer networks";
    homepage = https://www.uhub.org/;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

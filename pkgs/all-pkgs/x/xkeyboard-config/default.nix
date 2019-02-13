{ stdenv
, fetchurl
, intltool
, lib
, libxslt
, util-macros

, libx11
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "xkeyboard-config-2.26";

  src = fetchurl {
    url = "mirror://xorg/individual/data/xkeyboard-config/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "393718c7460cd06c4e8cb819d943ca54812ea476f32714c4d8975c77031a038e";
  };

  nativeBuildInputs = [
    intltool
    libxslt
    util-macros
  ];

  configureFlags = [
    "--disable-runtime-deps"
  ];

  postInstall = ''
    mkdir -p "$out"/etc
    ln -sv $out/share/X11 $out/etc
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprints = [
          # Sergey Udaltsov
          "FFB4 CCD2 75AA A422 F5F9  808E 0661 D98F C933 A145"
        ];
      };
    };
  };

  meta = with lib; {
    description = "X keyboard configuration files";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

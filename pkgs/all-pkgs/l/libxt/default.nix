{ stdenv
, fetchurl
, lib
, perl
, util-macros

, libice
, libsm
, libx11
, xorgproto
}:

let
  inherit (lib)
    boolWt;
in
stdenv.mkDerivation rec {
  name = "libXt-1.1.5";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "46eeb6be780211fdd98c5109286618f6707712235fdd19df4ce1e6954f349f1a";
  };

  nativeBuildInputs = [
    perl
    util-macros
  ];

  buildInputs = [
    libice
    libsm
    libx11
    xorgproto
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-specs"
    "--enable-xkb"
    "--disable-unit-tests"
    "--without-xmlto"
    "--without-fop"
    "--without-xsltproc"
    "--${boolWt (perl != null)}-perl"
    "--without-glib"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        # Alan Coopersmith
        "4A19 3C06 D35E 7C67 0FA4  EF0B A2FB 9E08 1F2D 130E"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "X Toolkit Intrinsics library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

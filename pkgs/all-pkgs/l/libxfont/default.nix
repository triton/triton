{ stdenv
, fetchurl
, lib
, util-macros

, bzip2
, freetype
, libfontenc
, xorgproto
, xtrans
, zlib

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt;

  sources = {
    "1" = {
      version = "1.5.4";
      sha256 = "1a7f7490774c87f2052d146d1e0e64518d32e6848184a18654e8d0bb57883242";
    };
    "2" = {
      version = "2.0.3";
      sha256 = "0e8ab7fd737ccdfe87e1f02b55f221f0bd4503a1c5f28be4ed6a54586bac9c4e";
    };
  };

  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "libXfont${if channel == "2" then channel else ""}-${source.version}";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    bzip2
    freetype
    libfontenc
    xorgproto
    xtrans
    zlib
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-devel-docs"
    "--${boolEn (freetype != null)}-freetype"
    "--enable-builtins"
    "--enable-pcfformat"
    "--enable-bdfformat"
    "--enable-snfformat"
    "--enable-fc"
    "--enable-unix-transport"
    "--enable-tcp-transport"
    "--enable-ipv6"
    "--enable-local-transport"
    "--without-xmlto"
    "--without-fop"
    "--${boolWt (bzip2 != null)}-bzip2"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        # Adam Jackson
        "DD38 563A 8A82 2453 7D1F  90E4 5B8A 2D50 A0EC D0D3"
        "995E D5C8 A613 8EB0 961F  1847 4C09 DD83 CAAA 50B2"
        # Keith Packard
        "C383 B778 2556 13DF DB40  9D91 DB22 1A69 0000 0011"
        # Matt Turner
        "3BB6 39E5 6F86 1FA2 E865  0569 0FDD 682D 974C A72A"
        # Matthieu Herrb
        "C41C 985F DCF1 E536 4576  638B 6873 93EE 37D1 28F8"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "X font handling library for server & utilities";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

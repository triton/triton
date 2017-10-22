{ stdenv
, fetchurl
, lib
, util-macros

, bzip2
, fontsproto
, freetype
, libfontenc
, xproto
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
      version = "1.5.3";
      sha256 = "ab85c10fd2683481dfef672a77fe60e6a2039558cbc0e9bf56b5e1df471c93d0";
    };
    "2" = {
      version = "2.0.2";
      sha256 = "94088d3b87f7d42c7116d9adaad155859e93330c6e47f5989f2de600b9a6c111";
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
    fontsproto
    freetype
    libfontenc
    xproto
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

# THIS IS A GENERATED FILE.  DO NOT EDIT!
args @ { fetchurl, fetchzip, fetchpatch, stdenv, pkgconfig, intltool, freetype, fontconfig
, libxslt, expat, libpng, zlib, perl, opengl-dummy, spice-protocol, spice
, dbus, util-linux_lib, openssl, gperf, gnum4, tradcpp, libinput, mcpp, makeWrapper, autoreconfHook
, autoconf, automake, libtool, xmlto, flex, bison, python, cairo, glib
, libepoxy, wayland, libbsd, systemd_lib, gettext, pciutils, python3, kmod, procps-ng
, python3Packages

, bdftopcf
, fontcacheproto
, libdmx
, libfontenc
, libice
, libpciaccess
, libpthread-stubs
, libsm
, libx11
, libxau
, libxcb
, libxcomposite
, libxcursor
, libxdamage
, libxdmcp
, libxext
, libxfixes
, libxfont
, libxfont2
, libxft
, libxi
, libxinerama
, libxkbfile
, libxmu
, libxrandr
, libxrender
, libxres
, libxscrnsaver
, libxshmfence
, libxt
, libxtst
, libxv
, util-macros
, xf86-video-amdgpu
, xf86-video-intel
, xfs
, xkbcomp
, xkeyboard-config
, xorg-server
, xorgproto
, xrefresh
, xtrans
, xwininfo

, ... }: with args;

let

  mkDerivation = name: attrs:
    let newAttrs = (overrides."${name}" or (x: x)) attrs;
        stdenv = newAttrs.stdenv or args.stdenv;
    in stdenv.mkDerivation (removeAttrs newAttrs [ "stdenv" ] // {
      builder = ./builder.sh;
      postPatch = (attrs.postPatch or "") + ''
        patchShebangs .
      '';
      meta.platforms = with stdenv.lib.platforms;
        x86_64-linux;
	});

  overrides = import ./overrides.nix {inherit args xorg;};

  xorg = rec {

    inherit
      fontcacheproto
      libdmx
      libfontenc
      libpciaccess
      libxcb
      libxkbfile
      libxshmfence
      xfs
      xkbcomp
      xorgproto
      xrefresh
      xtrans
      xwininfo;

    libICE = libice;
    libpthreadstubs = libpthread-stubs;
    libSM = libsm;
    libX11 = libx11;
    libXau = libxau;
    libXcomposite = libxcomposite;
    libXcursor = libxcursor;
    libXdamage = libxdamage;
    libXdmcp = libxdmcp;
    libXext = libxext;
    libXfixes = libxfixes;
    libXfont = libxfont;
    libXfont2 = libxfont2;
    libXft = libxft;
    libXi = libxi;
    libXinerama = libxinerama;
    libXrandr = libxrandr;
    libXrender = libxrender;
    libXres = libxres;
    libXScrnSaver = libxscrnsaver;
    libXt = libxt;
    libXtst = libxtst;
    libXv = libxv;
    utilmacros = util-macros;
    xf86videoamdgpu = xf86-video-amdgpu;
    xf86videointel = xf86-video-intel;
    xkeyboardconfig = xkeyboard-config;
    xorgserver = xorg-server;

################################################################################

  # encodings = (mkDerivation "encodings" {
  #   name = "encodings-1.0.4";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/encodings-1.0.4.tar.bz2;
  #     sha256 = "0ffmaw80vmfwdgvdkp6495xgsqszb6s0iira5j0j6pd4i0lk3mnf";
  #   };
  #   nativeBuildInputs = [ utilmacros ];
  #   buildInputs = [ ];
  #
  # }) // {inherit ;};

  # evieext = (mkDerivation "evieext" {
  #   name = "evieext-1.1.1";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/proto/evieext-1.1.1.tar.bz2;
  #     sha256 = "1zik4xcvm6hppd13irn9520ip8rblcw682x9fxjzb6bd8ca43xqw";
  #   };
  #   nativeBuildInputs = [ utilmacros ];
  #   buildInputs = [ ];
  #
  # }) // {inherit ;};

  fontadobe100dpi = (mkDerivation "fontadobe100dpi" {
    name = "font-adobe-100dpi-1.0.3";
    src = fetchurl {
      url = mirror://xorg/individual/font/font-adobe-100dpi-1.0.3.tar.bz2;
      sha256 = "0m60f5bd0caambrk8ksknb5dks7wzsg7g7xaf0j21jxmx8rq9h5j";
    };
    nativeBuildInputs = [ bdftopcf fontutil mkfontdir mkfontscale utilmacros ];
    buildInputs = [ ];
    configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];

  }) // {inherit ;};

  fontadobe75dpi = (mkDerivation "fontadobe75dpi" {
    name = "font-adobe-75dpi-1.0.3";
    src = fetchurl {
      url = mirror://xorg/individual/font/font-adobe-75dpi-1.0.3.tar.bz2;
      sha256 = "02advcv9lyxpvrjv8bjh1b797lzg6jvhipclz49z8r8y98g4l0n6";
    };
    nativeBuildInputs = [ bdftopcf fontutil mkfontdir mkfontscale utilmacros ];
    buildInputs = [ ];
    configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];

  }) // {inherit ;};

  # fontadobeutopia100dpi = (mkDerivation "fontadobeutopia100dpi" {
  #   name = "font-adobe-utopia-100dpi-1.0.4";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-adobe-utopia-100dpi-1.0.4.tar.bz2;
  #     sha256 = "19dd9znam1ah72jmdh7i6ny2ss2r6m21z9v0l43xvikw48zmwvyi";
  #   };
  #   nativeBuildInputs = [ bdftopcf fontutil mkfontdir mkfontscale utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontadobeutopia75dpi = (mkDerivation "fontadobeutopia75dpi" {
  #   name = "font-adobe-utopia-75dpi-1.0.4";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-adobe-utopia-75dpi-1.0.4.tar.bz2;
  #     sha256 = "152wigpph5wvl4k9m3l4mchxxisgsnzlx033mn5iqrpkc6f72cl7";
  #   };
  #   nativeBuildInputs = [ bdftopcf fontutil mkfontdir mkfontscale utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontadobeutopiatype1 = (mkDerivation "fontadobeutopiatype1" {
  #   name = "font-adobe-utopia-type1-1.0.4";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-adobe-utopia-type1-1.0.4.tar.bz2;
  #     sha256 = "0xw0pdnzj5jljsbbhakc6q9ha2qnca1jr81zk7w70yl9bw83b54p";
  #   };
  #   nativeBuildInputs = [ mkfontdir mkfontscale utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  fontalias = (mkDerivation "fontalias" {
    name = "font-alias-1.0.3";
    src = fetchurl {
      url = mirror://xorg/individual/font/font-alias-1.0.3.tar.bz2;
      sha256 = "16ic8wfwwr3jicaml7b5a0sk6plcgc1kg84w02881yhwmqm3nicb";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ ];

  }) // {inherit ;};

  # fontarabicmisc = (mkDerivation "fontarabicmisc" {
  #   name = "font-arabic-misc-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-arabic-misc-1.0.3.tar.bz2;
  #     sha256 = "1x246dfnxnmflzf0qzy62k8jdpkb6jkgspcjgbk8jcq9lw99npah";
  #   };
  #   nativeBuildInputs = [ bdftopcf mkfontdir utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  fontbh100dpi = (mkDerivation "fontbh100dpi" {
    name = "font-bh-100dpi-1.0.3";
    src = fetchurl {
      url = mirror://xorg/individual/font/font-bh-100dpi-1.0.3.tar.bz2;
      sha256 = "10cl4gm38dw68jzln99ijix730y7cbx8np096gmpjjwff1i73h13";
    };
    nativeBuildInputs = [ bdftopcf fontutil mkfontdir mkfontscale utilmacros ];
    buildInputs = [ ];
    configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];

  }) // {inherit ;};

  # fontbh75dpi = (mkDerivation "fontbh75dpi" {
  #   name = "font-bh-75dpi-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-bh-75dpi-1.0.3.tar.bz2;
  #     sha256 = "073jmhf0sr2j1l8da97pzsqj805f7mf9r2gy92j4diljmi8sm1il";
  #   };
  #   nativeBuildInputs = [ bdftopcf fontutil mkfontdir mkfontscale utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  fontbhlucidatypewriter100dpi = (mkDerivation "fontbhlucidatypewriter100dpi" {
    name = "font-bh-lucidatypewriter-100dpi-1.0.3";
    src = fetchurl {
      url = mirror://xorg/individual/font/font-bh-lucidatypewriter-100dpi-1.0.3.tar.bz2;
      sha256 = "1fqzckxdzjv4802iad2fdrkpaxl4w0hhs9lxlkyraq2kq9ik7a32";
    };
    nativeBuildInputs = [ bdftopcf fontutil mkfontdir mkfontscale utilmacros ];
    buildInputs = [ ];
    configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];

  }) // {inherit ;};

  fontbhlucidatypewriter75dpi = (mkDerivation "fontbhlucidatypewriter75dpi" {
    name = "font-bh-lucidatypewriter-75dpi-1.0.3";
    src = fetchurl {
      url = mirror://xorg/individual/font/font-bh-lucidatypewriter-75dpi-1.0.3.tar.bz2;
      sha256 = "0cfbxdp5m12cm7jsh3my0lym9328cgm7fa9faz2hqj05wbxnmhaa";
    };
    nativeBuildInputs = [ bdftopcf fontutil mkfontdir mkfontscale utilmacros ];
    buildInputs = [ ];
    configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];

  }) // {inherit ;};

  fontbhttf = (mkDerivation "fontbhttf" {
    name = "font-bh-ttf-1.0.3";
    src = fetchurl {
      url = mirror://xorg/individual/font/font-bh-ttf-1.0.3.tar.bz2;
      sha256 = "0pyjmc0ha288d4i4j0si4dh3ncf3jiwwjljvddrb0k8v4xiyljqv";
    };
    nativeBuildInputs = [ mkfontdir mkfontscale utilmacros ];
    buildInputs = [ ];
    configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];

  }) // {inherit ;};

  # fontbhtype1 = (mkDerivation "fontbhtype1" {
  #   name = "font-bh-type1-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-bh-type1-1.0.3.tar.bz2;
  #     sha256 = "1hb3iav089albp4sdgnlh50k47cdjif9p4axm0kkjvs8jyi5a53n";
  #   };
  #   nativeBuildInputs = [ mkfontdir mkfontscale utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontbitstream100dpi = (mkDerivation "fontbitstream100dpi" {
  #   name = "font-bitstream-100dpi-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-bitstream-100dpi-1.0.3.tar.bz2;
  #     sha256 = "1kmn9jbck3vghz6rj3bhc3h0w6gh0qiaqm90cjkqsz1x9r2dgq7b";
  #   };
  #   nativeBuildInputs = [ bdftopcf mkfontdir utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontbitstream75dpi = (mkDerivation "fontbitstream75dpi" {
  #   name = "font-bitstream-75dpi-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-bitstream-75dpi-1.0.3.tar.bz2;
  #     sha256 = "13plbifkvfvdfym6gjbgy9wx2xbdxi9hfrl1k22xayy02135wgxs";
  #   };
  #   nativeBuildInputs = [ bdftopcf mkfontdir utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontbitstreamspeedo = (mkDerivation "fontbitstreamspeedo" {
  #   name = "font-bitstream-speedo-1.0.2";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-bitstream-speedo-1.0.2.tar.bz2;
  #     sha256 = "0qv7sxrvfgzjplj0czq8vzf425w6iapl8n5mhb08hywl8q0gw207";
  #   };
  #   nativeBuildInputs = [ mkfontdir mkfontscale utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontbitstreamtype1 = (mkDerivation "fontbitstreamtype1" {
  #   name = "font-bitstream-type1-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-bitstream-type1-1.0.3.tar.bz2;
  #     sha256 = "1256z0jhcf5gbh1d03593qdwnag708rxqa032izmfb5dmmlhbsn6";
  #   };
  #   nativeBuildInputs = [ mkfontdir mkfontscale utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontcronyxcyrillic = (mkDerivation "fontcronyxcyrillic" {
  #   name = "font-cronyx-cyrillic-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-cronyx-cyrillic-1.0.3.tar.bz2;
  #     sha256 = "0ai1v4n61k8j9x2a1knvfbl2xjxk3xxmqaq3p9vpqrspc69k31kf";
  #   };
  #   nativeBuildInputs = [ bdftopcf mkfontdir utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  fontcursormisc = (mkDerivation "fontcursormisc" {
    name = "font-cursor-misc-1.0.3";
    src = fetchurl {
      url = mirror://xorg/individual/font/font-cursor-misc-1.0.3.tar.bz2;
      sha256 = "0dd6vfiagjc4zmvlskrbjz85jfqhf060cpys8j0y1qpcbsrkwdhp";
    };
    nativeBuildInputs = [ bdftopcf mkfontdir utilmacros ];
    buildInputs = [ ];
    configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];

  }) // {inherit ;};

  # fontdaewoomisc = (mkDerivation "fontdaewoomisc" {
  #   name = "font-daewoo-misc-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-daewoo-misc-1.0.3.tar.bz2;
  #     sha256 = "1s2bbhizzgbbbn5wqs3vw53n619cclxksljvm759h9p1prqdwrdw";
  #   };
  #   nativeBuildInputs = [ bdftopcf mkfontdir utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontdecmisc = (mkDerivation "fontdecmisc" {
  #   name = "font-dec-misc-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-dec-misc-1.0.3.tar.bz2;
  #     sha256 = "0yzza0l4zwyy7accr1s8ab7fjqkpwggqydbm2vc19scdby5xz7g1";
  #   };
  #   nativeBuildInputs = [ bdftopcf mkfontdir utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontibmtype1 = (mkDerivation "fontibmtype1" {
  #   name = "font-ibm-type1-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-ibm-type1-1.0.3.tar.bz2;
  #     sha256 = "1pyjll4adch3z5cg663s6vhi02k8m6488f0mrasg81ssvg9jinzx";
  #   };
  #   nativeBuildInputs = [ mkfontdir mkfontscale utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontisasmisc = (mkDerivation "fontisasmisc" {
  #   name = "font-isas-misc-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-isas-misc-1.0.3.tar.bz2;
  #     sha256 = "0rx8q02rkx673a7skkpnvfkg28i8gmqzgf25s9yi0lar915sn92q";
  #   };
  #   nativeBuildInputs = [ bdftopcf mkfontdir utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontjismisc = (mkDerivation "fontjismisc" {
  #   name = "font-jis-misc-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-jis-misc-1.0.3.tar.bz2;
  #     sha256 = "0rdc3xdz12pnv951538q6wilx8mrdndpkphpbblszsv7nc8cw61b";
  #   };
  #   nativeBuildInputs = [ bdftopcf mkfontdir utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontmicromisc = (mkDerivation "fontmicromisc" {
  #   name = "font-micro-misc-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-micro-misc-1.0.3.tar.bz2;
  #     sha256 = "1dldxlh54zq1yzfnrh83j5vm0k4ijprrs5yl18gm3n9j1z0q2cws";
  #   };
  #   nativeBuildInputs = [ bdftopcf mkfontdir utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontmisccyrillic = (mkDerivation "fontmisccyrillic" {
  #   name = "font-misc-cyrillic-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-misc-cyrillic-1.0.3.tar.bz2;
  #     sha256 = "0q2ybxs8wvylvw95j6x9i800rismsmx4b587alwbfqiw6biy63z4";
  #   };
  #   nativeBuildInputs = [ bdftopcf mkfontdir utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontmiscethiopic = (mkDerivation "fontmiscethiopic" {
  #   name = "font-misc-ethiopic-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-misc-ethiopic-1.0.3.tar.bz2;
  #     sha256 = "19cq7iq0pfad0nc2v28n681fdq3fcw1l1hzaq0wpkgpx7bc1zjsk";
  #   };
  #   nativeBuildInputs = [ mkfontdir mkfontscale utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontmiscmeltho = (mkDerivation "fontmiscmeltho" {
  #   name = "font-misc-meltho-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-misc-meltho-1.0.3.tar.bz2;
  #     sha256 = "148793fqwzrc3bmh2vlw5fdiwjc2n7vs25cic35gfp452czk489p";
  #   };
  #   nativeBuildInputs = [ mkfontdir mkfontscale utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  fontmiscmisc = (mkDerivation "fontmiscmisc" {
    name = "font-misc-misc-1.1.2";
    src = fetchurl {
      url = mirror://xorg/individual/font/font-misc-misc-1.1.2.tar.bz2;
      sha256 = "150pq6n8n984fah34n3k133kggn9v0c5k07igv29sxp1wi07krxq";
    };
    nativeBuildInputs = [ bdftopcf fontutil mkfontdir mkfontscale utilmacros ];
    buildInputs = [ ];
    configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];

  }) // {inherit ;};

  # fontmuttmisc = (mkDerivation "fontmuttmisc" {
  #   name = "font-mutt-misc-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-mutt-misc-1.0.3.tar.bz2;
  #     sha256 = "13qghgr1zzpv64m0p42195k1kc77pksiv059fdvijz1n6kdplpxx";
  #   };
  #   nativeBuildInputs = [ bdftopcf mkfontdir utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontschumachermisc = (mkDerivation "fontschumachermisc" {
  #   name = "font-schumacher-misc-1.1.2";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-schumacher-misc-1.1.2.tar.bz2;
  #     sha256 = "0nkym3n48b4v36y4s927bbkjnsmicajarnf6vlp7wxp0as304i74";
  #   };
  #   nativeBuildInputs = [ bdftopcf fontutil mkfontdir mkfontscale utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontscreencyrillic = (mkDerivation "fontscreencyrillic" {
  #   name = "font-screen-cyrillic-1.0.4";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-screen-cyrillic-1.0.4.tar.bz2;
  #     sha256 = "0yayf1qlv7irf58nngddz2f1q04qkpr5jwp4aja2j5gyvzl32hl2";
  #   };
  #   nativeBuildInputs = [ bdftopcf mkfontdir utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontsonymisc = (mkDerivation "fontsonymisc" {
  #   name = "font-sony-misc-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-sony-misc-1.0.3.tar.bz2;
  #     sha256 = "1xfgcx4gsgik5mkgkca31fj3w72jw9iw76qyrajrsz1lp8ka6hr0";
  #   };
  #   nativeBuildInputs = [ bdftopcf mkfontdir utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontsunmisc = (mkDerivation "fontsunmisc" {
  #   name = "font-sun-misc-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-sun-misc-1.0.3.tar.bz2;
  #     sha256 = "1q6jcqrffg9q5f5raivzwx9ffvf7r11g6g0b125na1bhpz5ly7s8";
  #   };
  #   nativeBuildInputs = [ bdftopcf mkfontdir utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fonttosfnt = (mkDerivation "fonttosfnt" {
  #   name = "fonttosfnt-1.0.4";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/app/fonttosfnt-1.0.4.tar.bz2;
  #     sha256 = "157mf1j790pnsx2lhybkpcpmprpx83fjbixxp3lwgydkk6samsiz";
  #   };
  #   nativeBuildInputs = [ ];
  #   buildInputs = [ libfontenc freetype xproto ];
  #
  # }) // {inherit libfontenc freetype xproto ;};

  fontutil = (mkDerivation "fontutil" {
    name = "font-util-1.3.1";
    src = fetchurl {
      url = mirror://xorg/individual/font/font-util-1.3.1.tar.bz2;
      sha256 = "08drjb6cf84pf5ysghjpb4i7xkd2p86k3wl2a0jxs1jif6qbszma";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ ];

  }) // {inherit ;};

  # fontwinitzkicyrillic = (mkDerivation "fontwinitzkicyrillic" {
  #   name = "font-winitzki-cyrillic-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-winitzki-cyrillic-1.0.3.tar.bz2;
  #     sha256 = "181n1bgq8vxfxqicmy1jpm1hnr6gwn1kdhl6hr4frjigs1ikpldb";
  #   };
  #   nativeBuildInputs = [ bdftopcf mkfontdir utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  # fontxfree86type1 = (mkDerivation "fontxfree86type1" {
  #   name = "font-xfree86-type1-1.0.4";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/font/font-xfree86-type1-1.0.4.tar.bz2;
  #     sha256 = "0jp3zc0qfdaqfkgzrb44vi9vi0a8ygb35wp082yz7rvvxhmg9sya";
  #   };
  #   nativeBuildInputs = [ mkfontdir mkfontscale utilmacros ];
  #   buildInputs = [ ];
  #   configureFlags = [ "--with-fontrootdir=$(out)/lib/X11/fonts" ];
  #
  # }) // {inherit ;};

  glamoregl = (mkDerivation "glamoregl" {
    name = "glamor-egl-0.6.0";
    src = fetchurl {
      url = mirror://xorg/individual/driver/glamor-egl-0.6.0.tar.bz2;
      sha256 = "1jg5clihklb9drh1jd7nhhdsszla6nv7xmbvm8yvakh5wrb1nlv6";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ xorgproto opengl-dummy libdrm libpciaccess xorgserver ];

  }) // {inherit xorgproto opengl-dummy libdrm xorgserver ;};

  # ico = (mkDerivation "ico" {
  #   name = "ico-1.0.4";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/app/ico-1.0.4.tar.bz2;
  #     sha256 = "141mqphg9sfz7x1gfiqpkjkqkiqq1b5zxw67l0ls2p7rk1q7cci9";
  #   };
  #   nativeBuildInputs = [ utilmacros ];
  #   buildInputs = [ libX11 xproto ];
  #
  # }) // {inherit libX11 xproto ;};

  imake = (mkDerivation "imake" {
    name = "imake-1.0.7";
    src = fetchurl {
      url = mirror://xorg/individual/util/imake-1.0.7.tar.bz2;
      sha256 = "0zpk8p044jh14bis838shbf4100bjg7mccd7bq54glpsq552q339";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ xorgproto ];

  }) // {inherit xorgproto ;};

  # libFS = (mkDerivation "libFS" {
  #   name = "libFS-1.0.7";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/lib/libFS-1.0.7.tar.bz2;
  #     sha256 = "1wy4km3qwwajbyl8y9pka0zwizn7d9pfiyjgzba02x3a083lr79f";
  #   };
  #   nativeBuildInputs = [ utilmacros ];
  #   buildInputs = [ fontsproto xproto xtrans ];
  #
  # }) // {inherit fontsproto xproto xtrans ;};

  # libXTrap = (mkDerivation "libXTrap" {
  #   name = "libXTrap-1.0.1";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/lib/libXTrap-1.0.1.tar.bz2;
  #     sha256 = "0bi5wxj6avim61yidh9fd3j4n8czxias5m8vss9vhxjnk1aksdwg";
  #   };
  #   nativeBuildInputs = [ utilmacros ];
  #   buildInputs = [ trapproto libX11 libXext xextproto libXt ];
  #
  # }) // {inherit trapproto libX11 libXext xextproto libXt ;};

  libXaw = (mkDerivation "libXaw" {
    name = "libXaw-1.0.13";
    src = fetchurl {
      url = mirror://xorg/individual/lib/libXaw-1.0.13.tar.bz2;
      sha256 = "1kdhxplwrn43d9jp3v54llp05kwx210lrsdvqb6944jp29rhdy4f";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libX11 libXext xorgproto libxmu libXpm libXt ];

  }) // {inherit libX11 libXext xorgproto libxmu libXpm libXt ;};

  libXaw3d = (mkDerivation "libXaw3d" {
    name = "libXaw3d-1.6.2";
    src = fetchurl {
      url = mirror://xorg/individual/lib/libXaw3d-1.6.2.tar.bz2;
      sha256 = "0awplv1nf53ywv01yxphga3v6dcniwqnxgnb0cn4khb121l12kxp";
    };
    nativeBuildInputs = [ bison flex utilmacros ];
    buildInputs = [ libX11 libXext libxmu libXpm xorgproto libXt ];

  }) // {inherit libX11 libXext libxmu libXpm xorgproto libXt ;};

  # libXevie = (mkDerivation "libXevie" {
  #   name = "libXevie-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/lib/libXevie-1.0.3.tar.bz2;
  #     sha256 = "0wzx8ic38rj2v53ax4jz1rk39idy3r3m1apc7idmk3z54chkh2y0";
  #   };
  #   nativeBuildInputs = [ utilmacros ];
  #   buildInputs = [ evieext libX11 libXext xextproto xproto ];
  #
  # }) // {inherit evieext libX11 libXext xextproto xproto ;};

  libXfontcache = (mkDerivation "libXfontcache" {
    name = "libXfontcache-1.0.5";
    src = fetchurl {
      url = mirror://xorg/individual/lib/libXfontcache-1.0.5.tar.bz2;
      sha256 = "1knbzagrisr68r7l7cv6iriw3rhkblzkh524dc7gllczahcr4qqd";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ fontcacheproto libX11 libXext xorgproto ];

  }) // {inherit fontcacheproto libX11 libXext xorgproto ;};

  # libXp = (mkDerivation "libXp" {
  #   name = "libXp-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/lib/libXp-1.0.3.tar.bz2;
  #     sha256 = "0mwc2jwmq03b1m9ihax5c6gw2ln8rc70zz4fsj3kb7440nchqdkz";
  #   };
  #   nativeBuildInputs = [ utilmacros ];
  #   buildInputs = [ printproto libX11 libXau libXext xextproto ];
  #
  # }) // {inherit printproto libX11 libXau libXext xextproto ;};

  libXpm = (mkDerivation "libXpm" {
    name = "libXpm-3.5.12";
    src = fetchurl {
      url = mirror://xorg/individual/lib/libXpm-3.5.12.tar.bz2;
      sha256 = "fd6a6de3da48de8d1bb738ab6be4ad67f7cb0986c39bd3f7d51dd24f7854bdec";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libX11 libXext xorgproto libXt ];

  }) // {inherit libX11 libXext xorgproto libXt ;};

  # libXprintAppUtil = (mkDerivation "libXprintAppUtil" {
  #   name = "libXprintAppUtil-1.0.1";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/lib/libXprintAppUtil-1.0.1.tar.bz2;
  #     sha256 = "198ad7pmkp31vcs0iwd8z3vw08p69hlyjmzgk7sdny9k01368q14";
  #   };
  #   nativeBuildInputs = [ ];
  #   buildInputs = [ printproto libX11 libXau libXp libXprintUtil xproto ];
  #
  # }) // {inherit printproto libX11 libXau libXp libXprintUtil xproto ;};

  # libXprintUtil = (mkDerivation "libXprintUtil" {
  #   name = "libXprintUtil-1.0.1";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/lib/libXprintUtil-1.0.1.tar.bz2;
  #     sha256 = "0v3fh9fqgravl8xl509swwd9a2v7iw38szhlpraiyq5r402axdkj";
  #   };
  #   nativeBuildInputs = [ ];
  #   buildInputs = [ printproto libX11 libXau libXp libXt ];
  #
  # }) // {inherit printproto libX11 libXau libXp libXt ;};

  libXvMC = (mkDerivation "libXvMC" {
    name = "libXvMC-1.0.10";
    src = fetchurl {
      url = mirror://xorg/individual/lib/libXvMC-1.0.10.tar.bz2;
      sha256 = "0bpffxr5dal90a8miv2w0rif61byqxq2f5angj4z1bnznmws00g5";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ xorgproto libX11 libXext libXv ];

  }) // {inherit xorgproto libX11 libXext libXv ;};

  libXxf86dga = (mkDerivation "libXxf86dga" {
    name = "libXxf86dga-1.1.4";
    src = fetchurl {
      url = mirror://xorg/individual/lib/libXxf86dga-1.1.4.tar.bz2;
      sha256 = "0zn7aqj8x0951d8zb2h2andldvwkzbsc4cs7q023g6nzq6vd9v4f";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libX11 libXext xorgproto ];

  }) // {inherit libX11 libXext xorgproto ;};

  libXxf86misc = (mkDerivation "libXxf86misc" {
    name = "libXxf86misc-1.0.4";
    src = fetchurl {
      url = mirror://xorg/individual/lib/libXxf86misc-1.0.4.tar.bz2;
      sha256 = "a89c03e2b0f16239d67a2031b9003f31b5a686106bbdb3c797fb88ae472af380";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libX11 libXext xorgproto ];

  }) // {inherit libX11 libXext xorgproto ;};

  libXxf86vm = (mkDerivation "libXxf86vm" {
    name = "libXxf86vm-1.1.4";
    src = fetchurl {
      url = mirror://xorg/individual/lib/libXxf86vm-1.1.4.tar.bz2;
      sha256 = "0mydhlyn72i7brjwypsqrpkls3nm6vxw0li8b2nw0caz7kwjgvmg";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libX11 libXext xorgproto ];

  }) // {inherit libX11 libXext xorgproto ;};

  lndir = (mkDerivation "lndir" {
    name = "lndir-1.0.3";
    src = fetchurl {
      url = mirror://xorg/individual/util/lndir-1.0.3.tar.bz2;
      sha256 = "0pdngiy8zdhsiqx2am75yfcl36l7kd7d7nl0rss8shcdvsqgmx29";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ xorgproto ];

  }) // {inherit xorgproto ;};

  # luit = (mkDerivation "luit" {
  #   name = "luit-1.1.1";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/app/luit-1.1.1.tar.bz2;
  #     sha256 = "0dn694mk56x6hdk6y9ylx4f128h5jcin278gnw2gb807rf3ygc1h";
  #   };
  #   nativeBuildInputs = [ utilmacros ];
  #   buildInputs = [ libfontenc ];
  #
  # }) // {inherit libfontenc ;};

  makedepend = (mkDerivation "makedepend" {
    name = "makedepend-1.0.5";
    src = fetchurl {
      url = mirror://xorg/individual/util/makedepend-1.0.5.tar.bz2;
      sha256 = "09alw99r6y2bbd1dc786n3jfgv4j520apblyn7cw6jkjydshba7p";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ xorgproto ];

  }) // {inherit xorgproto ;};

  mkfontdir = (mkDerivation "mkfontdir" {
    name = "mkfontdir-1.0.7";
    src = fetchurl {
      url = mirror://xorg/individual/app/mkfontdir-1.0.7.tar.bz2;
      sha256 = "0c3563kw9fg15dpgx4dwvl12qz6sdqdns1pxa574hc7i5m42mman";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ ];

  }) // {inherit ;};

  mkfontscale = (mkDerivation "mkfontscale" {
    name = "mkfontscale-1.1.2";
    src = fetchurl {
      url = mirror://xorg/individual/app/mkfontscale-1.1.2.tar.bz2;
      sha256 = "081z8lwh9c1gyrx3ad12whnpv3jpfbqsc366mswpfm48mwl54vcc";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libfontenc freetype xorgproto zlib ];

  }) // {inherit libfontenc freetype xorgproto zlib ;};

  pixman = (mkDerivation "pixman" {
    name = "pixman-0.38.0";
    src = fetchurl {
      url = mirror://xorg/individual/lib/pixman-0.38.0.tar.bz2;
      sha256 = "b768e3f7895ddebdc0f07478729d9cec4fe0a9d2201f828c900d67b0e5b436a8";
    };
    nativeBuildInputs = [ ];
    buildInputs = [ libpng ];

  }) // {inherit libpng ;};

  setxkbmap = (mkDerivation "setxkbmap" {
    name = "setxkbmap-1.3.1";
    src = fetchurl {
      url = mirror://xorg/individual/app/setxkbmap-1.3.1.tar.bz2;
      sha256 = "1qfk097vjysqb72pq89h0la3462kbb2dh1d11qzs2fr67ybb7pd9";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libX11 libxkbfile ];

  }) // {inherit libX11 libxkbfile ;};

  xauth = (mkDerivation "xauth" {
    name = "xauth-1.0.10";
    src = fetchurl {
      url = mirror://xorg/individual/app/xauth-1.0.10.tar.bz2;
      sha256 = "5afe42ce3cdf4f60520d1658d2b17face45c74050f39af45dccdc95e73fafc4d";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libX11 libXau libXext libxmu xorgproto ];

  }) // {inherit libX11 libXau libXext libxmu xorgproto ;};

  xbacklight = (mkDerivation "xbacklight" {
    name = "xbacklight-1.2.1";
    src = fetchurl {
      url = mirror://xorg/individual/app/xbacklight-1.2.1.tar.bz2;
      sha256 = "0arnd1j8vzhzmw72mqhjjcb2qwcbs9qphsy3ps593ajyld8wzxhp";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libxcb xcbutil ];

  }) // {inherit libxcb xcbutil ;};

  xcbutil = (mkDerivation "xcbutil" {
    name = "xcb-util-0.4.0";
    src = fetchurl {
      url = mirror://xorg/individual/xcb/xcb-util-0.4.0.tar.bz2;
      sha256 = "1sahmrgbpyki4bb72hxym0zvxwnycmswsxiisgqlln9vrdlr9r26";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libxcb ];

  }) // {inherit libxcb ;};

  xcbutilerrors = (mkDerivation "xcbutilerrors" {
    name = "xcb-util-errors-1.0";
    src = fetchurl {
      url = mirror://xorg/individual/xcb/xcb-util-errors-1.0.tar.bz2;
      sha256 = "682681769e818ba085870d1ccd65f1f282ca16ca7d6f0f73ee70bc3642aa1995";
    };
    nativeBuildInputs = [ gnum4 utilmacros ];
    buildInputs = [ libxcb python3Packages.xcb-proto ];
  }) // {inherit libxcb ;};

  xcbutilimage = (mkDerivation "xcbutilimage" {
    name = "xcb-util-image-0.4.0";
    src = fetchurl {
      url = mirror://xorg/individual/xcb/xcb-util-image-0.4.0.tar.bz2;
      sha256 = "1z1gxacg7q4cw6jrd26gvi5y04npsyavblcdad1xccc8swvnmf9d";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libxcb xcbutil xorgproto ];

  }) // {inherit libxcb xcbutil xorgproto ;};

  xcbutilkeysyms = (mkDerivation "xcbutilkeysyms" {
    name = "xcb-util-keysyms-0.4.0";
    src = fetchurl {
      url = mirror://xorg/individual/xcb/xcb-util-keysyms-0.4.0.tar.bz2;
      sha256 = "1nbd45pzc1wm6v5drr5338j4nicbgxa5hcakvsvm5pnyy47lky0f";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libxcb xorgproto ];

  }) // {inherit libxcb xorgproto ;};

  xcbutilrenderutil = (mkDerivation "xcbutilrenderutil" {
    name = "xcb-util-renderutil-0.3.9";
    src = fetchurl {
      url = mirror://xorg/individual/xcb/xcb-util-renderutil-0.3.9.tar.bz2;
      sha256 = "0nza1csdvvxbmk8vgv8vpmq7q8h05xrw3cfx9lwxd1hjzd47xsf6";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libxcb ];

  }) // {inherit libxcb ;};

  xcbutilwm = (mkDerivation "xcbutilwm" {
    name = "xcb-util-wm-0.4.1";
    src = fetchurl {
      url = mirror://xorg/individual/xcb/xcb-util-wm-0.4.1.tar.bz2;
      sha256 = "0gra7hfyxajic4mjd63cpqvd20si53j1q3rbdlkqkahfciwq3gr8";
    };
    nativeBuildInputs = [ gnum4 utilmacros ];
    buildInputs = [ libxcb ];

  }) // {inherit libxcb ;};

  xcompmgr = (mkDerivation "xcompmgr" {
    name = "xcompmgr-1.1.7";
    src = fetchurl {
      url = mirror://xorg/individual/app/xcompmgr-1.1.7.tar.bz2;
      sha256 = "14k89mz13jxgp4h2pz0yq0fbkw1lsfcb3acv8vkknc9i4ld9n168";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libXcomposite libXdamage libXext libXfixes libXrender ];

  }) // {inherit libXcomposite libXdamage libXext libXfixes libXrender ;};

  # xcursorgen = (mkDerivation "xcursorgen" {
  #   name = "xcursorgen-1.0.6";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/app/xcursorgen-1.0.6.tar.bz2;
  #     sha256 = "0v7nncj3kaa8c0524j7ricdf4rvld5i7c3m6fj55l5zbah7r3j1i";
  #   };
  #   nativeBuildInputs = [ utilmacros ];
  #   buildInputs = [ libpng libX11 libXcursor ];
  #
  # }) // {inherit libpng libX11 libXcursor ;};

  # xcursorthemes = (mkDerivation "xcursorthemes" {
  #   name = "xcursor-themes-1.0.4";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/data/xcursor-themes-1.0.4.tar.bz2;
  #     sha256 = "11mv661nj1p22sqkv87ryj2lcx4m68a04b0rs6iqh3fzp42jrzg3";
  #   };
  #   nativeBuildInputs = [ utilmacros ];
  #   buildInputs = [ libXcursor ];
  #
  # }) // {inherit libXcursor ;};

  # xf86dga = (mkDerivation "xf86dga" {
  #   name = "xf86dga-1.0.3";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/app/xf86dga-1.0.3.tar.bz2;
  #     sha256 = "0lm2wrsgzc1g97phm428bkn42zm0np77prdp6dpxnplx0h8p9n5l";
  #   };
  #   nativeBuildInputs = [ utilmacros ];
  #   buildInputs = [ libX11 libXxf86dga ];
  #
  # }) // {inherit libX11 libXxf86dga ;};

  xf86inputjoystick = (mkDerivation "xf86inputjoystick" {
    name = "xf86-input-joystick-1.6.3";
    src = fetchurl {
      url = mirror://xorg/individual/driver/xf86-input-joystick-1.6.3.tar.bz2;
      sha256 = "9e7669ecf0f23b8e5dc39d5397cf28296f692aa4c0e4255f5e02816612c18eab";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ xorgproto xorgserver ];

  }) // {inherit xorgproto xorgserver ;};

  xf86inputkeyboard = (mkDerivation "xf86inputkeyboard" {
    name = "xf86-input-keyboard-1.9.0";
    src = fetchurl {
      url = mirror://xorg/individual/driver/xf86-input-keyboard-1.9.0.tar.bz2;
      sha256 = "f7c900f21752683402992b288d5a2826de7a6c0c0abac2aadd7e8a409e170388";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ xorgserver ];

  }) // {inherit xorgserver ;};

  xf86inputlibinput = (mkDerivation "xf86inputlibinput" {
    name = "xf86-input-libinput-0.28.2";
    src = fetchurl {
      url = mirror://xorg/individual/driver/xf86-input-libinput-0.28.2.tar.bz2;
      sha256 = "b8b346962c6b62b8069928c29c0db83b6f544863bf2fc6830f324de841de2820";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libinput libpciaccess systemd_lib xorgproto xorgserver ];

  }) // {inherit libinput xorgserver ;};

  xf86inputmouse = (mkDerivation "xf86inputmouse" {
    name = "xf86-input-mouse-1.9.3";
    src = fetchurl {
      url = mirror://xorg/individual/driver/xf86-input-mouse-1.9.3.tar.bz2;
      sha256 = "93ecb350604d05be98b7d4e5db3b8155a44890069a7d8d6b800c0bea79c85cc5";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libpciaccess xorgproto xorgserver ];

  }) // {inherit xorgserver ;};

  # xf86inputvmmouse = (mkDerivation "xf86inputvmmouse" {
  #   name = "xf86-input-vmmouse-13.1.0";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/driver/xf86-input-vmmouse-13.1.0.tar.bz2;
  #     sha256 = "06ckn4hlkpig5vnivl0zj8a7ykcgvrsj8b3iccl1pgn1gaamix8a";
  #   };
  #   nativeBuildInputs = [ utilmacros ];
  #   buildInputs = [ inputproto systemd_lib randrproto xorgserver xproto ];
  #
  # }) // {inherit inputproto systemd_lib randrproto xorgserver xproto ;};

  # xf86videoamd = (mkDerivation "xf86videoamd" {
  #   name = "xf86-video-amd-2.7.7.7";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/driver/xf86-video-amd-2.7.7.7.tar.bz2;
  #     sha256 = "1pp9d3vpyj7iz5iz2wzvb2awmpiw1xdf2lff64nkkilbi01pqqrz";
  #   };
  #   nativeBuildInputs = [ ];
  #   buildInputs = [ fontsproto libpciaccess randrproto renderproto videoproto xextproto xf86dgaproto xorgserver xproto ];
  #
  # }) // {inherit fontsproto libpciaccess randrproto renderproto videoproto xextproto xf86dgaproto xorgserver xproto ;};

  xf86videoati = (mkDerivation "xf86videoati" {
    name = "xf86-video-ati-19.0.0";
    src = fetchurl {
      url = mirror://xorg/individual/driver/xf86-video-ati-19.0.0.tar.bz2;
      sha256 = "dd907d318884bb6e81e7e62da7bb34af26aeeed3a81c21e0b46a4f3cae3ff457";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ opengl-dummy xorgproto glamoregl libdrm systemd_lib libpciaccess xorgserver ];

  }) // {inherit xorgproto glamoregl libdrm systemd_lib libpciaccess xorgserver ;};

  xf86videomodesetting = (mkDerivation "xf86videomodesetting" {
    name = "xf86-video-modesetting-0.9.0";
    src = fetchurl {
      url = mirror://xorg/individual/driver/xf86-video-modesetting-0.9.0.tar.bz2;
      sha256 = "0p6pjn5bnd2wr3lmas4b12zcq12d9ilvssga93fzlg90fdahikwh";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ xorgproto libdrm systemd_lib libpciaccess libX11 xorgserver ];

  }) // {inherit xorgproto libdrm systemd_lib libpciaccess libX11 xorgserver ;};

  xf86videonouveau = (mkDerivation "xf86videonouveau" {
    name = "xf86-video-nouveau-1.0.16";
    src = fetchurl {
      url = mirror://xorg/individual/driver/xf86-video-nouveau-1.0.16.tar.bz2;
      sha256 = "304060806415579cdb5c1f71f1c54d11cacb431b5552b170decbc883ed43bf06";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ xorgproto libdrm systemd_lib libpciaccess xorgserver ];
    bindnow = false;
  }) // {inherit xorgproto libdrm systemd_lib libpciaccess xorgserver;};

  # xf86videonv = (mkDerivation "xf86videonv" {
  #   name = "xf86-video-nv-2.1.20";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/driver/xf86-video-nv-2.1.20.tar.bz2;
  #     sha256 = "1gqh1khc4zalip5hh2nksgs7i3piqq18nncgmsx9qvzi05azd5c3";
  #   };
  #   nativeBuildInputs = [ utilmacros ];
  #   buildInputs = [ fontsproto libpciaccess randrproto renderproto videoproto xextproto xorgserver xproto ];
  #
  # }) // {inherit fontsproto libpciaccess randrproto renderproto videoproto xextproto xorgserver xproto ;};

  # xf86videov4l = (mkDerivation "xf86videov4l" {
  #   name = "xf86-video-v4l-0.2.0";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/driver/xf86-video-v4l-0.2.0.tar.bz2;
  #     sha256 = "0pcjc75hgbih3qvhpsx8d4fljysfk025slxcqyyhr45dzch93zyb";
  #   };
  #   nativeBuildInputs = [ ];
  #   buildInputs = [ randrproto videoproto xorgserver xproto ];
  #
  # }) // {inherit randrproto videoproto xorgserver xproto ;};

  # xf86videovmware = (mkDerivation "xf86videovmware" {
  #   name = "xf86-video-vmware-13.2.1";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/driver/xf86-video-vmware-13.2.1.tar.bz2;
  #     sha256 = "e2f7f7101fba7f53b268e7a25908babbf155b3984fb5268b3d244eb6c11bf62b";
  #   };
  #   nativeBuildInputs = [ utilmacros ];
  #   buildInputs = [ fontsproto libdrm libpciaccess randrproto renderproto videoproto libX11 libXext xextproto xineramaproto xorgserver xproto ];
  #
  # }) // {inherit fontsproto libdrm libpciaccess randrproto renderproto videoproto libX11 libXext xextproto xineramaproto xorgserver xproto ;};

  xhost = (mkDerivation "xhost" {
    name = "xhost-1.0.8";
    src = fetchurl {
      url = mirror://xorg/individual/app/xhost-1.0.8.tar.bz2;
      sha256 = "a2dc3c579e13674947395ef8ccc1b3763f89012a216c2cc6277096489aadc396";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libX11 libXau libxmu xorgproto ];

  }) // {inherit libX11 libXau libxmu xorgproto ;};

  xinput = (mkDerivation "xinput" {
    name = "xinput-1.6.2";
    src = fetchurl {
      url = mirror://xorg/individual/app/xinput-1.6.2.tar.bz2;
      sha256 = "1i75mviz9dyqyf7qigzmxq8vn31i86aybm662fzjz5c086dx551n";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ xorgproto libX11 libXext libXi libXinerama libXrandr ];

  }) // {inherit xorgproto libX11 libXext libXi libXinerama libXrandr ;};

  # xman = (mkDerivation "xman" {
  #   name = "xman-1.1.4";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/app/xman-1.1.4.tar.bz2;
  #     sha256 = "0afzhiygy1mdxyr22lhys5bn94qdw3qf8vhbxclwai9p7wp9vymk";
  #   };
  #   nativeBuildInputs = [ utilmacros ];
  #   buildInputs = [ libXaw xproto libXt ];
  #
  # }) // {inherit libXaw xproto libXt ;};

  xmessage = (mkDerivation "xmessage" {
    name = "xmessage-1.0.5";
    src = fetchurl {
      url = mirror://xorg/individual/app/xmessage-1.0.5.tar.bz2;
      sha256 = "373dfb81e7a6f06d3d22485a12fcde6e255d58c6dee1bbaeb00c7d0caa9b2029";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libXaw libXt ];

  }) // {inherit libXaw libXt ;};

  # xmodmap = (mkDerivation "xmodmap" {
  #   name = "xmodmap-1.0.9";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/app/xmodmap-1.0.9.tar.bz2;
  #     sha256 = "0y649an3jqfq9klkp9y5gj20xb78fw6g193f5mnzpl0hbz6fbc5p";
  #   };
  #   nativeBuildInputs = [ utilmacros ];
  #   buildInputs = [ libX11 xproto ];
  #
  # }) // {inherit libX11 xproto ;};

  xorgcffiles = (mkDerivation "xorgcffiles" {
    name = "xorg-cf-files-1.0.6";
    src = fetchurl {
      url = mirror://xorg/individual/util/xorg-cf-files-1.0.6.tar.bz2;
      sha256 = "0kckng0zs1viz0nr84rdl6dswgip7ndn4pnh5nfwnviwpsfmmksd";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ ];

  }) // {inherit ;};

  # xpr = (mkDerivation "xpr" {
  #   name = "xpr-1.0.4";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/app/xpr-1.0.4.tar.bz2;
  #     sha256 = "1dbcv26w2yand2qy7b3h5rbvw1mdmdd57jw88v53sgdr3vrqvngy";
  #   };
  #   nativeBuildInputs = [ utilmacros ];
  #   buildInputs = [ libX11 libxmu xproto ];
  #
  # }) // {inherit libX11 libxmu xproto ;};

  # xpyb = (mkDerivation "xpyb" {
  #   name = "xpyb-1.3.1";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/xcb/xpyb-1.3.1.tar.bz2;
  #     sha256 = "0rkkk2n9g2n2cslvdnb732zwmiijlgn7i9il6w296f5q0mxqfk7x";
  #   };
  #   nativeBuildInputs = [ python ];
  #   buildInputs = [ libxcb xorg-proto ];
  #
  # }) // {inherit libxcb xorg-proto ;};

  xrandr = (mkDerivation "xrandr" {
    name = "xrandr-1.5.0";
    src = fetchurl {
      url = mirror://xorg/individual/app/xrandr-1.5.0.tar.bz2;
      sha256 = "1kaih7rmzxr1vp5a5zzjhm5x7dn9mckya088sqqw026pskhx9ky1";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libX11 xorgproto libXrandr libXrender ];

  }) // {inherit libX11 xorgproto libXrandr libXrender ;};

  xset = (mkDerivation "xset" {
    name = "xset-1.2.4";
    src = fetchurl {
      url = mirror://xorg/individual/app/xset-1.2.4.tar.bz2;
      sha256 = "e4fd95280df52a88e9b0abc1fee11dcf0f34fc24041b9f45a247e52df941c957";
    };
    nativeBuildInputs = [ utilmacros ];
    buildInputs = [ libX11 libXext libXfontcache libxmu xorgproto libXxf86misc ];

  }) // {inherit libX11 libXext libXfontcache libxmu xorgproto libXxf86misc ;};

  # xts = (mkDerivation "xts" {
  #   name = "xts-0.99.1";
  #   src = fetchurl {
  #     url = mirror://xorg/individual/test/xts-0.99.1.tar.bz2;
  #     sha256 = "08sanl2nhbbscid767i5zwk0nv2q3ds89w96ils8qfigd57kacc5";
  #   };
  #   nativeBuildInputs = [ utilmacros ];
  #   buildInputs = [ libX11 libXau libXaw libXext libXi libxmu libXt xtrans libXtst ];
  #
  # }) // {inherit libX11 libXau libXaw libXext libXi libxmu libXt xtrans libXtst ;};

}; in xorg

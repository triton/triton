{ args, xorg }:

let
  inherit (args) stdenv makeWrapper fetchurl fetchzip fetchTritonPatch;
  inherit (stdenv) lib targetSystem;
  inherit (lib) elem overrideDerivation platforms;
in
{
  fontmiscmisc = attrs: attrs // {
    postInstall = ''
      ALIASFILE=${xorg.fontalias}/share/fonts/X11/misc/fonts.alias
      test -f $ALIASFILE
      ln -s $ALIASFILE $out/lib/X11/fonts/misc/fonts.alias
    '';
  };

  imake = attrs: attrs // {
    inherit (xorg) xorgcffiles;
    x11BuildHook = ./imake.sh;
    patches = [
      ./imake.patch
    ];
    CFLAGS = [
      "-DIMAKE_COMPILETIME_CPP=\\\"gcc\\\""
    ];
  };

  mkfontdir = attrs: attrs // {
    preBuild = ''
      substituteInPlace mkfontdir.in --replace @bindir@ ${xorg.mkfontscale}/bin
    '';
  };

  setxkbmap = attrs: attrs // {
    postInstall = ''
      mkdir -p $out/share
      ln -sfn ${xorg.xkeyboardconfig}/etc/X11 $out/share/X11
    '';
  };

  xf86inputevdev = attrs: attrs // {
    installFlags = [
      "sdkdir=\${out}/include/xorg"
    ];
  };

  xf86inputmouse = attrs: attrs // {
    installFlags = [
      "sdkdir=\${out}/include/xorg"
    ];
  };

  xf86inputjoystick = attrs: attrs // {
    installFlags = [
      "sdkdir=\${out}/include/xorg"
    ];
  };

  xf86inputlibinput = attrs: attrs // {
    installFlags = [
      "sdkdir=\${out}/include/xorg"
    ];
  };

  xf86inputsynaptics = attrs: attrs // {
    installFlags = [
      "sdkdir=\${out}/include/xorg"
      "configdir=\${out}/share/X11/xorg.conf.d"
    ];
  };

  xf86inputvmmouse = attrs: attrs // {
    configureFlags = [
      "--sysconfdir=$(out)/etc"
      "--with-xorg-conf-dir=$(out)/share/X11/xorg.conf.d"
      "--with-udev-rules-dir=$(out)/lib/udev/rules.d"
    ];
  };

  xf86videoamdgpu = attrs: attrs // {
    installFlags = [
      "configdir=$(out)/share/X11/xorg.conf.d"
    ];
  };

  xf86videonv = attrs: attrs // {
    patches = [( args.fetchpatch {
      url = http://cgit.freedesktop.org/xorg/driver/xf86-video-nv/patch/?id=fc78fe98222b0204b8a2872a529763d6fe5048da;
      sha256 = "0i2ddgqwj6cfnk8f4r73kkq3cna7hfnz7k3xj3ifx5v8mfiva6gw";
    })];
  };

  xkbcomp = attrs: attrs // {
    configureFlags = [
      "--with-xkb-config-root=${xorg.xkeyboardconfig}/share/X11/xkb"
    ];
  };

  xkeyboardconfig = attrs: attrs // {
    postInstall = ''
      ln -sv share "$out/etc"
    '';
  };

  libXpm = attrs: attrs // {
    # Has some makefile dependency on gettext
    nativeBuildInputs = [
      args.gettext
    ] ++ attrs.nativeBuildInputs;
  };

  lndir = attrs: attrs // {
    preConfigure = ''
      substituteInPlace lndir.c \
        --replace 'n_dirs--;' ""
    '';
  };

  xcursorthemes = attrs: attrs // {
    configureFlags = [
      "--with-cursordir=$(out)/share/icons"
    ];
  };

  xrdb = attrs: attrs // {
    configureFlags = [
      "--with-cpp=${args.mcpp}/bin/mcpp"
    ];
  };

}

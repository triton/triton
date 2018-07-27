{ stdenv
, fetchurl
, gperf
, lib
, libxslt
, substituteAll

, freetype
, expat
, util-linux_lib
, xorg
}:

/** Font configuration scheme
 * - ./config-compat.patch makes fontconfig try the following root
 *   configs, in order: $FONTCONFIG_FILE,
 *   /etc/fonts/${configVersion}/fonts.conf, /etc/fonts/fonts.conf.
 *   This is done not to override config of pre-2.11 versions (which
 *   just blows up) and still use *global* font configuration at
 *   both NixOS or non-NixOS.
 * - NixOS creates /etc/fonts/${configVersion}/fonts.conf link to
 *   $out/etc/fonts/fonts.conf, and other modifications should go to
 *   /etc/fonts/${configVersion}/conf.d
 * - See ./make-fonts-conf.xsl for config details.
 */

let
  # bump whenever fontconfig breaks compatibility with older configurations
  configVersion = "2.13";
in
stdenv.mkDerivation rec {
  name = "fontconfig-2.13.0";

  src = fetchurl {
    urls = [
      "https://www.freedesktop.org/software/fontconfig/release/${name}.tar.bz2"
      "http://fontconfig.org/release/${name}.tar.bz2"
    ];
    sha256 = "91dde8492155b7f34bb95079e79be92f1df353fcc682c19be90762fd3e12eeb9";
  };

  nativeBuildInputs = [
    gperf
  ];

  buildInputs = [
    expat
    freetype
    util-linux_lib
  ];

  patches = [
    (substituteAll {
      src = ./config-compat.patch;
      inherit configVersion;
    })
  ];

  configureFlags = [
    "--enable-iconv"
    "--disable-docs"
    # This is what you get when loading fontconfig's config fails
    # for any reason.
    "--with-default-fonts=${xorg.fontbhttf}"
    "--with-cache-dir=/var/cache/fontconfig"
  ];

  # Don't try to write to /var/cache/fontconfig at install time.
  installFlags = [
    "fc_cachedir=$(TMPDIR)/dummy"
    "RUN_FC_CACHE_TEST=false"
  ];

  postInstall = ''
    cd "$out/etc/fonts"
    rm conf.d/{50-user,51-local}.conf
    "${libxslt}/bin/xsltproc" --stringparam fontDirectories "${xorg.fontbhttf}" \
      --stringparam fontconfig "$out" \
      --stringparam fontconfigConfigVersion "${configVersion}" \
      --path $out/share/xml/fontconfig \
      ${./make-fonts-conf.xsl} $out/etc/fonts/fonts.conf \
      > fonts.conf.tmp
    mv fonts.conf.tmp $out/etc/fonts/fonts.conf
  '';

  # Broken with 2.13.0
  #doCheck = true;

  passthru = {
    inherit configVersion;
  };

  meta = with lib; {
    description = "A library for font customization and configuration";
    homepage = http://fontconfig.org/;
    license = licenses.bsd2; # custom but very bsd-like
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}


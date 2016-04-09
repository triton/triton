{ stdenv, fetchFromGitHub }:

let version = "2015-12-06"; in
stdenv.mkDerivation {
  name = "fontconfig-ultimate-${version}";

  src = fetchFromGitHub {
    sha256 = "9e5b5bf98683528eae0fcf0817aceaafdb52ab98d74e6500d63dfa01f62f31c4";
    rev = version;
    repo = "fontconfig-ultimate";
    owner = "bohoomil";
  };

  phases = "$prePhases unpackPhase installPhase $postPhases";

  installPhase = ''
    mkdir -p $out/etc/fonts/conf.d
    cp conf.d.infinality/*.conf $out/etc/fonts/conf.d

    # Base rendering settings will be determined by NixOS module
    rm $out/etc/fonts/conf.d/10-base-rendering.conf

    # Options controlled by NixOS module
    rm $out/etc/fonts/conf.d/35-repl-custom.conf
    rm $out/etc/fonts/conf.d/38-repl-*.conf
    rm $out/etc/fonts/conf.d/82-*.conf
    rm $out/etc/fonts/conf.d/83-*.conf

    # Inclusion of local and user configs handled by global configuration
    rm $out/etc/fonts/conf.d/29-local.conf
    rm $out/etc/fonts/conf.d/28-user.conf

    cp fontconfig_patches/fonts-settings/*.conf $out/etc/fonts/conf.d

    mkdir -p $out/etc/fonts/presets/{combi,free,ms}
    cp fontconfig_patches/combi/*.conf $out/etc/fonts/presets/combi
    cp fontconfig_patches/free/*.conf $out/etc/fonts/presets/free
    cp fontconfig_patches/ms/*.conf $out/etc/fonts/presets/ms
  '';
}

{ stdenv
, fetchurl
, lib
, makeWrapper

, bzip2
, cairo
, gdk-pixbuf
, gksu
, glib
, gnome-themes-standard
, gtk_2
, libredirect
, libx11
, openssl
, pango
, shared-mime-info

, pkexecPath ? "/var/setuid-wrappers/pkexec"
}:

let
  inherit (stdenv)
    system;
  inherit (lib)
    makeSearchPath
    optionalString;

  version = "3143";
in
stdenv.mkDerivation rec {
  name = "sublime-text-${version}";

  src = fetchurl {
    url = "https://download.sublimetext.com/"
      + "sublime_text_3_build_${version}_x64.tar.bz2";
    multihash = "QmNgoqdq9jSkuVao3mcFphT8ujcPbCRCaCz8pN87MzJnyP";
    sha256 = "9ce120c4f28b239d3b3860ee672d9d87e1397a4c08ee6c4e62fd6e261a296519";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    gnome-themes-standard
  ];

  libPath = makeSearchPath "lib" [
    cairo
    glib
    gtk_2
    pango
    libx11
  ];

  redirects = [
    "/usr/bin/gksudo=${gksu}/bin/gksudo"
    "/usr/bin/pkexec=${pkexecPath}"
  ];

  postPatch = /* Fix paths */ ''
    sed -i sublime_text.desktop \
      -e 's,/opt/sublime_text/,,' \
      -e 's,sublime-text,sublime_text,'
  '' + /* Rename icon file */ ''
    mv -v Icon/256x256/sublime-text.png Icon/256x256/sublime_text.png
  '';

  buildPhase = ''
    for i in 'sublime_text' 'plugin_host' 'crash_reporter' ; do
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath ${libPath}:${stdenv.cc.cc}/lib64 \
        $i
      if [ -n "$(ldd "$i" 2>&- | grep --only-matching 'not found')" ]; then
        echo "ERROR: failed to patch RPATH's for:"
        echo "$i"
        ldd $i
        return 1
      fi
    done
  '' + /* Rewrite gksudo/pkexec argument. Note that we can't delete
          bytes in binary. */ ''
    sed -i sublime_text \
      -e 's,/bin/cp\x00,cp\x00\x00\x00\x00\x00\x00,g'
  '';

  installPhase = ''
    mkdir -pv $out/share/sublime-text/
    cp -prvd * $out/share/sublime-text/
  '' + ''
    wrapProgram $out/share/sublime-text/sublime_text \
      --set 'GDK_PIXBUF_MODULE_FILE' '${gdk-pixbuf.loaders.cache}' \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --run "$DEFAULT_GTK2_RC_FILES" \
      --set LD_PRELOAD '${libredirect}/lib/libredirect.so' \
      --set NIX_REDIRECTS ${builtins.concatStringsSep ":" redirects}
  '' + /* Without this, plugin_host crashes, even though it has the rpath */ ''
    wrapProgram $out/share/sublime-text/plugin_host \
      --prefix LD_PRELOAD : '${stdenv.cc.cc}/lib64/libgcc_s.so.1' \
      --prefix LD_PRELOAD : '${openssl}/lib/libssl.so' \
      --prefix LD_PRELOAD : '${bzip2}/lib/libbz2.so'
  '' + /* Symlink files to correct prefix locations */ ''
    mkdir -pv $out/bin
    ln -sv $out/share/sublime-text/sublime_text $out/bin/sublime_text
    ln -sv $out/share/sublime-text/sublime_text $out/bin/subl

    mkdir -pv $out/share/applications
    ln -sv $out/share/sublime-text/sublime_text.desktop $out/share/applications
    mkdir -pv $out/share/icons
    ln -sv $out/share/sublime-text/Icon/256x256/sublime_text.png $out/share/icons
  '';

  dontStrip = true;
  dontPatchELF = true;

  meta = with lib; {
    description = "Sophisticated text editor for code, markup and prose";
    homepage = https://www.sublimetext.com/;
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, fetchurl
, lib
, makeWrapper

#, boost
, curl
, expat
#, ffmpeg
#, jemalloc
, libdrm
, libnatpmp
, libusb
#, libva
#, libxml2
#, libxslt
#, miniupnpc
, openssl
#, python2
, sqlite
, taglib
, zlib

# Plex's data directory must be baked into the package due to symlinks.
, dataDir ? "/var/lib/plex"
}:

let
  inherit (lib)
    makeSearchPath;

  version = "1.9.6.4429-23901a099";
in
stdenv.mkDerivation rec {
  name = "plex-${version}";

  src = fetchurl {
    url = "https://downloads.plex.tv/plex-media-server/${version}/"
      + "plexmediaserver_${version}_amd64.deb";
    sha1Confirm = "0517280a68b39efc199cd3505d2fdf92173f08f4";
    sha256 = "09586466a00ecc691437446d08252c71f9eb84c79667f70fb43ba6f0fc09bd33";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  libraryPath = makeSearchPath "lib" [
    # boost  # older version
    curl
    expat
    # ffmpeg  # Not ABI compatible
    # jemalloc  # older version
    libdrm
    libnatpmp
    libusb
    # libva  # older version
    # libxml2  # Not ABI compatible
    # libxslt  # Not ABI compatible
    # miniupnpc  # older version
    openssl
    # python2  # Not ABI compatible
    sqlite
    stdenv.cc.cc
    stdenv.libc
    taglib
    zlib
  ];

  unpackPhase = ''
    ar x $src
    tar xf data.tar.gz
  '';

  configurePhase = ''
    declare -A PlexExecutableList
    PlexExecutableList=(
      #['CrashUploader']
      #['MigratePlexServerConfig.sh']
      ['Plex DLNA Server']='plex-dlna-server'
      ['Plex Media Scanner']='plex-media-scanner'
      ['Plex Media Server']='plex-media-server'
      ['Plex Media Server Tests']='plex-media-server-tests'
      ['Plex Relay']='plex-replay'
      ['Plex Script Host']='plex-script-host'
      ['Plex Transcoder']='plex-transcoder'
    )

    # Find all shared objects in usr/lib/plexmediaserver
    mapfile -t PlexLibraryList < <(
      find 'usr/lib/plexmediaserver' -type f -name '*.so*' -printf '%P\n'
    )
    # Filter out plex libraries if they match system libraries provided
    # in `libraryPath`.
    for PlexLibrary in "''${PlexLibraryList[@]}"; do
      # Read `libraryPath` string into an array
      mapfile -d: -t InputLibraryList < <(echo ${libraryPath})
      for InputLibrary in "''${InputLibraryList[@]}"; do
        # Drop matches from the array
        if [ -f "$InputLibrary/$PlexLibrary" ]; then
          PlexLibraryList=("''${PlexLibraryList[@]//$PlexLibrary}")
        fi
      done
    done
  '';

  buildPhase = ":";

  installPhase = ''
    mkdir -pv $out/bin
    for PlexExecutable in "''${!PlexExecutableList[@]}"; do
      install -D -m 755 -v "usr/lib/plexmediaserver/$PlexExecutable" \
        "$out/lib/plexmediaserver/$PlexExecutable"
      ln -sv \
        "$out/lib/plexmediaserver/$PlexExecutable" \
        "$out/bin/''${PlexExecutableList["$PlexExecutable"]}"
    done

    for PlexLibrary in "''${PlexLibraryList[@]}"; do
      if [ -n "$PlexLibrary" ]; then
        install -D -m 644 -v "usr/lib/plexmediaserver/$PlexLibrary" \
          "$out/lib/plexmediaserver/$PlexLibrary"
      fi
    done

    cp -dr --no-preserve='ownership' 'usr/lib/plexmediaserver/Resources' \
      "$out/lib/plexmediaserver"
  '';

  preFixup = ''
    for PlexExecutable in "''${!PlexExecutableList[@]}"; do
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        "$out/lib/plexmediaserver/$PlexExecutable"
      patchelf \
        --set-rpath "$libraryPath:$out/lib/plexmediaserver" \
        "$out/lib/plexmediaserver/$PlexExecutable"
    done

    for PlexLibrary in "''${PlexLibraryList[@]}"; do
      if [ -n "$PlexLibrary" ] ; then
        patchelf \
          --set-rpath "$libraryPath:$out/lib/plexmediaserver" \
          "$out/lib/plexmediaserver/$PlexLibrary"
      fi
    done
  '' + ''
    for PlexExecutable in "''${PlexExecutableList[@]}"; do
      wrapProgram "$out/bin/$PlexExecutable" \
        --set 'PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR' \
          '"''${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR:-${dataDir}}"' \
        --set 'PLEX_MEDIA_SERVER_HOME' "$out/lib/plexmediaserver" \
        --set 'PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS' \
          '"''${PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS:-6}"' \
        --set 'PLEX_MEDIA_SERVER_TMPDIR' '"/tmp/plex"' \
        --prefix 'LD_LIBRARY_PATH' : "${libraryPath}:$out/lib"
        # --run "
        #   if [ ! -d \"\$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/.skeleton\" ] ; then
        #     for db in 'com.plexapp.plugins.library.db' ; do
        #       mkdir -p \"\$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/.skeleton\"
        #       cp \"\$PLEX_MEDIA_SERVER_HOME/Resources/base_\$db\" \\
        #         \"\$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/.skeleton/\$db\"
        #       chmod u+w \"\$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/.skeleton/\$db\"
        #     done
        #   fi"
    done
  '' + /*
    # FIXME: make configurable at runtime
    The search path for the database is hardcoded and since the nix-store is
    read-only we create a symlink to a fixed location and copy the database
    to that location from the nix-store.
    */ ''
    mv -v "$out/lib/plexmediaserver/Resources/com.plexapp.plugins.library.db" \
      "$out/lib/plexmediaserver/Resources/base_com.plexapp.plugins.library.db"
    ln -sv "${dataDir}/.skeleton/com.plexapp.plugins.library.db" \
      "$out/lib/plexmediaserver/Resources/com.plexapp.plugins.library.db"
  '';

  postFixup = /* Run some tests */ ''
    # Fail if libraries contain broken RPATH's
    local TestLib
    for TestLib in "''${PlexLibraryList[@]}"; do
      echo "Testing rpath for: $TestLib"
      if [ -n "$(ldd "$out/lib/plexmediaserver/$(basename "$TestLib")" 2> /dev/null |
                 grep --only-matching 'not found')" ]; then
        echo "ERROR: failed to patch RPATH's for:"
        echo "$(basename "$TestLib")"
        ldd "$out/lib/plexmediaserver/$(basename "$TestLib")"
        return 1
      fi
      echo "PASSED"
    done

    # Fail if executables contain broken RPATH's
    local executable
    for executable in "''${!PlexExecutableList[@]}"; do
      echo "Testing rpath for: $executable"
      if [ -n "$(ldd "$out/lib/plexmediaserver/$executable" 2> /dev/null |
                 grep --only-matching 'not found')" ]; then
        echo "ERROR: failed to patch RPATH's for:"
        echo "$executable"
        ldd "$out/lib/plexmediaserver/$executable"
        return 1
      fi
      echo "PASSED"
    done
  '';

  passthru = {
    inherit
      dataDir
      libraryPath;
  };

  meta = with lib; {
    description = "Media / DLNA server";
    homepage = https://www.plex.tv/;
    license = licenses.unfree;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

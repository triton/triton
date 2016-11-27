{ stdenv
, fetchurl
, lib
, makeWrapper

, curl
, expat
#, ffmpeg
, libnatpmp
#, libxml2
#, libxslt
, openssl
#, python2
, sqlite
, taglib
, zlib

# Plex's data directory must be baked into the package due to symlinks.
, dataDir ? "/var/lib/plex"
}:

# Requires gcc/glibc
assert stdenv.cc.isGNU;

let
  inherit (lib)
    makeSearchPath;

  version = "1.2.7.2987-1bef33a";
in
stdenv.mkDerivation rec {
  name = "plex-${version}";

  src = fetchurl {
    url = "https://downloads.plex.tv/plex-media-server/${version}/"
      + "plexmediaserver_${version}_amd64.deb";
    sha256 = "33b21ebb656e1f1011141aff5e6a47946c346392912b4c9ce3049df7e1d9ba08";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  libraryPath = makeSearchPath "lib" [
    curl
    expat
    # ffmpeg  # Not ABI compatible
    libnatpmp
    # libxml2  # Not ABI compatible
    # libxslt  # Not ABI compatible
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

    declare -a PlexLibraryList
    PlexLibraryList=(
      'libavcodec.so.57'
      'libavformat.so.57'
      'libavutil.so.55'
      'libboost_atomic.so.1.59.0'
      'libboost_chrono.so.1.59.0'
      'libboost_date_time.so.1.59.0'
      'libboost_filesystem.so.1.59.0'
      'libboost_iostreams.so.1.59.0'
      'libboost_locale.so.1.59.0'
      'libboost_program_options.so.1.59.0'
      'libboost_regex.so.1.59.0'
      'libboost_system.so.1.59.0'
      'libboost_thread.so.1.59.0'
      'libboost_timer.so.1.59.0'
      #'libcrypto.so.1.0.0'
      #'libcurl.so.4'
      #'libexpat.so.1'
      'libexslt.so.0'
      'libfreeimage.so'
      'libgnsdk_correlates.so.3.07.7'
      'libgnsdk_dsp.so.3.07.7'
      'libgnsdk_fp.so.3.07.7'
      'libgnsdk_link.so.3.07.7'
      'libgnsdk_lookup_local.so.3.07.7'
      'libgnsdk_lookup_localstream.so.3.07.7'
      'libgnsdk_manager.so.3.07.7'
      'libgnsdk_moodgrid.so.3.07.7'
      'libgnsdk_musicid.so.3.07.7'
      'libgnsdk_musicid_file.so.3.07.7'
      'libgnsdk_musicid_match.so.3.07.7'
      'libgnsdk_musicid_stream.so.3.07.7'
      'libgnsdk_playlist.so.3.07.7'
      'libgnsdk_rhythm.so.3.07.7'
      'libgnsdk_storage_sqlite.so.3.07.7'
      'libgnsdk_submit.so.3.07.7'
      'libgnsdk_tocgen.so.3.07.7'
      'libgnsdk_video.so.3.07.7'
      'libiconv.so.2'
      'libjemalloc.so.1'
      'liblrc.so.0'
      'libmediainfo.so.0'
      'libminiupnpc.so.10'
      'libminizip.so.1'
      #'libnatpmp.so.1'
      'libopencv_core.so.2.4'
      'libopencv_imgproc.so.2.4'
      'libpython2.7.so.1.0'
      'libsoci_core.so.3.0.0'
      'libsoci_sqlite3.so.3.0.0'
      #'libsqlite3.so.0'
      #'libssl.so.1.0.0'
      'libswscale.so.4'
      #'libtag.so.1'
      'libxml2.so.2'
      'libxslt.so.1'
      #'libz.so.1'
      'libzen.so.0'
    )
  '';

  buildPhase = ":";

  installPhase = ''
    mkdir -pv $out/bin
    for PlexExecutable in "''${!PlexExecutableList[@]}" ; do
      install -D -m 755 -v "usr/lib/plexmediaserver/$PlexExecutable" \
        "$out/lib/plexmediaserver/$PlexExecutable"
      ln -sv \
        "$out/lib/plexmediaserver/$PlexExecutable" \
        "$out/bin/''${PlexExecutableList["$PlexExecutable"]}"
    done

    for PlexLibrary in "''${PlexLibraryList[@]}" ; do
      install -D -m 644 -v "usr/lib/plexmediaserver/$PlexLibrary" \
        "$out/lib/plexmediaserver/$PlexLibrary"
    done

    install -D -m 644 -v 'usr/lib/plexmediaserver/plex-archive-keyring.gpg' \
      "$out/lib/plexmediaserver/plex-archive-keyring.gpg"

    cp -dr --no-preserve='ownership' 'usr/lib/plexmediaserver/Resources' \
      "$out/lib/plexmediaserver"
  '';

  preFixup = ''
    for PlexExecutable in "''${!PlexExecutableList[@]}" ; do
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        "$out/lib/plexmediaserver/$PlexExecutable"
      patchelf \
        --set-rpath "$libraryPath:$out/lib/plexmediaserver" \
        "$out/lib/plexmediaserver/$PlexExecutable"
    done

    for PlexLibrary in "''${PlexLibraryList[@]}" ; do
      patchelf \
        --set-rpath "$libraryPath:$out/lib/plexmediaserver" \
        "$out/lib/plexmediaserver/$PlexLibrary"
    done
  '' + ''
    for PlexExecutable in "''${PlexExecutableList[@]}" ; do
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
    The search path for the database is hardcoded and since the nix-store is
    read-only we create a symlink to a fixed location and copy the database
    to that location from the nix-store.
    */ ''
    for db in "com.plexapp.plugins.library.db"; do
      mv -v "$out/lib/plexmediaserver/Resources/$db" \
        "$out/lib/plexmediaserver/Resources/base_$db"
      ln -sv "${dataDir}/.skeleton/$db" \
        "$out/lib/plexmediaserver/Resources/$db"
    done
  '';

  postFixup = /* Run some tests */ ''
    # Fail if libraries contain broken RPATH's
    local TestLib
    for TestLib in "''${PlexLibraryList[@]}" ; do
      echo "Testing rpath for: $TestLib"
      if [ -n "$(ldd "$out/lib/plexmediaserver/$TestLib" 2> /dev/null |
                 grep --only-matching 'not found')" ] ; then
        echo "ERROR: failed to patch RPATH's for:"
        echo "$TestLib"
        ldd "$out/lib/plexmediaserver/$TestLib"
        return 1
      fi
      echo "PASSED"
    done

    # Fail if executables contain broken RPATH's
    local executable
    for executable in "''${!PlexExecutableList[@]}" ; do
      echo "Testing rpath for: $executable"
      if [ -n "$(ldd "$out/lib/plexmediaserver/$executable" 2> /dev/null |
                 grep --only-matching 'not found')" ] ; then
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

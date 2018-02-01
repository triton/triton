{ stdenv
, cmake
, fetchFromGitHub
, fetchzip
, gettext
, intltool
, lib
, makeWrapper
, ninja


, adwaita-icon-theme
, curl
, dbus
, dht
, gdk-pixbuf
, glib
, gtk_3
#, libappindicator
, libb64
, libevent
, libnatpmp
, miniupnpc
, openssl
, qt5
, systemd_lib
, zlib

, useStableVersionUserAgent ? false

, channel
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (lib)
    boolOn
    elem
    optionals
    optionalString
    platforms;

  sources = {
    "2" = {
      fetchzipversion = 5;
      version = "2.93";
      sha256 = "da538ec9bbfb884dabb4c6531f2b131558e7efb55f1b7fd668e0c79a0588f71d";
    };
    "head" = {
      fetchzipversion = 5;
      version = "2018-01-15";
      rev = "eb5d1a79cbe1b9bc5b22fdcc598694ecd4d02f43";
      sha256 = "f1c3546bf160c12a535c92ecee48309271dc74fdeb5495fa280da6f17d47d4f0";
    };
  };
  source = sources."${channel}";

  # Transmission vendors patched libutp sources required for building.
  libutp =
    stdenv.mkDerivation rec {
      name = "libutp-transmission-7c4f19abdf";

      src = fetchzip {
        version = 5;
        url = "https://github.com/transmission/libutp/archive/7c4f19abdf.tar.gz";
        sha256 = "7102572f3cc6b4d2aebc770ea0828729c92215bc91d5151f6392fe26d6dc2238";
      };

      nativeBuildInputs = [
        cmake
        ninja
      ];

      postPatch = /* From third-patry/utp.cmake */ ''
        cat > CMakeLists.txt <<'EOF'
        cmake_minimum_required(VERSION 2.8)
        project(utp CXX)

        add_definitions(-DPOSIX)

        include_directories(.)

        add_library(''${PROJECT_NAME} STATIC
          utp.cpp
          utp_utils.cpp
          ''${''${PROJECT_NAME}_ADD_SOURCES}
        )

        install(TARGETS ''${PROJECT_NAME} DESTINATION lib)
        install(
          FILES
            utp.h
            utypes.h
          DESTINATION
            include/libutp
        )

        EOF
      '' + /* From third-patry/libutp */ ''
        cat > utp_config.h <<'EOF'
        #define CCONTROL_TARGET (100 * 1000) // us
        #define RATE_CHECK_INTERVAL 10000 // ms
        #define DYNAMIC_PACKET_SIZE_ENABLED false
        #define DYNAMIC_PACKET_SIZE_FACTOR 2

        uint64 UTP_GetGlobalUTPBytesSent(const struct sockaddr *remote, socklen_t remotelen) { return 0; }

        enum bandwidth_type_t {
          payload_bandwidth, connect_overhead,
          close_overhead, ack_overhead,
          header_overhead, retransmit_overhead
        };

        #define I64u "%Lu"

        #define g_log_utp 0
        #define g_log_utp_verbose 0
        void utp_log(char const* fmt, ...) { };

        EOF
      '';

      meta = with lib; {
        license = licenses.free;
        platforms = with platforms;
          x86_64-linux;
      };
    };
in
stdenv.mkDerivation rec {
  name = "transmission-${source.version}";

  src = fetchFromGitHub {
    version = source.fetchzipversion;
    owner = "transmission";
    repo = "transmission";
    rev =
      if channel == "head" then
        source.rev
      else
        source.version;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    cmake
    gettext
    intltool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    curl
    dbus
    dht
    gdk-pixbuf
    glib
    gtk_3
    libb64
    libevent
    libnatpmp
    libutp
    miniupnpc
    openssl
    #qt5
    systemd_lib
    zlib
  ];

  postPatch = /* FIXME: remove in 2.93+ */ ''
    sed -i CMakeLists.txt \
      -e 's/libsystemd-daemon/libsystemd/'
  '' + /* Make sure no vendored code is used */ ''
    rm -rfv third-party/
  '' + optionalString useStableVersionUserAgent ''
    sed -i CMakeLists.txt \
      -e '/TR_USER_AGENT_PREFIX/ s/+//' \
      -e '/TR_PEER_ID_PREFIX/ s/Z/0/'
  '';

  cmakeFlags = [
    "-DENABLE_CLI=ON"
    "-DENABLE_DAEMON=ON"
    "-DENABLE_GTK=${boolOn (
      adwaita-icon-theme != null
      && dbus != null
      && gdk-pixbuf != null
      && glib != null
      && gtk_3 != null)}"
    "-DENABLE_LIGHTWEIGHT=OFF"
    "-DENABLE_NLS=ON"
    "-DENABLE_QT=${boolOn (qt5 != null)}"
    "-DENABLE_TESTS=OFF"
    "-DENABLE_UTILS=ON"
    "-DENABLE_UTP=ON"
    "-DUSE_QT5=${boolOn (qt5 != null)}"
    "-DUSE_SYSTEM_B64=ON"
    "-DUSE_SYSTEM_DHT=ON"
    "-DUSE_SYSTEM_EVENT2=ON"
    "-DUSE_SYSTEM_MINIUPNPC=ON"
    "-DUSE_SYSTEM_NATPMP=ON"
    "-DUSE_SYSTEM_UTP=ON"
    "-DWITH_CRYPTO=openssl"
    #"-DWITH_INOTIFY"
    "-DWITH_KQUEUE=${boolOn (elem targetSystem platforms.freebsd)}"
    "-DWITH_SYSTEMD=${boolOn (systemd_lib != null)}"
  ];

  CXXFLAGS = [
    # https://bugs.gentoo.org/577528
    "-D_LARGEFILE64_SOURCE=1"
  ];

  preFixup = optionalString (
    adwaita-icon-theme != null
    && dbus != null
    && gdk-pixbuf != null
    && glib != null
    && gtk_3 != null) ''
    wrapProgram $out/bin/transmission-gtk \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  meta = with lib; {
    description = "Fast, easy, and free BitTorrent client";
    homepage = https://transmissionbt.com/;
    license = with licenses; [
      gpl2
      gpl3
      mit
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

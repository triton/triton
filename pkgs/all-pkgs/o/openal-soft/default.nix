{ stdenv
, cmake
, fetchurl
, lib
, ninja

, alsa-lib
, jack2_lib
, portaudio
, pulseaudio_lib
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (lib)
    boolOn
    elem
    platforms;
in
stdenv.mkDerivation rec {
  name = "openal-soft-1.18.2";

  src = fetchurl {
    urls = [
      "mirror://gentoo/distfiles/${name}.tar.bz2"
      "http://kcat.strangesoft.net/openal-releases/${name}.tar.bz2"
    ];
    sha256 = "9f8ac1e27fba15a59758a13f0c7f6540a0605b6c3a691def9d420570506d7e82";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    alsa-lib
    jack2_lib
    portaudio
    pulseaudio_lib
  ];

  cmakeFlags = [
    "-DALSOFT_BACKEND_ALSA=${boolOn (alsa-lib != null)}"
    "-DALSOFT_BACKEND_OSS=OFF"
    "-DALSOFT_BACKEND_PULSEAUDIO=${boolOn (pulseaudio_lib != null)}"
    "-DALSOFT_BACKEND_WAVE=ON"
    "-DALSOFT_CONFIG=OFF"
    "-DALSOFT_CPUEXT_SSE=${boolOn (elem targetSystem platforms.x86-all)}"
    "-DALSOFT_CPUEXT_SSE2=${boolOn (elem targetSystem platforms.x86-all)}"
    "-DALSOFT_CPUEXT_SSE3=${boolOn (elem targetSystem platforms.x86-all)}"
    "-DALSOFT_CPUEXT_SSE4_1=${boolOn (elem targetSystem platforms.x86-all)}"
    "-DALSOFT_DLOPEN=ON"
    "-DALSOFT_EXAMPLES=OFF"
    # "-DALSOFT_HRTF_DEFS":BOOL=ON
    "-DALSOFT_INSTALL=ON"
    "-DALSOFT_NO_CONFIG_UTIL=OFF"
    "-DALSOFT_REQUIRE_ALSA=${boolOn (alsa-lib != null)}"
    "-DALSOFT_REQUIRE_COREAUDIO=OFF"  # macos
    "-DALSOFT_REQUIRE_DSOUND=OFF"  # windows
    "-DALSOFT_REQUIRE_JACK=${boolOn (jack2_lib != null)}"
    "-DALSOFT_REQUIRE_MMDEVAPI=OFF"  # windows
    "-DALSOFT_REQUIRE_NEON=OFF"  # arm
    "-DALSOFT_REQUIRE_OPENSL=OFF"  # android
    "-DALSOFT_REQUIRE_OSS=OFF"
    "-DALSOFT_REQUIRE_PORTAUDIO=${boolOn (portaudio != null)}"
    "-DALSOFT_REQUIRE_PULSEAUDIO=${boolOn (pulseaudio_lib != null)}"
    "-DALSOFT_REQUIRE_QSA=OFF"
    "-DALSOFT_REQUIRE_SNDIO=OFF"
    "-DALSOFT_REQUIRE_SOLARIS=${boolOn (elem targetSystem platforms.illumos)}"
    "-DALSOFT_REQUIRE_SSE=${boolOn (elem targetSystem platforms.x86-all)}"
    "-DALSOFT_REQUIRE_SSE2=${boolOn (elem targetSystem platforms.x86-all)}"
    "-DALSOFT_REQUIRE_SSE4_1=${boolOn (elem targetSystem platforms.x86-all)}"
    "-DALSOFT_REQUIRE_WINMM=OFF"  # windows
    "-DALSOFT_STATIC_LIBGCC=OFF"
    "-DALSOFT_TESTS=OFF"
    "-DALSOFT_UTILS=OFF"
    "-DALSOFT_WERROR=OFF"
  ];

  meta = with lib; {
    description = "A software implementation of the OpenAL 3D audio API";
    homepage = http://kcat.strangesoft.net/openal.html;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

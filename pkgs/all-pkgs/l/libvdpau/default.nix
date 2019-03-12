{ stdenv
, fetchTritonPatch
, fetchurl
, lib
#, meson
#, ninja

, libx11
, libxext
, opengl-dummy
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libvdpau-1.2";

  src = fetchurl {
    name = "${name}.tar.bz2";
    multihash = "QmVxoiFuySsaZUzYCyYtE1jSxgvxKWypqXVX5EiwMze7uK";
    hashOutput = false;
    sha256 = "6a499b186f524e1c16b4f5b57a6a2de70dfceb25c4ee546515f26073cd33fa06";
  };

  #nativeBuildInputs = [
  #  meson
  #  ninja
  #];

  buildInputs = [
    libx11
    libxext
    xorgproto
  ];

  configureFlags = [
    "--enable-dri2"
    "--disable-documentation"
    "--with-module-dir=${opengl-dummy.driverSearchPath}/lib/vdpau"
  ];

  #mesonFlags = [
  #  "-Ddocumentation=false"
  #  "-Ddri2=true"
  #  "-Dmoduledir=${opengl-dummy.driverSearchPath}/lib/vdpau"
  #];

  preInstall = ''
    installFlagsArray+=("moduledir=$out/lib/vdpau")
  '';

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src)
        outputHash
        outputHashAlgo;
      # Upstream doesn't understand how to use gitlab.
      url = "https://gitlab.freedesktop.org/vdpau/libvdpau/uploads/14b620084c027d546fa0b3f083b800c6/libvdpau-1.2.tar.bz2";
      fullOpts = {
        pgpsigUrl = "https://gitlab.freedesktop.org/vdpau/libvdpau/uploads/0abd351387dbb4aa21a43caf847074f3/libvdpau-1.2.tar.bz2.sig";
        pgpKeyFingerprint = "BD68 A042 C603 DDAD 9AA3  54B0 F56A CC8F 09BA 9635";
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "VDPAU wrapper and trace libraries";
    homepage = https://people.freedesktop.org/~aplattner/vdpau/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

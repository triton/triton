{ stdenv
, fetchurl
, lib
, perl

, alsa-lib
, libjpeg-turbo_1-4
, libx11
, qt5

, channel ? null
}:

# TODO: qt5 support

let
  inherit (stdenv.lib)
    any
    optionals
    optionalString;
in

assert any (n: n == channel) [
  "lib"
  "utils"
];

# See libv4l in all-packages.nix for the libs only (overrides alsa, libX11 & QT)

stdenv.mkDerivation rec {
  name = "v4l-utils-1.12.5";

  src = fetchurl {
    url = "https://linuxtv.org/downloads/v4l-utils/${name}.tar.bz2";
    multihash = "QmPN2qMtk72HxzEN7kPzWoEUdYrZQuY4WeGaCcFQNJUNXL";
    sha256 = "0618162ddb0b57fe7c45407d4d66ed79e3a134cdbc9e72598d34e61d3359e20d";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = optionals (channel == "utils") [
    alsa-lib
    libx11
    qt5
  ] ++ [
    libjpeg-turbo_1-4
  ];

  postPatch = ''
    patchShebangs utils/cec-ctl/msg2ctl.pl
  '';

  preConfigure = optionalString (channel == "utils") ''
    configureFlagsArray+=(
      "--with-udevdir=$out/lib/udev"
    )
  '';

  configureFlags = [
    "--enable-libv4l"
  ] ++ (
    if (channel == "utils") then [
    "--enable-v4l-utils"
    "--enable-qv4l2"
  ] else [
    "--without-libudev"
    "--without-udevdir"
    "--disable-v4l-utils"
    "--disable-qv4l2"
  ]);

  postInstall = ''
    # Create symlink for V4l1 compatibility
    ln -sv $out/include/libv4l1-videodev.h $out/include/videodev.h
    mkdir -pv $out/include/linux
    ln -sv $out/include/libv4l1-videodev.h $out/include/linux/videodev.h
  '';

  parallelBuild = false;
  parallelInstall = false;

  meta = with stdenv.lib; {
    description = "V4L utils and libv4l, provide common image formats regardless of the v4l device";
    homepage = http://linuxtv.org/projects.php;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

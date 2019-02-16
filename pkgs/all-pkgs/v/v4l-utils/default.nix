{ stdenv
, fetchurl
, lib
, perl

, alsa-lib
, libjpeg-turbo
, libx11
, qt5

, channel ? null
}:

# TODO: qt5 support

let
  inherit (lib)
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
  name = "v4l-utils-1.16.3";

  src = fetchurl {
    url = "https://linuxtv.org/downloads/v4l-utils/${name}.tar.bz2";
    multihash = "QmS1DAu73SCCr7scyaGjmFdqkjzGgq9Xodw56RJxKHAq82";
    sha256 = "7c5c0d49c130cf65d384f28e9f3a53c5f7d17bf18740c48c40810e0fbbed5b54";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = optionals (channel == "utils") [
    alsa-lib
    libx11
    qt5
  ] ++ [
    libjpeg-turbo
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
    # Install to a separate directory so that it is easier to remove.
    "--with-libv4l1subdir=libv4l1"
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
    rm -rv "$out"/{include,lib{,/pkgconfig}}/{,lib}v4l1*
  '';

  buildParallel = false;
  installParallel = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprints = [
          # Gregor Jasny
          "05D0 169C 26E4 1593 4181  29DF 199A 64FA DFB5 00FF"
        ];
      };
    };
  };

  meta = with lib; {
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

{ stdenv
, fetchpatch
, fetchTritonPatch
, fetchurl
, lib

, libjpeg
, mesa
}:

let
  inherit (lib)
    boolEn;
in
stdenv.mkDerivation rec {
  name = "jasper-1.900.2";

  src = fetchurl {
    url = "https://www.ece.uvic.ca/~frodo/jasper/software/${name}.tar.gz";
    multihash = "QmSMdvaKu4GTw8LUf8U7RTUh1rkzX4GYYxPVVJNFDmB7xU";
    sha256 = "2a31a38e8f2c84e8e2d011833d5a71a4334a90d63739a17aa342cb81a15c712e";
  };

  propagatedBuildInputs = [
    libjpeg
    mesa
  ];

  patches = [
    (fetchTritonPatch {
      rev = "ed6a70194b140716d65bb604e9040004e379dfe2";
      file = "j/jasper/jasper-CVE-2014-8137-noabort.patch";
      sha256 = "dc4c8abb1ae95f2bfbfa34c9bd377185534bed28ad11828d3f01776194d9eb86";
    })
    (fetchTritonPatch {
      rev = "ed6a70194b140716d65bb604e9040004e379dfe2";
      file = "j/jasper/jasper-CVE-2014-8137-variant2.patch";
      sha256 = "6a899143de357c04ea13740dcf22231028e3423725185478d920096dc09deabe";
    })

    # Backported commits
    (fetchpatch { # CVE-2016-2089
      url = "https://github.com/mdadams/jasper/commit/aa6d9c2bbae9155f8e1466295373a68fa97291c3.patch";
      sha256 = "097ec6d96d2bdf9ca80f895359b01927f61317f7e316b1024b56567ab3c28b51";
    })
    (fetchpatch { # CVE-2015-5203
      url = "https://github.com/mdadams/jasper/commit/e73bb58f99fec0bf9c5d8866e010fcf736a53b9a.patch";
      sha256 = "5caad84414219403387cbecdf4c40836e7b74d35c700c139f5d14ae87ef79a7a";
    })
  ];

  configureFlags = [
    "--enable-shared"
    "--${boolEn (libjpeg != null)}-libjpeg"
    "--${boolEn (mesa != null)}-opengl"
    "--disable-dmalloc"
    "--disable-debug"
    "--disable-special0"
    "--with-x"
  ];

  meta = with lib; {
    description = "JPEG2000 Library";
    homepage = https://www.ece.uvic.ca/~frodo/jasper/;
    license = licenses.free; # JasPer2.0
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

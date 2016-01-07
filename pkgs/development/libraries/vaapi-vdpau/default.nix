{ stdenv, fetchurl, libvdpau, mesa, libva }:
let
  fetchpatch = name: sha256: fetchurl {
    urls = [
      "https://projects.archlinux.org/svntogit/packages.git/plain/trunk/${name}?h=packages/libva-vdpau-driver&id=92c430287af4260c97fefd9b31372c84ef058b3d"
    ];
    inherit name sha256;
  };
in
stdenv.mkDerivation rec {
  name = "libva-vdpau-driver-0.7.4";
  
  src = fetchurl {
    url = "http://www.freedesktop.org/software/vaapi/releases/libva-vdpau-driver/${name}.tar.bz2";
    sha256 = "1fcvgshzyc50yb8qqm6v6wn23ghimay23ci0p8sm8gxcy211jp0m";
  };

  patches = [
    (fetchpatch "libva-vdpau-driver-0.7.4-libvdpau-0.8.patch" "179vp8f346pas00nh15mrrc7mdxpq46421bcgch0xp4pdc17nmjy")
    (fetchpatch "libva-vdpau-driver-0.7.4-glext-missing-definition.patch" "132mnkzzk9cl7p585iyv1ifq5kf6i2r2jc3qv2bf7p8w216gwsvp")
    (fetchpatch "libva-vdpau-driver-0.7.4-VAEncH264VUIBufferType.patch" "166svcav6axkrlb3i4rbf6dkwjnqdf69xw339az1f5yabj72pqqs")
  ];

  buildInputs = [ libvdpau mesa libva ];

  meta = {
    homepage = http://cgit.freedesktop.org/vaapi/vdpau-driver/;
    license = stdenv.lib.licenses.gpl2Plus;
    description = "VDPAU driver for the VAAPI library";
  };
}

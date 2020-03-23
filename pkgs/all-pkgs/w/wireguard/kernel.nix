{ stdenv
, bc
, elfutils
, fetchzip
, perl

, kernel
}:

let
  rev = "cf877de9a8b38422aef6beb514b688a0eedae4d8";
  date = "2020-03-18";
in
stdenv.mkDerivation {
  name = "wireguard-linux-compat-${date}-${kernel.version}";

  src = fetchzip {
    version = 6;
    url = "https://git.zx2c4.com/wireguard-linux-compat/snapshot/wireguard-linux-compat-${rev}.tar.xz";
    multihash = "QmebYStGVwA5YVy8YEjJyN93iwhfUv8pbG1ECR2ctc8wTt";
    sha256 = "2ce9fec119538d652bca15a986cf37085d51593732ab52f1308c3483f421c3f4";
  };

  nativeBuildInputs = [
    bc
    elfutils
    perl
  ];

  preConfigure = ''
    cd src
  '';

  makeFlags = [
    "DEPMOD=true"
    "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "PREFIX=${placeholder "out"}"
    "INSTALL_MOD_PATH=${placeholder "out"}"
    "INSTALL_MOD_STRIP=1"
  ];

  # Kernel code doesn't support our hardening flags
  optFlags = kernel == null;
  pie = kernel == null;
  fpic = kernel == null;
  noStrictOverflow = kernel == null;
  fortifySource = kernel == null;
  stackProtector = kernel == null;
  optimize = kernel == null;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

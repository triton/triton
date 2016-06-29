{ stdenv
, fetchzip

, kernel
, libmnl
}:

stdenv.mkDerivation {
  name = "wireguard-2016-06-29";

  src = fetchzip {
    url = "https://git.zx2c4.com/WireGuard/snapshot/WireGuard-530ee2b2906af4d635d4d5bbabda5250b4a2b33e.tar.xz";
    sha256 = "28a0d50d760f6a67e75d37490888aab7434136c9c5a2ac422fdcd0bee086abdb";
  };

  buildInputs = [
    libmnl
  ];

  preConfigure = ''
    cd src
  '';

  makeFlags = [
    "-C"
    "tools"
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

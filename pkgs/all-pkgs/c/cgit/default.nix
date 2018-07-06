{ stdenv
, fetchzip
, git

, openssl
, zlib
}:

let
  rev = "22583c4992852fff08559c35fde7bf6f673d1644";
  date = "2018-07-05";
in
stdenv.mkDerivation {
  name = "cgit-${date}";

  src = fetchzip {
    version = 6;
    url = "https://git.zx2c4.com/cgit/snapshot/cgit-${rev}.tar.xz";
    multihash = "QmUo56QMxngG8CQn6e9diRKdDNvdogpRZpMN8mC5v3WAjd";
    sha256 = "3ac7d3ff9e5905250b9b5617d6fe6c6571bf0172b1d1617e46cd6dd93760a0a2";
  };

  buildInputs = [
    openssl
    zlib
  ];

  prePatch = ''
    rm -r git
    unpackFile "${git.src}"
    mv git-* git
  '';

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  preInstall = ''
    installFlagsArray+=(
      "CGIT_SCRIPT_PATH=$out/share/cgit/www"
    )
  '';

  preFixup = ''
    find . -type f -executable -exec strip -s -v {} \;
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

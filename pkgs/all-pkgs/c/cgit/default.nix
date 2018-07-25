{ stdenv
, fetchzip
, git

, openssl
, zlib
}:

let
  rev = "5897d950ec1fa084091b06b11a7dca96dc3253a4";
  date = "2018-07-17";
in
stdenv.mkDerivation {
  name = "cgit-${date}";

  src = fetchzip {
    version = 6;
    url = "https://git.zx2c4.com/cgit/snapshot/cgit-${rev}.tar.xz";
    multihash = "QmbvuN6PmsJX4xWzE1TJ8DpLtHkMt8XeRANdpp3DreY2Ux";
    sha256 = "584e8a1ed7b2dd10c89dfd8603e81e5e44968c2ac1e904e5453f8b4ed17ecc1b";
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

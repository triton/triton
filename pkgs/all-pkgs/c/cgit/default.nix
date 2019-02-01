{ stdenv
, fetchzip
, git

, openssl
, zlib
}:

let
  rev = "7d87cd3a215976a480b3c71b017a191597e5cb44";
  date = "2019-01-03";
in
stdenv.mkDerivation {
  name = "cgit-${date}";

  src = fetchzip {
    version = 6;
    url = "https://git.zx2c4.com/cgit/snapshot/cgit-${rev}.tar.xz";
    multihash = "QmY3SdtFJEGigyVA4CiFBfG7D71qkiFn6D6DTdSWwtRL4y";
    sha256 = "033a53f4a5d2f2b72c4580e9fcab7803cb0b2db06f59689fa2da640fe7dceba0";
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

{ stdenv
, fetchzip
, git

, openssl
, zlib
}:

let
  rev = "824138e59194acaf5efe53690d4ef6eaf38e1549";
  date = "2018-08-03";
in
stdenv.mkDerivation {
  name = "cgit-${date}";

  src = fetchzip {
    version = 6;
    url = "https://git.zx2c4.com/cgit/snapshot/cgit-${rev}.tar.xz";
    multihash = "Qmed2HkGD9EB29enBisccWeW8s6suiXE4BBUnnacMidEGp";
    sha256 = "39c2591ffe01e23be76c9859924ea186043075c7974f619e1b87da132e5f75b1";
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

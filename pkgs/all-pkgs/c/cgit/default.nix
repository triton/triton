{ stdenv
, fetchzip
, git

, openssl
, zlib
}:

let
  rev = "dbaee2672be14374acb17266477c19294c6155f3";
  date = "2018-01-19";
in
stdenv.mkDerivation {
  name = "cgit-${date}";

  src = fetchzip {
    version = 5;
    url = "https://git.zx2c4.com/cgit/snapshot/cgit-${rev}.tar.xz";
    multihash = "QmQiyNJddSWgGgKZaJ3MUrHGmWfCUSjxFPSv6Urd1GUUSg";
    sha256 = "e3caa1df9123c38cf48b546ed0c9ae5a454548505fbcf4f57883af741fb5b48c";
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

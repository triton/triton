{ stdenv
, fetchurl

, channel
}:

let
  source = (
    import ./sources.nix {
      inherit (stdenv.lib)
        licenses;
    }
  )."${channel}";
in
stdenv.mkDerivation rec {
  name = "db-${source.version}";

  src = fetchurl {
    url = "http://download.oracle.com/berkeley-db/${name}.tar.gz";
    inherit (source)
      multihash
      sha256;
  };

  configureFlags = [
    "--enable-cxx"
    "--enable-compat185"
    "--enable-dbm"
    "--with-pic"
  ];

  preConfigure = ''
    cd build_unix
    configureScript=../dist/configure
  '';

  postInstall = ''
    rm -rf $out/docs
  '';

  meta = with stdenv.lib; {
    description = "Berkeley DB";
    homepage = http://www.oracle.com/technetwork/database/database-technologies/berkeleydb/index.html;
    license = source.license;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

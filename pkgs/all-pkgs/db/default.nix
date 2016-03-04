{ stdenv
, fetchurl
, channel ? "5"
}:

let
  sources = import ./sources.nix {
    inherit (stdenv.lib) licenses;
  };
  source = sources.${channel};
in
stdenv.mkDerivation rec {
  name = "db-${source.version}";

  src = fetchurl {
    url = "http://download.oracle.com/berkeley-db/${name}.tar.gz";
    inherit (source) sha256;
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
    homepage = "http://www.oracle.com/technetwork/database/database-technologies/berkeleydb/index.html";
    description = "Berkeley DB";
    license = license;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

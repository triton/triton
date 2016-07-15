{ stdenv
, buildPerlPackage
, fetchTritonPatch
, fetchurl
, perl

, DBI
, sqlite
}:

buildPerlPackage rec {
  name = "DBD-SQLite-1.50";

  src = fetchurl {
    url = "mirror://cpan/authors/id/I/IS/ISHIGAKI/${name}.tar.gz";
    sha256 = "3ac513ab73944fd7d4b672e1fe885dc522b6369d38f46a68e67e0045bf159ce1";
  };

  buildInputs = [
    DBI
  ];

  patches = [
    (fetchTritonPatch {
      rev = "0bb5283b08a3a9b17c750fce8d5f2e6d35133e48";
      file = "DBD-SQLite/external-sqlite.patch";
      sha256 = "ccc81ad281c36a4b2fb777a384de71e1629d9a84f2abe9bccb680d529a34bfcb";
    })
  ];

  configureFlags = [
    "SQLITE_LOCATION=${sqlite}"
  ];

  # Remove superfluous sqlite sources
  postInstall = ''
    rm -r $out/${perl.libPrefix}/*/*/auto/share
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

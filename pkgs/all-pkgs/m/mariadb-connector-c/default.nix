{ stdenv
, cmake
, fetchFromGitHub
, ninja

, curl
, krb5_lib
, openssl
, sqlite
, zlib
}:

let
  rev = "3f356c0598ad4785e9b4eff23e03fd662a701070";
  date = "2017-07-07";
in
stdenv.mkDerivation rec {
  name = "mariadb-connector-c-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "MariaDB";
    repo = "mariadb-connector-c";
    inherit rev;
    sha256 = "40749572ddae702b7522dd0bed864f3b5cadb6a4fec798fd4aacb6213d0d0685";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    curl
    krb5_lib
    openssl
    sqlite
    zlib
  ];

  cmakeFlags = [
    "-DINSTALL_LIBDIR=lib"
    "-DWITH_MYSQLCOMPAT=ON"
    "-DWITH_UNITTEST=OFF"
    "-DWITH_EXTERNAL_ZLIB=ON"
    "-DWITH_SQLITE=ON"
  ];

  postInstall = ''
    ln -sv mariadb_config "$out"/bin/mysql_config
    ln -sv mariadb "$out"/include/mysql
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

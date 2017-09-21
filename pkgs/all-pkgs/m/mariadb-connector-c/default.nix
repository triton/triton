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
  rev = "f9a6b8e0864fdb63707419639a34a3377f1b3091";
  date = "2017-09-08";
in
stdenv.mkDerivation rec {
  name = "mariadb-connector-c-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "MariaDB";
    repo = "mariadb-connector-c";
    inherit rev;
    sha256 = "812b1a602ab307924f083e2bb8d48f8312a29f48b0ee37ac8d0e76e5a1095e2c";
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

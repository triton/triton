{ stdenv
, cmake
, fetchFromGitHub
, ninja

, curl
, kerberos
, openssl
, zlib
}:

let
  rev = "3b3b492901956c1ba9283261fe395a64b426c174";
  date = "2018-12-18";
in
stdenv.mkDerivation rec {
  name = "mariadb-connector-c-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "MariaDB";
    repo = "mariadb-connector-c";
    inherit rev;
    sha256 = "5ff9bcefeccade699c2edbb30876f056c9a88c82812d72abddcb4a1c8ba196cb";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    curl
    kerberos
    openssl
    zlib
  ];

  cmakeFlags = [
    "-DINSTALL_LIBDIR=lib"
    "-DWITH_MYSQLCOMPAT=ON"
    "-DWITH_UNITTEST=OFF"
    "-DWITH_EXTERNAL_ZLIB=ON"
  ];

  # Hack to make sure we include the libpath in the _config binaries
  preBuild = ''
    sed \
      -e 's,-lz,-L${zlib}/lib -lz,g' \
      -e 's,-lssl,-L${openssl}/lib -lssl,g' \
      -i mariadb_config/mariadb_config.c
  '';

  postInstall = ''
    ln -sv mariadb_config "$out"/bin/mysql_config
    ln -sv mariadb "$out"/include/mysql
  '';

  # Make sure we have all the needed lib paths
  preFixupCheck = ''
    echo 'void main() {}' | NIX_LDFLAGS= gcc -x c -o main - $("$out"/bin/mariadb_config --libs)
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

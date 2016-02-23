{ stdenv
, fetchurl

, iana_etc
, mime-types
, tzdata
}:

stdenv.mkDerivation rec {
  name = "go-${version}";
  version = "1.4.3";

  src = fetchurl {
    url = "https://github.com/golang/go/archive/go${version}.tar.gz";
    sha256 = "0rcrhb3r997dw3d02r37zp26ln4q9n77fqxbnvw04zs413md5s35";
  };

  # I'm not sure what go wants from its 'src', but the go installation manual
  # describes an installation keeping the src.
  preUnpack = ''
    mkdir -p $out/share
    cd $out/share
  '';

  prePatch = ''
    # Ensure that the source directory is named go
    cd ..
    if [ ! -d go ]; then
      mv * go
    fi

    cd go
  '';

  patches = [
    ./remove-tools-1.4.patch
  ];

  postPatch = ''
    patchShebangs ./ # replace /bin/bash

    # The os test wants to read files in an existing path. Just don't let it be /usr/bin.
    sed -i 's,/usr/bin,'"`pwd`", src/os/os_test.go
    sed -i 's,/bin/pwd,'"`type -P pwd`", src/os/os_test.go

    # Disable the hostname test
    sed -i '/TestHostname/areturn' src/os/os_test.go

    # Disable the port test
    rm src/net/port_test.go

    # Disable the multicast test
    rm src/net/multicast_test.go

    sed -i '\#"/etc/mime.types",#i"${mime-types}/etc/mime.types",' src/mime/type_unix.go
    sed -i 's,/etc/protocols,${iana_etc}/etc/protocols,g' src/net/lookup_unix.go
    sed -i 's,/etc/services,${iana_etc}/etc/services,g' src/net/port_unix.go src/net/parse_test.go
    sed -i '\#"/usr/share/zoneinfo/",#i"${tzdata}/share/zoneinfo/",' src/time/zoneinfo_unix.go
  '';

  GOOS = "linux";
  GOARCH =
    if stdenv.system == "i686-linux" then
      "386"
    else if stdenv.system == "x86_64-linux" then
      "amd64"
    else
      throw "Unsupported system.";
  GO386 = 387; # from Arch: don't assume sse2 on i686
  CGO_ENABLED = 1;

  installPhase = ''
    mkdir -p "$out/bin"
    export GOROOT="$(pwd)/"
    export GOBIN="$out/bin"
    export PATH="$GOBIN:$PATH"
    cd ./src
    ./all.bash
  '';

  setupHook = ./setup-hook.sh;

  meta = with stdenv.lib; {
    homepage = http://golang.org/;
    description = "The Go Programming language";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

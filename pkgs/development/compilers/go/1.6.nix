{ stdenv
, fetchurl
, tzdata
, iana_etc
, mime-types
, go_1_4
, runCommand
, perl
, which
}:

let
  goBootstrap = runCommand "go-bootstrap" {} ''
    mkdir $out
    cp -rf ${go_1_4}/* $out/
    chmod -R u+w $out
    find $out -name "*.c" -delete
    cp -rf $out/bin/* $out/share/go/bin/
  '';
in

stdenv.mkDerivation rec {
  name = "go-${version}";
  version = "1.6rc2";

  src = fetchurl {
    url = "https://github.com/golang/go/archive/go${version}.tar.gz";
    sha256 = "00vylhw8603pnbf4w0apk9d0wkkcrsfmnkljlhmwdndp3h3pw4qc";
  };

  # perl is used for testing go vet
  nativeBuildInputs = [
    perl
    which
  ];

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
    patchShebangs ./ # replace /bin/bash

    # The os test wants to read files in an existing path. Just don't let it be /usr/bin.
    sed -i 's,/usr/bin,'"`pwd`", src/os/os_test.go
    sed -i 's,/bin/pwd,'"`type -P pwd`", src/os/os_test.go
    # Disable the hostname test
    sed -i '/TestHostname/areturn' src/os/os_test.go
    # Remove the api check as it never worked
    sed -i '/src\/cmd\/api\/run.go/ireturn nil' src/cmd/dist/test.go

    sed -i '\#"/etc/mime.types",#i"${mime-types}/etc/mime.types",' src/mime/type_unix.go
    sed -i 's,/etc/protocols,${iana_etc}/etc/protocols,g' src/net/lookup_unix.go
    sed -i 's,/etc/services,${iana_etc}/etc/services,g' src/net/port_unix.go src/net/parse_test.go
    sed -i '\#"/usr/share/zoneinfo/",#i"${tzdata}/share/zoneinfo/",' src/time/zoneinfo_unix.go

    # We need to fix shebangs which will be used in an output script
    # We can't use patch shebangs because this is an embedded script fix
    sed -i 's,#!/usr/bin/env bash,#! ${stdenv.shell},g' misc/cgo/testcarchive/test.bash
  '';

  patches = [
    ./remove-tools-1.5.patch
  ];

  GOOS = if stdenv.isLinux then "linux" else throw "Unknown GOOS";
  GOARCH = if stdenv.system == "i686-linux" then "386"
           else if stdenv.system == "x86_64-linux" then "amd64"
           else throw "Unsupported system";
  GO386 = 387; # from Arch: don't assume sse2 on i686
  CGO_ENABLED = 1;
  GOROOT_BOOTSTRAP = "${goBootstrap}/share/go";

  installPhase = ''
    mkdir -p "$out/bin"
    export GOROOT="$(pwd)/"
    export GOBIN="$out/bin"
    export PATH="$GOBIN:$PATH"
    cd ./src
    echo Building
    ./all.bash
  '';

  preFixup = ''
    rm -r $out/share/go/pkg/bootstrap
  '';

  setupHook = ./setup-hook.sh;

  disallowedReferences = [ go_1_4 ];

  meta = with stdenv.lib; {
    branch = "1.6";
    homepage = http://golang.org/;
    description = "The Go Programming language";
    license = licenses.bsd3;
    maintainers = with maintainers; [ cstrahan wkennington ];
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };
}

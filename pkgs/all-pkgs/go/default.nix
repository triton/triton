{ stdenv
, fetchTritonPatch
, fetchurl
, perl
, which
, patchelf

, iana_etc
, mime-types
, tzdata

, channel ? "1.6"
}:

let
  sources = import ./sources.nix;

  source = sources."${channel}";

  goPlatform =
    if stdenv.hostSystem == "x86_64-linux" then
      "linux-amd64"
    else
      throw "Unsupported System";

  goBootstrap = stdenv.mkDerivation {
    name = "go-bootstrap";

    src = fetchurl {
      url = "https://storage.googleapis.com/golang/go${channel}.${goPlatform}.tar.gz";
      sha256 = source.sha256Bootstrap."${stdenv.hostSystem}";
    };

    nativeBuildInputs = [
      patchelf
    ];

    buildPhase = ''
      strip bin/*
      find bin -type f -exec patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" {} \;
    '';

    installPhase = ''
      mkdir -p $out/share
      ln -s .././ $out/share/go
      cp -r bin src pkg $out

      # Test that the install worked
      $out/bin/go help
    '';
  };
in

stdenv.mkDerivation {
  name = "go-${source.version}";

  src = fetchurl {
    url = "https://storage.googleapis.com/golang/go${source.version}.src.tar.gz";
    inherit (source) sha256;
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
  '';

  patches = [
    (fetchTritonPatch {
      rev = "e55948eaf64c06f2c147cb6b18522a9d9bf72641";
      file = "go/remove-tools.patch";
      sha256 = "275c4428ce5c0ff45e853f93b8259ed656fd2c53cdb83aeb287a9f305c1f84a7";
    })
  ];

  postPatch = ''
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

  disallowedReferences = [ goBootstrap ];

  meta = with stdenv.lib; {
    branch = "1.6";
    homepage = http://golang.org/;
    description = "The Go Programming language";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

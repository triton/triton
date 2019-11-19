{ stdenv
, fetchTritonPatch
, fetchurl
, patchelf

, iana-etc
, mime-types
, tzdata

, channel
}:

let
  inherit (stdenv.lib)
    concatStringsSep;

  inherit ((import ./sources.nix)."${channel}")
    version
    sha256
    sha256Bootstrap
    patches;

  goPlatform =
    if stdenv.hostSystem == "x86_64-linux" then
      "linux-amd64"
    else
      throw "Unsupported System";

  goBootstrap = stdenv.mkDerivation {
    name = "go-bootstrap";

    src = fetchurl {
      url = "https://storage.googleapis.com/golang/go${channel}.${goPlatform}.tar.gz";
      hashOutput = false;
      sha256 = sha256Bootstrap."${stdenv.hostSystem}";
    };

    nativeBuildInputs = [
      patchelf
    ];

    buildPhase = ''
      echo "int main() { }" >main.c
      cc -o main main.c
      strip bin/*
      find bin -type f -exec patchelf --set-interpreter "$(patchelf --print-interpreter ./main)" {} \;
    '';

    installPhase = ''
      mkdir -p $out/share
      ln -s .././ $out/share/go
      cp -r bin src pkg $out

      # Test that the install worked
      $out/bin/go help

      find "$out" -name testdata -prune -exec rm -r {} \;
    '';
  };
in
stdenv.mkDerivation {
  name = "go-${version}";

  src = fetchurl {
    url = "https://storage.googleapis.com/golang/go${version}.src.tar.gz";
    hashOutput = false;
    inherit sha256;
  };

  # I'm not sure what go wants from its 'src', but the go installation manual
  # describes an installation keeping the src.
  preUnpack = ''
    mkdir -p $out/share
    cd $out/share
  '';

  patches = map (p: fetchTritonPatch p) patches;

  postPatch = ''
    # Don't run tests by default
    sed -i '/run.bash/d' src/all.bash

    grep -q '"/etc/mime.types"' src/mime/type_unix.go
    sed -i '\#"/etc/mime.types",#i"${mime-types}/etc/mime.types",' src/mime/type_unix.go
    grep -q '"/etc/protocols"' src/net/lookup_unix.go
    sed -i 's,/etc/protocols,${iana-etc}/etc/protocols,g' src/net/lookup_unix.go
    grep -q '"/usr/share/zoneinfo/"' src/time/zoneinfo_unix.go
    sed -i '\#"/usr/share/zoneinfo/",#i"${tzdata.data}/share/zoneinfo/",' src/time/zoneinfo_unix.go

    patchShebangs src/all.bash
  '';

  preBuild = ''
    # Incremental re-compilation requires a path relative to home to store
    # the object files
    export HOME="$TMPDIR"

    # For some reason the go toolchain only adds an rpath to our libc and not
    # all of our DT_NEEDED entries. This forces the toolchain to set all of
    # the needed rpaths.
    echo "int main() { }" >main.c
    cc -o main main.c
    patchelf --print-rpath main
    export GO_LDFLAGS="-r=$(patchelf --print-rpath main)"
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

    find "$out/bin" -mindepth 1 -exec mv {} "$out/share/go/bin" \;
    rmdir "$out/bin"
    ln -srv "$out"/share/go/bin "$out/bin"
  '';

  preFixup = ''
    #find "$out"/share/go/pkg -maxdepth 1 -mindepth 1 \( -not -name tool -and -not -name include \) -exec rm -rv {} \;
    rm -rv "$out"/share/go/pkg/obj
    rm -rv "$out"/share/go/{doc,misc,test}
    find "$out" -type f \( -name run -or -name \*.bash -or -name \*.sh -or -name \*.rc \) -print -delete
    find "$out" -name testdata -prune -exec rm -rv {} \;

    while read exe; do
      strip $exe || true
      patchelf --shrink-rpath $exe || true
    done < <(find $out/share/ -executable -and -not -type d)

    # Remove perl stuff we don't need
    find "$out" -name '*'.pl -print -delete
  '';

  dontStrip = true;

  setupHook = ./setup-hook.sh;

  passthru = {
    inherit
      channel
      version;
  };

  meta = with stdenv.lib; {
    branch = channel;
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

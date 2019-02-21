{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, type ? "full"
}:

let
  inherit (lib)
    optionalString;

  version = "1.0.6.0.2";
in
stdenv.mkDerivation rec {
  name = "bzip2-${version}";

  src = fetchurl {
    #url = "http://www.bzip.org/${version}/${name}.tar.gz";  # upstream
    # https://github.com/NixOS/nixpkgs/issues/31396#issuecomment-342900842
    url = "http://ftp.suse.com/pub/people/sbrabec/bzip2/tarballs/${name}.tar.gz";
    multihash = "QmNXBLhp5sz86D8QzAseNQkxiKuSKU4wK8DnXQY7GbPbmA";
    sha256 = "167870372e0e1def1de4cea26020a5931cdc07f1075e0d2f797c2fe37665c5b0";
  };

  patches = [
    # Fix buffer overflow in bzip2recover
    # TODO: cite fedora issue
    (fetchTritonPatch {
      rev = "63e801888f6788d616d360a08f25604e2ac9cdcf";
      file = "b/bzip2/bzip2-1.0.4-bzip2recover.patch";
      sha256 = "0585fb92a4b409404147a3f940ed2ca03b3eaed1ec4fb68ae6ad74db668bea83";
    })
    # Fix bzgrep compat with POSIX shells
    (fetchTritonPatch {
      rev = "63e801888f6788d616d360a08f25604e2ac9cdcf";
      file = "b/bzip2/bzip2-1.0.4-POSIX-shell.patch";
      sha256 = "e8826fedfed105ba52c85a2e43589ba37424513cb932072136ceac01ceb0ec99";
    })
    (fetchTritonPatch {
      rev = "63e801888f6788d616d360a08f25604e2ac9cdcf";
      file = "b/bzip2/bzip2-1.0.6-CVE-2016-3189.patch";
      sha256 = "2ad8ead7e43cb584ea5c1df737394a8ca56ea3cac504756361e507dc5a263325";
    })
    # Fix include path
    (fetchTritonPatch {
      rev = "63e801888f6788d616d360a08f25604e2ac9cdcf";
      file = "b/bzip2/bzip2-1.0.6-mingw.patch";
      sha256 = "8da568f1d7daac4ac6b9d7946dd3b807e062b5a1710a2548029cc4f158e8d717";
    })
    # https://bugs.gentoo.org/show_bug.cgi?id=82192
    (fetchTritonPatch {
      rev = "63e801888f6788d616d360a08f25604e2ac9cdcf";
      file = "b/bzip2/bzip2-1.0.6-progress.patch";
      sha256 = "f93e6b50082a8e880ee8436c7ec6a65a8f01e9282436af77f95bb259b1c7f7f7";
    })
  ];

  postInstall = optionalString (type != "full") ''
    rm -r "$out"/share
  '';

  dontPatchShebangs = true;

  allowedReferences = [
    "out"
  ] ++ stdenv.cc.runtimeLibcLibs;

  meta = with lib; {
    description = "high-quality data compression program";
    # upstream http://www.bzip.org
    homepage = http://ftp.suse.com/pub/people/sbrabec/bzip2/;
    license = licenses.free;  # bzip2
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

{ lib
, hostSystem
}:

let
  makeUrls = { multihash, nix-hash, file, sha256, executable ? false }:
    import <nix/fetchurl.nix> {
      name = file;
      url = "https://ipfs.wak.io/ipfs/${multihash}";
      #urls = [
      #  "http://127.0.0.1/ipfs/${multihash}"
      #  "http://127.0.0.1:8080/ipfs/${multihash}"
      #  "https://pub.wak.io/nixos/bootstrap/${hostSystem}/${nix-hash}/${file}"
      #  "https://ipfs.wak.io/ipfs/${multihash}"
      #  "https://gateway.ipfs.io/ipfs/${multihash}"
      #];
      inherit sha256 executable;
    };
in
if [ hostSystem ] == lib.platforms.x86_64-linux then {
  busybox = makeUrls {
    file = "bootstrap-busybox";
    nix-hash = "dayf8f2nvd7yrvagfipkss3cvwzym7j1";
    multihash = "QmQ1dche6tk7oEAcV5Q4KMSVPC54ikhbAsfcaWqd7buUUg";
    sha256 = "1bn3v1jfxkj0pb4q1yvlrlphy9izxx7rsbns43j8fkgqfqc3a2w1";
    executable = true;
  };

  bootstrapTools = makeUrls {
    file = "bootstrap-tools";
    nix-hash = "dayf8f2nvd7yrvagfipkss3cvwzym7j1";
    multihash = "QmUdKGWBGTeh1MRrwufeJoNeL2gNnHvMxzbEKT4pT8ayKD";
    sha256 = "956fe1a2a083d2066b2f33a17d711ea4904397911c70a3b4b030e50c5b004947";
  };

  langC = true;
  langCC = true;
  isGNU = true;
} else if [ hostSystem ] == lib.platforms.i686-linux then {
  busybox = makeUrls {
    file = "bootstrap-busybox";
    nix-hash = "sf1ydfr2icbxvv9vfg8b7nzic8a9i55n";
    multihash = "QmWK7MwnR66b79g85SkkCMyWHddNrMHpk7ieHup1JJ9t47";
    sha256 = "0m8z670i4s4p4daj2776frazrprmm3c9gsnzslz9dx0hqd70p3iq";
    executable = true;
  };

  bootstrapTools = makeUrls {
    file = "bootstrap-tools";
    nix-hash = "sf1ydfr2icbxvv9vfg8b7nzic8a9i55n";
    multihash = "QmXJQh3utXkx93tRGA6t8puYKyBkaaXC2fdNwGTHzeyFft";
    sha256 = "dd27b7e023bc8fe375790325771741a9342712caa205533900279d2a7051e245";
  };

  langC = true;
  langCC = true;
  isGNU = true;
} else
  throw "Unsupported System ${hostSystem}"

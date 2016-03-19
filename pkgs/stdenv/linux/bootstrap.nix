{ lib
, hostSystem
}:

let
  makeUrls = { multihash, nix-hash, file, sha256, executable ? false }:
    import <nix/fetchurl.nix> {
      name = file;
      url = "https://gateway.ipfs.io/ipfs/${multihash}";
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
  busybox = import <nix/fetchurl.nix> {
    url = "https://pub.wak.io/nixos/bootstrap/i686-linux/ygk76d6amwb610f10nqnq08h1gmmc3j0/busybox";
    sha256 = "16f62zvr1w1ffyn84n4yspb549awnx6jf778i3wh5893i0d4dsv9";
    executable = true;
  };

  bootstrapTools = import <nix/fetchurl.nix> {
    url = "https://pub.wak.io/nixos/bootstrap/i686-linux/ygk76d6amwb610f10nqnq08h1gmmc3j0/bootstrap-tools.tar.xz";
    sha256 = "af7b3bde18fdf951588c05c1503ef504e0ae87be296161021ede4df0989b4acc";
  };

  langC = true;
  langCC = true;
  isGNU = true;
} else
  throw "Unsupported System ${hostSystem}"

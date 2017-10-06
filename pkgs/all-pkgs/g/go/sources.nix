{
  "1.8" = {
    version = "1.8.3";
    sha256 = "5f5dea2447e7dcfdc50fa6b94c512e58bfba5673c039259fd843f68829d99fa6";
    sha256Bootstrap = {
      "x86_64-linux" = "53ab94104ee3923e228a2cb2116e5e462ad3ebaeea06ff04463479d7f12d27ca";
    };
    patches = [
      {
        rev = "2426b84827f78c72ffcb9da51d34b889fcb8b056";
        file = "go/remove-tools.patch";
        sha256 = "647282e43513a6d0a71aa406f54a0b13d3331f825bc60fedebaa32d757f0e483";
      }
    ];
  };
  "1.9" = {
    version = "1.9.1";
    sha256 = "a84afc9dc7d64fe0fa84d4d735e2ece23831a22117b50dafc75c1484f1cb550e";
    sha256Bootstrap = {
      "x86_64-linux" = "d70eadefce8e160638a9a6db97f7192d8463069ab33138893ad3bf31b0650a79";
    };
    patches = [
      {
        rev = "2426b84827f78c72ffcb9da51d34b889fcb8b056";
        file = "go/remove-tools.patch";
        sha256 = "647282e43513a6d0a71aa406f54a0b13d3331f825bc60fedebaa32d757f0e483";
      }
      {
        rev = "9ea313ea633a868f95db3f0883573961edb06abd";
        file = "g/go/0001-cmd-compile-replace-GOROOT-in-line-directives.patch";
        sha256 = "7c37ad5bf8d40a40ae44f1caa61f3d7c27bdf7a9aa2f27e8b769e6d9972959dd";
      }
    ];
  };
}

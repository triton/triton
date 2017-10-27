{
  "1.8" = {
    version = "1.8.5";
    sha256 = "4949fd1a5a4954eb54dd208f2f412e720e23f32c91203116bed0387cf5d0ff2d";
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
    version = "1.9.2";
    sha256 = "665f184bf8ac89986cfd5a4460736976f60b57df6b320ad71ad4cef53bb143dc";
    sha256Bootstrap = {
      "x86_64-linux" = "d70eadefce8e160638a9a6db97f7192d8463069ab33138893ad3bf31b0650a79";
    };
    patches = [
      {
        rev = "2426b84827f78c72ffcb9da51d34b889fcb8b056";
        file = "go/remove-tools.patch";
        sha256 = "647282e43513a6d0a71aa406f54a0b13d3331f825bc60fedebaa32d757f0e483";
      }
    ];
  };
}

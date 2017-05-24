{
  "1.8" = {
    version = "1.8.2";
    sha256 = "e10401faaa8ae29dbe87349c1814b07b1903d453f822215d7b274bbc335cbf79";
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
}

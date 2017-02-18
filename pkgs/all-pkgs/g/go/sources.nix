{
  "1.8" = {
    version = "1.8";
    sha256 = "406865f587b44be7092f206d73fc1de252600b79b3cacc587b74b5ef5c623596";
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
  "1.7" = {
    version = "1.7.5";
    sha256 = "4e834513a2079f8cbbd357502cccaac9507fd00a1efe672375798858ff291815";
    sha256Bootstrap = {
      "x86_64-linux" = "702ad90f705365227e902b42d91dd1a40e48ca7f67a2f4b2fd052aaa4295cd95";
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

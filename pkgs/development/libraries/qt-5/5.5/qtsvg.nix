{ qtSubmodule, qtbase, zlib }:

qtSubmodule {
  name = "qtsvg";
  buildInputs = [ zlib ];
  qtInputs = [ qtbase ];
}

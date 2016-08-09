{ stdenv
}:

stdenv.mkDerivation {
  name = "compiler-test";

  buildCommand = ''
    set -x

    # Check for a regression where we have CFLAG includes in the wrong order which breaks compilation
    g++ -fno-exceptions -fno-strict-aliasing -fno-rtti -ffunction-sections -fdata-sections -fno-exceptions -fno-math-errno -std=gnu++0x ${./include-test.cxx}
    ./a.out
    touch $out
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

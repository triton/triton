{ stdenv
, lib
}:

stdenv.mkDerivation {
  name = "compiler-regression";

  buildCommand = ''
    echo '#include <cstdio>' >>out.cpp
    echo 'int main() {' >>out.cpp
    echo 'printf("FILE:      %s\n", __FILE__);' >>out.cpp
    echo 'printf("DATE:      %s\n", __DATE__);' >>out.cpp
    echo 'printf("TIME:      %s\n", __TIME__);' >>out.cpp
    echo 'printf("TIMESTAMP: %s\n", __TIMESTAMP__);' >>out.cpp
    echo 'return 0; }' >>out.cpp

    set -x
    export NIX_DEBUG=1
    mkdir -p "$out"/bin
    echo "SOURCE_DATE_EPOCH: $SOURCE_DATE_EPOCH"

    g++ -std=c++17 -O2 -o "$out"/bin/out1 $(pwd)/out.cpp
    # Make sure prefix mapping / date rewriting is working for macros
    sleep 1
    # Make sure timestamps are bound
    touch out.cpp
    g++ -std=c++17 -O2 -o "$out"/bin/out2 $(pwd)/out.cpp
    diff -q "$out"/bin/out{1,2}

    # Make sure LTO is deterministic
    g++ -std=c++17 -O2 -flto -o "$out"/bin/out4 $(pwd)/out.cpp
    mv "$out"/bin/out{4,3}
    g++ -std=c++17 -O2 -flto -o "$out"/bin/out4 $(pwd)/out.cpp
    diff -q "$out"/bin/out{3,4}

    set +x
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

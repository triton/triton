{ stdenv
, fetchFromGitHub
}:

let
  rev = "7b68537ac11fa62e923fd26aa87e206dc93a9a55";
  date = "2018-03-27";
in
stdenv.mkDerivation rec {
  name = "iniparser-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "ndevilla";
    repo = "iniparser";
    inherit rev;
    sha256 = "69e5adca2de8a9eaec44a03d5c03c5126818fd2fc2c806956739e715d9244540";
  };

  postPatch = ''
    grep -q '/usr' iniparser.pc
    sed -i "s,/usr,$out," iniparser.pc
  '';

  installPhase = ''
    for file in src/*.h; do
      install -D -m644 -v "$file" "$out"/include/$(basename "$file")
    done

    shared_lib="$(echo libiniparser.so.*)"
    install -D -m644 -v "$shared_lib" "$out"/lib/"$shared_lib"
    ln -sv "$shared_lib" "$out"/lib/libiniparser.so

    install -D -m644 -v iniparser.pc "$out"/lib/pkgconfig/iniparser.pc
  '';

  meta = with stdenv.lib; {
    description = "Free standalone ini file parsing library";
    homepage = http://ndevilla.free.fr/iniparser;
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}

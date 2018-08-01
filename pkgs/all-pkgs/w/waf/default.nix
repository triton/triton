{ stdenv
, fetchurl
, lib

, python

, channel
}:

let
  autowaf = fetchurl {
    # r101
    # This is not a persistent URL since it is the SVN repo, so we rely on
    # using the multihash.
    url = "http://svn.drobilla.net/autowaf/autowaf.py";
    multihash = "Qmbztdz9ry33VWVtgzASTbXDwcwxKtmFBZ1y5nsHA1rE97";
    sha256 = "6cecb0c26bcbe046f8ef4742ae46834518dabff59dfab68dd2ae1f9704b193bd";
  };
  lv2 = fetchurl {
    # r101
    # See autowaf note.
    url = "http://svn.drobilla.net/autowaf/lv2.py";
    multihash = "QmSkRjCoADgQ5EDDPrQVDWYfMZCkx9rsYMiHHoE6mYsDfU";
    sha256 = "12ce4d81d9bf32283324c26db40c4ab459b61bc24891969708ec0eeaf96f902d";
  };

  sources = {
    "1.9" = {
      version = "1.9.15";
      multihash = "QmaXJ7fQJTfM77DNnEg4HH6b6odMYtKpHhVVEiqmZV5EQh";
      sha256 = "4b7b92aaf90828853d57bed9a89a7c0e965d5af3c03717b970d67ff3ae4f2483";
    };
    "2.0" = {
      version = "2.0.10";
      multihash = "QmZPsPnS4zXKU7yZjQeJdJewYjjAiKhLDUnMq6HtHFSyT2";
      sha256 = "6550f9b7b7ad5c5f55c7e3472bdae041f3e2f47c1f905fa3c79c172aa91403ed";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "waf-${source.version}";

  src = fetchurl {
    url = "https://waf.io/${name}.tar.bz2";
    hashOutput = false;
    inherit (source)
      multihash
      sha256;
  };

  buildInputs = [
    python
  ];

  PYTHON_EXE = "${python.interpreter}";

  setupHook = ./setup-hook.sh;

  configurePhase = ''
    ${python.interpreter} waf-light configure
  '';

  buildPhase = ''
    cp -v ${autowaf} autowaf.py
    cp -v ${lv2} lv2.py
    ${python.interpreter} waf-light build --tools=$(pwd)/autowaf.py,$(pwd)/lv2.py
  '';

  installPhase = ''
    install -D -m755 -v waf $out/bin/waf
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      # Thomas Nagy
      pgpKeyFingerprint = "8AF2 2DE5 A068 22E3 474F  3C70 49B4 C67C 0527 7AAA";
    };
  };

  meta = with lib; {
    description = "Meta build system";
    homepage = https://waf.io/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

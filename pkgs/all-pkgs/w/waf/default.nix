{ stdenv
, fetchFromGitLab
, fetchurl
, lib

, python
}:

let
  autooptions = stdenv.mkDerivation rec {
    name = "waf-autooptions-2018-10-06";

    src = fetchFromGitLab {
      version = 6;
      owner = "karllinden";
      repo = "waf-autooptions";
      rev = "cc16822604501c96af265a2e3c51855d2aed635f";
      sha256 = "69702af83555ce127765752bb55acfa0412ff436d18569900349d60e10f3e569";
    };

    installPhase = ''
      mkdir -v $out
      cp -v __init__.py $out/autooptions.py
    '';

    meta = with lib; {
      license = licenses.bsd2;
    };
  };

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
in
stdenv.mkDerivation rec {
  name = "waf-2.0.14";

  src = fetchurl {
    url = "https://waf.io/${name}.tar.bz2";
    multihash = "Qmazf5F7byK6qQA8HDoEcfyNEEKwP7PJzzkNiJUdtnSb6C";
    hashOutput = false;
    sha256 = "c74055d7452540ad66c12d955c09f62a9fde0e23b0ab3c43984dc879b4bb51f4";
  };

  buildInputs = [
    python
  ];

  PYTHON_EXE = "${python.interpreter}";

  configurePhase = ''
    ${python.interpreter} waf-light configure
  '';

  buildPhase = ''
    cp -v ${autooptions}/autooptions.py autooptions.py
    cp -v ${autowaf} autowaf.py
    cp -v ${lv2} lv2.py
    ${python.interpreter} waf-light build --tools=$(pwd)/autooptions.py,$(pwd)/autowaf.py,$(pwd)/lv2.py
  '';

  installPhase = ''
    install -D -m755 -v waf $out/bin/waf
    mkdir -p "$dev"
  '';

  postFixup = ''
    mkdir -p "$dev"/{bin,nix-support}
    ln -sv "$out"/bin/waf "$dev"/bin
    substituteAll '${./setup-hook.sh}' "$dev/nix-support/setup-hook"
  '';

  outputs = [ "out" "dev" ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        # Thomas Nagy
        pgpKeyFingerprint = "8AF2 2DE5 A068 22E3 474F  3C70 49B4 C67C 0527 7AAA";
      };
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

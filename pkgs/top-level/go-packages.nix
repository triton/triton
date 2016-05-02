/* This file defines the composition for Go packages. */

{ overrides, stdenv, go, buildGoPackage, git
, fetchgit, fetchhg, fetchurl, fetchzip, fetchFromGitHub, fetchFromBitbucket, fetchbzr, pkgs }:

let
  self = _self // overrides; _self = with self; {

  inherit go buildGoPackage;

  fetchGxPackage = { src, sha256 }: stdenv.mkDerivation {
    name = "gx-src-${src.name}";

    impureEnvVars = [ "NIX_API" ];
    buildCommand = ''
      if ! [ -f /etc/ssl/certs/ca-certificates.crt ]; then
        echo "Missing /etc/ssl/certs/ca-certificates.crt" >&2
        echo "Please update to a version of nix which supports ssl." >&2
        exit 1
      fi

      unpackDir="$TMPDIR/src"
      mkdir "$unpackDir"
      cd "$unpackDir"
      unpackFile "${src}"
      cd *

      mtime=$(find . -type f -print0 | xargs -0 -r stat -c '%Y' | sort -n | tail -n 1)
      if [ "$(( $(date -u '+%s') - 600 ))" -lt "$mtime" ]; then
        str="The newest file is too close to the current date (10 minutes):\n"
        str+="  File: $(date -u -d "@$mtime")\n"
        str+="  Current: $(date -u)\n"
        echo -e "$str" >&2
        exit 1
      fi
      echo -n "Clamping to date: " >&2
      date -d "@$mtime" --utc >&2

      gx --verbose install --global

      echo "Building GX Archive" >&2
      cd "$unpackDir"
      tar --sort=name --owner=0 --group=0 --numeric-owner \
        --mode=go=rX,u+rw,a-s \
        --clamp-mtime --mtime=@$mtime \
        -c . | brotli --quality 6 --output "$out"
    '';

    buildInputs = [ gx.bin ];
    outputHashAlgo = "sha256";
    outputHashMode = "flat";
    outputHash = sha256;
    preferLocalBuild = true;
  };

  buildFromGitHub =
    { rev
    , date ? null
    , owner
    , repo
    , sha256
    , gxSha256 ? null
    , goPackagePath ? "github.com/${owner}/${repo}"
    , name ? baseNameOf goPackagePath
    , ...
    } @ args:
    buildGoPackage (args // (let
        name' = "${name}-${if date != null then date else if builtins.stringLength rev != 40 then rev else stdenv.lib.strings.substring 0 7 rev}";
      in {
        inherit rev goPackagePath;
        name = name';
        src = let
          src' = fetchFromGitHub {
            name = name';
            inherit rev owner repo sha256;
          };
        in if gxSha256 == null then
          src'
        else
          fetchGxPackage { src = src'; sha256 = gxSha256; };
      })
  );

  buildFromGoogle = { rev, date ? null, repo, sha256, name ? repo, goPackagePath ? "google.golang.org/${repo}", ... }@args: buildGoPackage (args // (let
      name' = "${name}-${if date != null then date else if builtins.stringLength rev != 40 then rev else stdenv.lib.strings.substring 0 7 rev}";
    in {
      inherit rev goPackagePath;
      name = name';
      src  = fetchzip {
        name = name';
        url = "https://code.googlesource.com/go${repo}/+archive/${rev}.tar.gz";
        inherit sha256;
        stripRoot = false;
        purgeTimestamps = true;
      };
    })
  );

  ## OFFICIAL GO PACKAGES

  appengine = buildFromGitHub {
    rev = "e234e71924d4aa52444bc76f2f831f13fa1eca60";
    date = "2016-04-18";
    owner = "golang";
    repo = "appengine";
    sha256 = "06l62j64mjgmfc295m5dmyfizbwmvs5cnfs0cj2hrl5xm5hpprr8";
    goPackagePath = "google.golang.org/appengine";
    propagatedBuildInputs = [ protobuf net ];
  };

  crypto = buildFromGitHub {
    rev = "285fb2ed20d1dc450fc743a1b3ff7c36bef372b9";
    date = "2016-04-26";
    owner    = "golang";
    repo     = "crypto";
    sha256 = "0z983nnzq9032j25xii52b0bz6qj6jl444qswz6alk3gh448m6qa";
    goPackagePath = "golang.org/x/crypto";
    goPackageAliases = [
      "code.google.com/p/go.crypto"
      "github.com/golang/crypto"
    ];
    buildInputs = [
      net_crypto_lib
    ];
  };

  glog = buildFromGitHub {
    rev = "23def4e6c14b4da8ac2ed8007337bc5eb5007998";
    date = "2016-01-25";
    owner  = "golang";
    repo   = "glog";
    sha256 = "0wj30z2r6w1zdbsi8d14cx103x13jszlqkvdhhanpglqr22mxpy0";
  };

  codesearch = buildFromGitHub {
    rev = "0.0.0";
    date   = "2015-06-17";
    owner  = "google";
    repo   = "codesearch";
    sha256 = "12bv3yz0l3bmsxbasfgv7scm9j719ch6pmlspv4bd4ix7wjpyhny";
  };

  image = buildFromGitHub {
    rev = "0.0.0";
    date = "2016-01-02";
    owner = "golang";
    repo = "image";
    sha256 = "05c5qrph5r5ikzxw1mlgihx8396hawv38q2syjvwbxdiib9gfg9k";
    goPackagePath = "golang.org/x/image";
    goPackageAliases = [ "github.com/golang/image" ];
  };

  net = buildFromGitHub {
    rev = "35ec611a141ee705590b9eb64d673f9e6dfeb1ac";
    date = "2016-04-28";
    owner  = "golang";
    repo   = "net";
    sha256 = "1v9adcws9g9q8k65bdwnl0cvh6ay8sqfdwy8n1zxg8n0bzdhabax";
    goPackagePath = "golang.org/x/net";
    goPackageAliases = [
      "code.google.com/p/go.net"
      "github.com/hashicorp/go.net"
      "github.com/golang/net"
    ];
    propagatedBuildInputs = [ text crypto ];
  };

  net_crypto_lib = buildFromGitHub {
    inherit (net) rev date owner repo sha256 goPackagePath;
    subPackages = [
      "context"
    ];
  };

  oauth2 = buildFromGitHub {
    rev = "9ef2eddcc6774e42f998940fe1167216d36a7424";
    date = "2016-04-13";
    owner = "golang";
    repo = "oauth2";
    sha256 = "12xijfwjxrxswv869bxwcidcy2883k66d7gc7ngb975yjj2hbdcx";
    goPackagePath = "golang.org/x/oauth2";
    goPackageAliases = [ "github.com/golang/oauth2" ];
    propagatedBuildInputs = [ net gcloud-golang-compute-metadata ];
  };


  protobuf = buildFromGitHub {
    rev = "7cc19b78d562895b13596ddce7aafb59dd789318";
    date = "2016-04-26";
    owner = "golang";
    repo = "protobuf";
    sha256 = "0gn7ciqf2wfci2iqvmlxdwkkq5bv0mgp9vkzhbg3yhzi4jxg7lf6";
    goPackagePath = "github.com/golang/protobuf";
    goPackageAliases = [ "code.google.com/p/goprotobuf" ];
  };

  snappy = buildFromGitHub {
    rev = "43fea289edce21979658cbbdb3925390890aa86e";
    date = "2016-04-30";
    owner  = "golang";
    repo   = "snappy";
    sha256 = "0b0k00lwpky3arbhfjyzvx4wyshpr2sik2x0gzas1wkc5lg46kdp";
    goPackageAliases = [ "code.google.com/p/snappy-go/snappy" ];
  };

  sys = buildFromGitHub {
    rev = "b776ec39b3e54652e09028aaaaac9757f4f8211a";
    date = "2016-04-20";
    owner  = "golang";
    repo   = "sys";
    sha256 = "08c5k25h5frld4pdjpg0r224dn25bccnhlbxacj9f867c3vsp35h";
    goPackagePath = "golang.org/x/sys";
    goPackageAliases = [
      "github.com/golang/sys"
    ];
  };

  text = buildFromGitHub {
    rev = "bd1c9905f55d983c0cd0b15cf0c3e2fe860c8902";
    date = "2016-04-28";
    owner = "golang";
    repo = "text";
    sha256 = "15p33l1sf4rm40lkz5jsx368xxyqz17r740pvjc68idhn3xgx6h2";
    goPackagePath = "golang.org/x/text";
    goPackageAliases = [ "github.com/golang/text" ];
  };

  tools = buildFromGitHub {
    rev = "d4437bf59744b83da8bb401f87f0ae099fc66564";
    date = "2016-04-28";
    owner = "golang";
    repo = "tools";
    sha256 = "18314gs5xgnrn564bdb060jsv52n7xs648gil8qg3q3sv38g5mji";
    goPackagePath = "golang.org/x/tools";
    goPackageAliases = [ "code.google.com/p/go.tools" ];

    preConfigure = ''
      # Make the builtin tools available here
      mkdir -p $bin/bin
      eval $(go env | grep GOTOOLDIR)
      find $GOTOOLDIR -type f | while read x; do
        ln -sv "$x" "$bin/bin"
      done
      export GOTOOLDIR=$bin/bin
    '';

    excludedPackages = "\\("
      + stdenv.lib.concatStringsSep "\\|" ([ "testdata" ] ++ stdenv.lib.optionals (stdenv.lib.versionAtLeast go.meta.branch "1.5") [ "vet" "cover" ])
      + "\\)";

    buildInputs = [ appengine net ];

    # Do not copy this without a good reason for enabling
    # In this case tools is heavily coupled with go itself and embeds paths.
    allowGoReference = true;

    # Set GOTOOLDIR for derivations adding this to buildInputs
    postInstall = ''
      mkdir -p $bin/nix-support
      echo "export GOTOOLDIR=$bin/bin" >> $bin/nix-support/setup-hook
    '';
  };


  ## THIRD PARTY

  ace = buildFromGitHub {
    rev = "0.0.0";
    owner  = "yosssi";
    repo   = "ace";
    sha256 = "0xdzqfzaipyaa973j41yq9lbijw36kyaz523sw05kci4r5ivq4f5";
    buildInputs = [ gohtml ];
  };

  adapted = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-06-03";
    owner = "michaelmacinnis";
    repo = "adapted";
    sha256 = "0f28sn5mj48087zhjdrph2sjcznff1i1lwnwplx32bc5ax8nx5xm";
    propagatedBuildInputs = [ sys ];
  };

  afero = buildFromGitHub {
    rev = "0.0.0";
    owner  = "spf13";
    repo   = "afero";
    sha256 = "1xqvbwny61j85psymcs8hggmqyyg4yq3q4cssnvnvbsl3aq8kn4k";
    propagatedBuildInputs = [ text ];
  };

  amber = buildFromGitHub {
    rev = "0.0.0";
    owner  = "eknkc";
    repo   = "amber";
    sha256 = "079wwdq4cn9i1vx5zik16z4bmghkc7zmmvbrp1q6y4cnpmq95rqk";
  };

  ansicolor = buildFromGitHub {
    date = "2015-11-20";
    rev = "a422bbe96644373c5753384a59d678f7d261ff10";
    owner  = "shiena";
    repo   = "ansicolor";
    sha256 = "1qfq4ax68d7a3ixl60fb8kgyk0qx0mf7rrk562cnkpgzrhkdcm0w";
  };

  asciinema = buildFromGitHub {
    rev = "0.0.0";
    owner = "asciinema";
    repo = "asciinema";
    sha256 = "0k48k8815k433s25lh8my2swl89kczp0m2gbqzjlpy1xwmk06nxc";
  };

  asn1-ber = buildFromGitHub {
    rev = "0.0.0";
    owner  = "go-asn1-ber";
    repo   = "asn1-ber";
    sha256 = "0pzbixrg487wczcg3a86y5kgglq69yzkvb16vsm4mbmmbs8ixra4";
    goPackageAliases = [
      "github.com/nmcclain/asn1-ber"
      "github.com/vanackere/asn1-ber"
      "gopkg.in/asn1-ber.v1"
    ];
  };

  assertions = buildGoPackage rec {
    version = "1.5.0";
    name = "assertions-${version}";
    goPackagePath = "github.com/smartystreets/assertions";
    src = fetchurl {
      name = "${name}.tar.gz";
      url = "https://github.com/smartystreets/assertions/archive/${version}.tar.gz";
      sha256 = "1s4b0v49yv7jmy4izn7grfqykjrg7zg79dg5hsqr3x40d5n7mk02";
    };
    buildInputs = [ oglematchers ];
    propagatedBuildInputs = [ goconvey ];
    doCheck = false;
  };

  aws-sdk-go = buildFromGitHub {
    rev = "v1.1.22";
    owner  = "aws";
    repo   = "aws-sdk-go";
    sha256 = "03jcv27w3lv5y02ri9lnnn6gjzgspcbq4lxw5sdzghxzp3gwbbd4";
    buildInputs = [ testify gucumber tools ];
    propagatedBuildInputs = [ ini go-jmespath ];

    preBuild = ''
      pushd go/src/$goPackagePath
      make generate
      popd
    '';
  };

  b = buildFromGitHub {
    date = "2016-02-10";
    rev = "47184dd8c1d2c7e7f87dae8448ee2007cdf0c6c4";
    owner  = "cznic";
    repo   = "b";
    sha256 = "1sw8yyb906v3kv8km8wnyrgkvyjbv74iinrdvjh1qb87p2vr4b17";
  };

  bigfft = buildFromGitHub {
    date = "2013-09-13";
    rev = "a8e77ddfb93284b9d58881f597c820a2875af336";
    owner = "remyoudompheng";
    repo = "bigfft";
    sha256 = "1cj9zyv3shk8n687fb67clwgzlhv47y327180mvga7z741m48hap";
  };

  bleve = buildFromGitHub {
    rev = "0.0.0";
    date   = "2016-01-19";
    owner  = "blevesearch";
    repo   = "bleve";
    sha256 = "0ny7nvilrxmmzcdvpivwyrjkynnhc22c5gdrxzs421jly35jw8jx";
    buildFlags = [ "-tags all" ];
    propagatedBuildInputs = [ protobuf goleveldb kagome gtreap bolt text
     rcrowley_go-metrics bitset segment go-porterstemmer ];
  };

  binarydist = buildFromGitHub {
    rev = "0.0.0";
    owner  = "kr";
    repo   = "binarydist";
    sha256 = "11wncbbbrdcxl5ff3h6w8vqfg4bxsf8709mh6vda0cv236flkyn3";
  };

  bitset = buildFromGitHub {
    rev = "0.0.0";
    date   = "2016-01-13";
    owner  = "willf";
    repo   = "bitset";
    sha256 = "1d4z2hjjs9jk6aysi4mf50p8lbbzag4ir4y1f0z4sz8gkwagh7b7";
  };

  blackfriday = buildFromGitHub {
    rev = "0.0.0";
    owner  = "russross";
    repo   = "blackfriday";
    sha256 = "1l78hz8k1ixry5fjw29834jz1q5ysjcpf6kx2ggjj1s6xh0bfzvf";
    propagatedBuildInputs = [ sanitized_anchor_name ];
  };

  bolt = buildFromGitHub {
    rev = "v1.2.0";
    owner  = "boltdb";
    repo   = "bolt";
    sha256 = "14w1zf6d9mn6p2m9ypalrf55zfqm81v63r8g8gq3ll8nzc8flw48";
  };

  bufio = buildFromGitHub {
    rev = "0.0.0";
    owner  = "vmihailenco";
    repo   = "bufio";
    sha256 = "0x46qnf2f15v7m0j2dcb16raxjamk5rdc7hqwgyxfr1sqmmw3983";
  };

  bufs = buildFromGitHub {
    date = "2014-08-18";
    rev = "3dcccbd7064a1689f9c093a988ea11ac00e21f51";
    owner  = "cznic";
    repo   = "bufs";
    sha256 = "0551h2slsb7lg3r6yif65xvf6k8f0izqwyiigpipm3jhlln37c6p";
  };

  candiedyaml = buildFromGitHub {
    date = "2016-03-22";
    rev = "0.0.0";
    owner  = "cloudfoundry-incubator";
    repo   = "candiedyaml";
    sha256 = "10pdcm54fnxjr48qdfnjmp14xyhpa7xzrbp1af2fgqrayi9himk8";
  };

  cascadia = buildGoPackage rec {
    rev = "0.0.1"; #master
    name = "cascadia-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/andybalholm/cascadia";
    goPackageAliases = [ "code.google.com/p/cascadia" ];
    propagatedBuildInputs = [ net ];
    buildInputs = propagatedBuildInputs;
    doCheck = true;

    src = fetchFromGitHub {
      inherit rev;
      owner = "andybalholm";
      repo = "cascadia";
      sha256 = "1z21w6p5bp7mi2pvicvcqc871k9s8a6262pkwyjm2qfc859c203m";
    };
  };

  cast = buildFromGitHub {
    rev = "0.0.0";
    owner  = "spf13";
    repo   = "cast";
    sha256 = "144xwvmjbrv59zjj1gnq5j9qpy62dgyfamxg5l3smdwfwa8vpf5i";
    buildInputs = [ jwalterweatherman ];
  };

  check-v1 = buildFromGitHub {
    rev = "4f90aeace3a26ad7021961c297b22c42160c7b25";
    owner = "go-check";
    repo = "check";
    goPackagePath = "gopkg.in/check.v1";
    sha256 = "1vmf8shg0kqakmh60k5m985vxj9h2lb18lw69qx9scl5i66n746h";
    date = "2016-01-05";
  };

  circbuf = buildFromGitHub {
    date = "2015-08-26";
    rev = "bbbad097214e2918d8543d5201d12bfd7bca254d";
    owner  = "armon";
    repo   = "circbuf";
    sha256 = "0wgpmzh0ga2kh51r214jjhaqhpqr9l2k6p0xhy5a006qypk5fh2m";
  };

  mitchellh-cli = buildFromGitHub {
    date = "2016-03-23";
    rev = "168daae10d6ff81b8b1201b0a4c9607d7e9b82e3";
    owner = "mitchellh";
    repo = "cli";
    sha256 = "1ihlx94djy3npy88kv1ahsgk4vh4jchsgmyj2pkrawf8chf1i4v3";
    propagatedBuildInputs = [ crypto go-radix speakeasy go-isatty ];
  };

  codegangsta-cli = buildFromGitHub {
    rev = "v1.15.0";
    owner = "codegangsta";
    repo = "cli";
    sha256 = "0y2bxyl9hvg8agwvd6c2825wwzbkdjgqa4bhl8a5aigzlnz455xy";
    buildInputs = [ yaml-v2 ];
  };

  cli-spinner = buildFromGitHub {
    rev = "0.0.0";
    owner  = "odeke-em";
    repo   = "cli-spinner";
    sha256 = "13wzs2qrxd72ah32ym0ppswhvyimjw5cqaq3q153y68vlvxd048c";
  };

  cobra = buildFromGitHub {
    rev = "0.0.0";
    owner  = "spf13";
    repo   = "cobra";
    sha256 = "0skmq1lmkh2xzl731a2sfcnl2xbcy9v1050pcf10dahwqzsbx6ij";
    propagatedBuildInputs = [ pflag-spf13 mousetrap go-md2man viper ];
  };

  cli-go = buildFromGitHub {
    rev = "v1.15.0";
    owner  = "codegangsta";
    repo   = "cli";
    sha256 = "0y2bxyl9hvg8agwvd6c2825wwzbkdjgqa4bhl8a5aigzlnz455xy";
  };

  columnize = buildFromGitHub {
    rev = "v2.1.0";
    owner  = "ryanuber";
    repo   = "columnize";
    sha256 = "0r9r4p4x1vnrq31dj5bvw3phhmqpsb5vwh72cs2wwxmhalzq92hx";
  };

  command = buildFromGitHub {
    rev = "0.0.0";
    owner  = "odeke-em";
    repo   = "command";
    sha256 = "1ghckzr8h99ckagpmb15p61xazdjmf9mjmlym634hsr9vcj84v62";
  };

  copystructure = buildFromGitHub {
    date = "2016-01-28";
    rev = "80adcec1955ee4e97af357c30dee61aadcc02c10";
    owner = "mitchellh";
    repo = "copystructure";
    sha256 = "0ripl8zx55a9phrzw00fnk8ni3jj2bkahn3ffa767a1pz1fysz5j";
    propagatedBuildInputs = [ reflectwalk ];
  };

  confd = buildGoPackage rec {
    rev = "0.0.0";
    name = "confd-${rev}";
    goPackagePath = "github.com/kelseyhightower/confd";
    preBuild = "export GOPATH=$GOPATH:$NIX_BUILD_TOP/go/src/${goPackagePath}/Godeps/_workspace";
    src = fetchFromGitHub {
      inherit rev;
      owner = "kelseyhightower";
      repo = "confd";
      sha256 = "0rz533575hdcln8ciqaz79wbnga3czj243g7fz8869db6sa7jwlr";
    };
    subPackages = [ "./" ];
  };

  consul = buildFromGitHub {
    rev = "v0.6.4";
    owner = "hashicorp";
    repo = "consul";
    sha256 = "0x1rc0smfd4p5bqcqrjp0hkaj3cl60fsk518vipn5hyr70ywl187";

    buildInputs = [
      datadog-go circbuf armon_go-metrics go-radix speakeasy bolt
      go-bindata-assetfs go-dockerclient errwrap go-checkpoint go-cleanhttp
      go-immutable-radix go-memdb ugorji_go go-multierror go-reap go-syslog
      golang-lru hcl logutils memberlist net-rpc-msgpackrpc raft raft-boltdb
      scada-client serf yamux muxado dns mitchellh-cli mapstructure columnize
      copystructure hil hashicorp-go-uuid crypto sys
    ];

    # Keep consul.ui for backward compatability
    passthru.ui = pkgs.consul-ui;
  };

  consul-api = buildFromGitHub {
    inherit (consul) rev owner repo sha256;
    buildInputs = [ go-cleanhttp serf ];
    subPackages = [ "api" "tlsutil" ];
  };

  consul-alerts = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-08-09";
    owner = "AcalephStorage";
    repo = "consul-alerts";
    sha256 = "191bmxix3nl4pr26hcdfxa9qpv5dzggjvi86h2slajgyd2rzn23b";

    renameImports = ''
      # Remove all references to included dependency store
      rm -rf go/src/github.com/AcalephStorage/consul-alerts/Godeps
      govers -d -m github.com/AcalephStorage/consul-alerts/Godeps/_workspace/src/ ""
    '';

    # Temporary fix for name change
    postPatch = ''
      sed -i 's,SetApiKey,SetAPIKey,' notifier/opsgenie-notifier.go
    '';

    buildInputs = [ logrus docopt-go hipchat-go gopherduty consul-api opsgenie-go-sdk influxdb8-client ];
  };

  consul-template = buildFromGitHub {
    rev = "0.0.0";
    owner = "hashicorp";
    repo = "consul-template";
    sha256 = "96be40e0ff990df7850e3ec746c393d831783065deb5a8182607ae90ecf426ab";

    buildInputs = [
      consul-api
      go-cleanhttp
      go-multierror
      go-reap
      go-syslog
      logutils
      mapstructure
      serf
      yaml-v2
      vault-api
    ];
  };

  context = buildGoPackage rec {
    rev = "v1.1";
    name = "config-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/gorilla/context";

    src = fetchFromGitHub {
      inherit rev;
      owner = "gorilla";
      repo = "context";
    sha256 = "0fsm31ayvgpcddx3bd8fwwz7npyd7z8d5ja0w38lv02yb634daj6";
    };
  };

  cookoo = buildFromGitHub {
    rev = "0.0.0";
    owner  = "Masterminds";
    repo   = "cookoo";
    sha256 = "1mxqnxddny43k1shsvd39sfzfs0d20gv3vm9lcjp04g3b0rplck1";
  };

  cronexpr = buildFromGitHub {
    rev = "0.0.0";
    owner  = "gorhill";
    repo   = "cronexpr";
    sha256 = "0xhb611v03c1l5g0glzcapx6p54vxxfgfhx3gy895bl9yj4hwwpx";
    date = "2016-03-18";
  };

  crypt = buildFromGitHub {
    rev = "0.0.0";
    owner  = "xordataexchange";
    repo   = "crypt";
    sha256 = "17g9122b8bmbdpshyzhl7cxsp0nvhk0rc6syc92djavggmbpl6ig";
    preBuild = ''
      substituteInPlace go/src/github.com/xordataexchange/crypt/backend/consul/consul.go \
        --replace 'github.com/armon/consul-api' 'github.com/hashicorp/consul/api' \
        --replace 'consulapi' 'api'
    '';
    propagatedBuildInputs = [ go-etcd consul-api crypto ];
  };

  cssmin = buildFromGitHub {
    rev = "0.0.0";
    owner  = "dchest";
    repo   = "cssmin";
    sha256 = "09sdijfx5d05z4cd5k6lhl7k3kbpdf2amzlngv15h5v0fff9qw4s";
  };

  datadog-go = buildFromGitHub {
    date = "2016-03-29";
    rev = "cc2f4770f4d61871e19bfee967bc767fe730b0d9";
    owner = "DataDog";
    repo = "datadog-go";
    sha256 = "10c1jkghl7a7a4z80lsjg11gx3vf6nn7y5x078b98mxisf0x0cdv";
  };

  dbus = buildFromGitHub {
    rev = "v4.0.0";
    owner = "godbus";
    repo = "dbus";
    sha256 = "0q2qabf656sq0pd3candndd8nnkwwp4by4hlkxjn4fs85ld44i8s";
  };

  deis = buildFromGitHub {
    rev = "0.0.0";
    owner = "deis";
    repo = "deis";
    sha256 = "03lznzcij3gn08kqj2p6skifcdv5aw09dm6zxgvqw7nxx2n1j2ib";
    subPackages = [ "client" ];
    buildInputs = [ docopt-go crypto yaml-v2 ];
    postInstall = ''
      if [ -f "$bin/bin/client" ]; then
        mv "$bin/bin/client" "$bin/bin/deis"
      fi
    '';
  };

  discosrv = buildFromGitHub {
    rev = "1a2ac62dd59a350a2efd5dd742454a3dcf98dbc7";
    owner = "syncthing";
    repo = "discosrv";
    sha256 = "074c6lk7fp2zfly5nzzckjlm3l055n7q7p7rs571bxq9ifwy3fgi";
    buildInputs = [ ql groupcache pq ratelimit syncthing-lib ];
    date = "2016-04-30";
  };

  dns = buildFromGitHub {
    rev = "c9d1302d540edfb97d9ecbfe90b4fb515088630b";
    date = "2016-04-19";
    owner  = "miekg";
    repo   = "dns";
    sha256 = "098kallsmqzbjm5ylwfxkkqmd0773dmjf5m9rkaplslijypamfb1";
  };

  aetrion-dnsimple-go = buildFromGitHub {
    rev = "0.0.0";
    date = "2016-04-02";
    owner  = "aetrion";
    repo   = "dnsimple-go";
    sha256 = "1sr76vm16g81bvd48abk400z2jf67ic359pn2ga3xa3yhz4vqg5b";
    goPackageAliases = [
      "github.com/weppos/dnsimple-go"
    ];
  };

  weppos-dnsimple-go = buildFromGitHub {
    rev = "65c1ca73cb19baf0f8b2b33219b7f57595a3ccb0";
    date = "2016-02-04";
    owner  = "weppos";
    repo   = "dnsimple-go";
    sha256 = "0v3vnp128ybzmh4fpdwhl6xmvd815f66dgdjzxarjjw8ywzdghk9";
  };

  docker = buildFromGitHub {
    rev = "v1.11.1";
    owner = "docker";
    repo = "docker";
    sha256 = "0brmkks18dkvch6x9hlpvn73p0p7vvaqkawi337jqz25qcvsshrw";
  };

  docker_for_runc = buildFromGitHub {
    inherit (docker) rev owner repo sha256;
    subPackages = [
      "pkg/mount"
      "pkg/symlink"
      "pkg/system"
      "pkg/term"
    ];
    propagatedBuildInputs = [
      go-units
    ];
  };

  docker_for_go-dockerclient = buildFromGitHub {
    inherit (docker) rev owner repo sha256;
    subPackages = [
      "opts"
      "pkg/archive"
      "pkg/fileutils"
      "pkg/homedir"
      "pkg/idtools"
      "pkg/ioutils"
      "pkg/pools"
      "pkg/promise"
      "pkg/stdcopy"
    ];
    propagatedBuildInputs = [
      go-units
      logrus
      net
      runc
    ];
  };

  docopt-go = buildFromGitHub {
    rev = "0.0.0";
    owner  = "docopt";
    repo   = "docopt-go";
    sha256 = "1sddkxgl1pwlipfvmv14h8vg9b9wq1km427j1gjarhb5yfqhh3l1";
  };

  duo_api_golang = buildFromGitHub {
    date = "2016-03-22";
    rev = "0.0.0";
    owner = "duosecurity";
    repo = "duo_api_golang";
    sha256 = "0mls2kxgncrg649j33vmr5srh6cc7mak00h9ijhq4dhywh8s4vsr";
  };

  cache = buildFromGitHub {
    rev = "0.0.0";
    owner = "odeke-em";
    repo = "cache";
    sha256 = "1rmm1ky7irqypqjkk6qcd2n0xkzpaggdxql9dp9i9qci5rvvwwd4";
  };

  exercism = buildFromGitHub {
    rev = "0.0.0";
    name = "exercism";
    owner = "exercism";
    repo = "cli";
    sha256 = "13kwcxd7m3xv42j50nlm9dd08865dxji41glfvnb4wwq9yicyn4g";
    buildInputs = [ net cli-go osext ];
  };

  exponential-backoff = buildFromGitHub {
    rev = "0.0.0";
    owner = "odeke-em";
    repo = "exponential-backoff";
    sha256 = "1as21p2jj8xpahvdxqwsw2i1s3fll14dlc9j192iq7xl1ybwpqs6";
  };

  extractor = buildFromGitHub {
    rev = "0.0.0";
    owner = "odeke-em";
    repo = "extractor";
    sha256 = "036zmnqxy48h6mxiwywgxix2p4fqvl4svlmcp734ri2rbq3cmxs1";
  };

  open-golang = buildFromGitHub {
    rev = "0.0.0";
    owner = "skratchdot";
    repo = "open-golang";
    sha256 = "0qhn2d00v3m9fiqk9z7swdm599clc6j7rnli983s8s1byyp0x3ac";
  };

  pretty-words = buildFromGitHub {
    rev = "0.0.0";
    owner = "odeke-em";
    repo = "pretty-words";
    sha256 = "1466wjhrg9lhqmzil1vf8qj16fxk32b5kxlcccyw2x6dybqa6pkl";
  };

  meddler = buildFromGitHub {
    rev = "0.0.0";
    owner = "odeke-em";
    repo = "meddler";
    sha256 = "0m0fqrn3kxy4swyk4ja1y42dn1i35rq9j85y11wb222qppy2342x";
  };

  dts = buildFromGitHub {
    rev = "0.0.0";
    owner  = "odeke-em";
    repo   = "dts";
    sha256 = "0vq3cz4ab9vdsz9s0jjlp7z27w218jjabjzsh607ps4i8m5d441s";
  };

  du = buildFromGitHub {
    rev = "v1.0.0";
    owner  = "calmh";
    repo   = "du";
    sha256 = "02gri7xy9wp8szxpabcnjr18qic6078k213dr5k5712s1pg87qmj";
  };

  ed25519 = buildGoPackage rec {
    rev = "0.0.0";
    name = "ed25519-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/agl/ed25519";
    src = fetchgit {
      inherit rev;
      url = "git://${goPackagePath}.git";
      sha256 = "83e3010509805d1d315c7aa85a356fda69d91b51ff99ed98a503d63adb3613e9";
    };
  };

  errwrap = buildFromGitHub {
    date = "2014-10-27";
    rev = "7554cd9344cec97297fa6649b055a8c98c2a1e55";
    owner  = "hashicorp";
    repo   = "errwrap";
    sha256 = "02hsk2zbwg68w62i6shxc0lhjxz20p3svlmiyi5zjz988qm3s530";
  };

  etcd = buildFromGitHub {
    rev = "0.0.0";
    owner  = "coreos";
    repo   = "etcd";
    sha256 = "0z4rlg5m5w131rgi6qlnsdl4lpfnvy7abxyi98arp06z86ddyhzg";
  };

  etcd-client = buildFromGitHub {
    inherit (etcd) rev owner repo sha256;
    subPackages = [
      "client"
      "pkg/pathutil"
      "pkg/transport"
      "pkg/types"
      "Godeps/_workspace/src/golang.org/x/net"
      "Godeps/_workspace/src/github.com/ugorji/go/codec"
    ];
  };

  exp = buildFromGitHub {
    date = "2015-12-07";
    rev = "c21cce1fce3e6e5bc84854aa3d02a808de44229b";
    owner  = "cznic";
    repo   = "exp";
    sha256 = "00dx5nnjxwpd8dmig210hsgag0brk8391kar97kp3dlikn6dbqb5";
    propagatedBuildInputs = [ bufs fileutil mathutil sortutil zappy ];
  };

  fileutil = buildFromGitHub {
    date = "2015-07-08";
    rev = "1c9c88fbf552b3737c7b97e1f243860359687976";
    owner  = "cznic";
    repo   = "fileutil";
    sha256 = "0naps0miq8lk4k7k6c0l9583nv6wcdbs9zllvsjjv60h4fsz856a";
    buildInputs = [ mathutil ];
  };

  fs = buildFromGitHub {
    date = "2013-11-07";
    rev = "0.0.0";
    owner  = "kr";
    repo   = "fs";
    sha256 = "0i1apcy79f6mxvdb1qzqg47c8l4x9a31yp7zgs2mij706x2cqv8v";
  };

  fsnotify.v0 = buildGoPackage rec {
    rev = "0.0.0";
    name = "fsnotify.v0-${rev}";
    goPackagePath = "gopkg.in/fsnotify.v0";
    goPackageAliases = [ "github.com/howeyc/fsnotify" ];

    src = fetchFromGitHub {
      inherit rev;
      owner = "go-fsnotify";
      repo = "fsnotify";
      sha256 = "15wqjpkfzsxnaxbz6y4r91hw6812g3sc4ipagxw1bya9klbnkdc9";
    };
  };

  flannel = buildFromGitHub {
    rev = "0.0.0";
    owner = "coreos";
    repo = "flannel";
    sha256 = "0d9khv0bczvsaqnz16p546m4r5marmnkcrdhi0f3ajnwxb776r9p";
  };

  fsnotify.v1 = buildGoPackage rec {
    rev = "0.0.0";
    name = "fsnotify.v1-${rev}";
    goPackagePath = "gopkg.in/fsnotify.v1";

    src = fetchFromGitHub {
      inherit rev;
      owner = "go-fsnotify";
      repo = "fsnotify";
      sha256 = "1308z1by82fbymcra26wjzw7lpjy91kbpp2skmwqcq4q1iwwzvk2";
    };
  };

  fsync = buildFromGitHub {
    rev = "0.0.0";
    owner  = "spf13";
    repo   = "fsync";
    sha256 = "0hzfk2f8pm756j10zgsk8b8gbfylcf8h6q4djz0ka9zpg76s26lz";
    buildInputs = [ afero ];
  };

  fzf = buildFromGitHub {
    rev = "0.0.0";
    owner = "junegunn";
    repo = "fzf";
    sha256 = "1zw1kq4d5sb1qia44q04i33yii9qwlwlwz8vxhln03d4631mhsra";

    buildInputs = [
      crypto ginkgo gomega junegunn.go-runewidth go-shellwords pkgs.ncurses text
    ];

    postInstall= ''
      cp $src/bin/fzf-tmux $bin/bin
    '';
  };

  g2s = buildFromGitHub {
    rev = "0.0.0";
    owner  = "peterbourgon";
    repo   = "g2s";
    sha256 = "1p4p8755v2nrn54rik7yifpg9szyg44y5rpp0kryx4ycl72307rj";
  };

  gawp = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-08-31";
    owner  = "martingallagher";
    repo   = "gawp";
    sha256 = "0iqqd63nqdijdskdb9f0jwnm6akkh1p2jw4p2w7r1dbaqz1znyay";
    dontInstallSrc = true;
    buildInputs = [ fsnotify.v1 yaml-v2 ];

    meta = with stdenv.lib; {
      homepage    = "https://github.com/martingallagher/gawp";
      description = "A simple, configurable, file watching, job execution tool implemented in Go.";
      maintainers = with maintainers; [ kamilchm ];
      license     = licenses.asl20 ;
      platforms   = platforms.all;
    };
  };

  gcloud-golang = buildFromGoogle {
    rev = "200292f09e3aaa34878d801ab71fe823b1f7d36a";
    repo = "cloud";
    sha256 = "07x7siyx553n21l5xh16f119rjqj5gf398jc3w73cqmyrfpbj4vx";
    propagatedBuildInputs = [ net oauth2 protobuf google-api-go-client grpc ];
    excludedPackages = "oauth2";
    meta.hydraPlatforms = [ ];
    date = "2016-04-28";
  };

  gcloud-golang-compute-metadata = buildFromGoogle {
    inherit (gcloud-golang) rev repo sha256 date;
    subPackages = [ "compute/metadata" "internal" ];
    buildInputs = [ net ];
  };

  gettext-go = buildFromGitHub {
    rev = "0.0.0";
    owner  = "chai2010";
    repo   = "gettext-go";
    sha256 = "1iz4wjxc3zkj0xkfs88ig670gb08p1sd922l0ig2cxpjcfjp1y99";
  };

  ginkgo = buildFromGitHub {
    rev = "2c2e9bb47b4e44067024f29339588cac8b34dd12";
    owner = "onsi";
    repo = "ginkgo";
    sha256 = "184ci0cw46nngj02ilzb63dy098m5y4m3ywcbhfhbgp1kbgnl5r8";
    date = "2016-04-09";
  };

  git-annex-remote-b2 = buildFromGitHub {
    buildInputs = [ go go-backblaze ];
    owner = "encryptio";
    repo = "git-annex-remote-b2";
    rev = "0.0.0";
    sha256 = "1139rzdvlj3hanqsccfinprvrzf4qjc5n4f0r21jp9j24yhjs6j2";
  };

  git-appraise = buildFromGitHub {
    rev = "0.0.0";
    owner = "google";
    repo = "git-appraise";
    sha256 = "124hci9whsvlcywsfz5y20kkj3nhy176a1d5s1lkvsga09yxq6wm";
  };

  git-lfs = buildFromGitHub {
    rev = "0.0.0";
    owner = "github";
    repo = "git-lfs";
    sha256 = "1zlg3rm5yxak6d88brffv1wpj0iq4qgzn6sgg8xn0pbnzxjd1284";

    # Tests fail with 'lfstest-gitserver.go:46: main redeclared in this block'
    excludedPackages = [ "test" ];

    preBuild = ''
      pushd go/src/github.com/github/git-lfs
        go generate ./commands
      popd
    '';

    postInstall = ''
      rm -v $bin/bin/{man,script}
    '';
  };

  glide = buildFromGitHub {
    rev = "0.0.0";
    owner  = "Masterminds";
    repo   = "glide";
    sha256 = "1v66c2igm8lmljqrrsyq3cl416162yc5l597582bqsnhshj2kk4m";
    buildInputs = [ cookoo cli-go go-gypsy vcs ];
  };

  gls = buildFromGitHub {
    rev = "0.0.0";
    owner  = "jtolds";
    repo   = "gls";
    sha256 = "1gvgkx7llklz6plapb95fcql7d34i6j7anlvksqhdirpja465jnm";
  };

  ugorji_go = buildFromGitHub {
    date = "2016-03-28";
    rev = "a396ed22fc049df733440d90efe17475e3929ccb";
    owner = "ugorji";
    repo = "go";
    sha256 = "0i6v9ql86j0fgscwkbpfgi9m97y7vxaqyivlckw9ngdqnm4wcgpq";
    goPackageAliases = [ "github.com/hashicorp/go-msgpack" ];
  };

  go4 = buildFromGitHub {
    date = "2016-03-13";
    rev = "03efcb870d84809319ea509714dd6d19a1498483";
    owner = "camlistore";
    repo = "go4";
    sha256 = "0zkmafigzr2whpdwal6zwkb9xzxv87qym92xs7nmriwrggqa3l6x";
    goPackagePath = "go4.org";
    goPackageAliases = [ "github.com/camlistore/go4" ];
    buildInputs = [ gcloud-golang net ];
    autoUpdatePath = "github.com/camlistore/go4";
  };

  goamz = buildFromGitHub {
    rev = "02d5144a587b982e33b95f484a34164ce6923c99";
    owner  = "goamz";
    repo   = "goamz";
    sha256 = "0nrw83ys5c9aiqxrangig7c0dk9xl41cqs9gskka9sk849fpl9f2";
    date = "2016-04-07";
    goPackageAliases = [
      "github.com/mitchellh/goamz"
    ];
    buildInputs = [
      check-v1
      go-ini
      go-simplejson
      sets
    ];
  };

  goautoneg = buildGoPackage rec {
    name = "goautoneg-2012-07-07";
    goPackagePath = "bitbucket.org/ww/goautoneg";
    rev = "75cd24fc2f2c2a2088577d12123ddee5f54e0675";

    src = fetchFromBitbucket {
      inherit rev;
      owner  = "ww";
      repo   = "goautoneg";
      sha256 = "9acef1c250637060a0b0ac3db033c1f679b894ef82395c15f779ec751ec7700a";
    };

    meta.autoUpdate = false;
  };

  dgnorton.goback = buildFromGitHub {
    rev = "0.0.0";
    owner  = "dgnorton";
    repo   = "goback";
    sha256 = "1nyg6sckwd0iafs9vcmgbga2k3hid2q0avhwj29qbdhj3l78xi47";
  };

  gocapability = buildFromGitHub {
    rev = "2c00daeb6c3b45114c80ac44119e7b8801fdd852";
    owner = "syndtr";
    repo = "gocapability";
    sha256 = "0kwcqvj2fq6wl453hcc3q4fmyrv3yk9m3igxwksx9rmpnzaclz8r";
    date = "2015-07-16";
  };

  gocryptfs = buildFromGitHub {
    rev = "0.0.0";
    owner = "rfjakob";
    repo = "gocryptfs";
    sha256 = "0jsdz8y7a1fkyrfwg6353c9r959qbqnmf2cjh57hp26w1za5bymd";
    buildInputs = [ crypto go-fuse openssl-spacemonkey ];
  };

  gocheck = buildGoPackage rec {
    rev = "0.0.0";
    name = "gocheck-${rev}";
    goPackagePath = "launchpad.net/gocheck";
    src = fetchbzr {
      inherit rev;
      url = "https://${goPackagePath}";
      sha256 = "1y9fa2mv61if51gpik9isls48idsdz87zkm1p3my7swjdix7fcl0";
    };
  };

  gocql = buildFromGitHub {
    rev = "0.0.0";
    owner  = "gocql";
    repo   = "gocql";
    sha256 = "17dgvbzb36yzp45hg8xmh7hm86shnzrzbznx932zvs6mxxpvpp0r";
    propagatedBuildInputs = [ inf snappy hailocab_go-hostpool net ];
    date = "2016-04-19";
  };

  gocode = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-09-03";
    owner = "nsf";
    repo = "gocode";
    sha256 = "1ay2xakz4bcn8r3ylicbj753gjljvv4cj9l4wfly55cj1vjybjpv";
  };

  gocolorize = buildGoPackage rec {
    rev = "0.0.0";
    name = "gocolorize-${rev}";
    goPackagePath = "github.com/agtorre/gocolorize";

    src = fetchFromGitHub {
      inherit rev;
      owner = "agtorre";
      repo = "gocolorize";
      sha256 = "1dj7s8bgw9qky344d0k9gz661c0m317a08a590184drw7m51hy9p";
    };
  };

  goconvey = buildGoPackage rec {
    version = "1.5.0";
    name = "goconvey-${version}";
    goPackagePath = "github.com/smartystreets/goconvey";
    src = fetchurl {
      name = "${name}.tar.gz";
      url = "https://github.com/smartystreets/goconvey/archive/${version}.tar.gz";
      sha256 = "0g3965cb8kg4kf9b0klx4pj9ycd7qwbw1jqjspy6i5d4ccd6mby4";
    };
    buildInputs = [ oglematchers ];
    doCheck = false; # please check again
  };

  gohtml = buildFromGitHub {
    rev = "0.0.0";
    owner  = "yosssi";
    repo   = "gohtml";
    sha256 = "1cghwgnx0zjdrqxzxw71riwiggd2rjs2i9p2ljhh76q3q3fd4s9f";
    propagatedBuildInputs = [ net ];
  };

  gojsonpointer = buildFromGitHub {
    rev = "e0fe6f68307607d540ed8eac07a342c33fa1b54a";
    owner  = "xeipuuv";
    repo   = "gojsonpointer";
    sha256 = "1gm1m5vf1nkg87qhskpqfyg9r8n0fy74nxvp6ajcqb04v3k8sd7v";
    date = "2015-10-27";
  };

  gojsonreference = buildFromGitHub {
    rev = "e02fc20de94c78484cd5ffb007f8af96be030a45";
    owner  = "xeipuuv";
    repo   = "gojsonreference";
    sha256 = "1c2yhjjxjvwcniqag9i5p159xsw4452vmnc2nqxnfsh1whd8wpi5";
    date = "2015-08-08";
    propagatedBuildInputs = [ gojsonpointer ];
  };

  gojsonschema = buildFromGitHub {
    rev = "d3178baac32433047aa76f07317f84fbe2be6cda";
    owner  = "xeipuuv";
    repo   = "gojsonschema";
    sha256 = "0iacjvsfizg2islh6dlhxdd1d2y3ppffgb7avvy3wd6dpaccfpv2";
    date = "2016-05-01";
    propagatedBuildInputs = [ gojsonreference ];
  };

  gotty = buildFromGitHub {
    rev = "0.0.0";
    owner   = "yudai";
    repo    = "gotty";
    sha256  = "0gvnbr61d5si06ik2j075jg00r9b94ryfgg06nqxkf10dp8lgi09";

    buildInputs = [ cli-go go manners go-bindata-assetfs go-multierror structs websocket hcl pty ];

    meta = with stdenv.lib; {
      description = "Share your terminal as a web application";
      homepage = "https://github.com/yudai/gotty";
      maintainers = with maintainers; [ matthiasbeyer ];
      license = licenses.mit;
    };
  };

  govers = buildFromGitHub {
    rev = "3b5f175f65d601d06f48d78fcbdb0add633565b9";
    date = "2015-01-09";
    owner = "rogpeppe";
    repo = "govers";
    sha256 = "1ir47942q9z6h5cajn84hvibhxicq93yrrgd36bagkibi4b2s5qf";
    dontRenameImports = true;
  };

  golang-lru = buildFromGitHub {
    date = "2016-02-07";
    rev = "a0d98a5f288019575c6d1f4bb1573fef2d1fcdc4";
    owner  = "hashicorp";
    repo   = "golang-lru";
    sha256 = "1q4cvlrk1pzki8lkf8b5mc3ciini8b6dlljrijycdh7izfc17vsz";
  };

  golang-petname = buildFromGitHub {
    rev = "0.0.0";
    owner  = "dustinkirkland";
    repo   = "golang-petname";
    sha256 = "1xx6lpv1r2sji8m9w35a2fkr9v4vsgvxrrahcq9bdg75qvadq91d";
  };

  golang_protobuf_extensions = buildFromGitHub {
    rev = "v1.0.0";
    owner  = "matttproud";
    repo   = "golang_protobuf_extensions";
    sha256 = "0r1sv4jw60rsxy5wlnr524daixzmj4n1m1nysv4vxmwiw9mbr6fm";
    buildInputs = [ protobuf ];
  };

  goleveldb = buildFromGitHub {
    rev = "cfa635847112c5dc4782e128fa7e0d05fdbfb394";
    date = "2016-04-25";
    owner = "syndtr";
    repo = "goleveldb";
    sha256 = "1g3z08af36r0vw79784r3a07psgl12qsa4vpl4ljcf7nsnxkb7ry";
    propagatedBuildInputs = [ ginkgo gomega snappy ];
  };

  gollectd = buildFromGitHub {
    rev = "0.0.0";
    owner  = "kimor79";
    repo   = "gollectd";
    sha256 = "1f3ml406cprzjc192csyr2af4wcadkc74kg8n4c0zdzglxxfsqxa";
  };

  gomega = buildFromGitHub {
    rev = "7ce781ea776b2fd506491011353bded2e40c8467";
    owner  = "onsi";
    repo   = "gomega";
    sha256 = "00728gg7inc980xvxdy158s2xklrgfldgzkl960jjsv1w10l2vbn";
    buildInputs = [ protobuf ];
    date = "2016-03-05";
  };

  google-api-go-client = buildFromGitHub {
    rev = "ff0a1ff302946b997eb1832381419d1f95143483";
    date = "2016-04-28";
    owner = "google";
    repo = "google-api-go-client";
    sha256 = "1v91815lw1y5pm5wvlq01s52ziddklk9p90iwqp4mdn1g80v8nys";
    goPackagePath = "google.golang.org/api";
    goPackageAliases = [ "github.com/google/google-api-client" ];
    buildInputs = [ net ];
  };

  odeke-em.google-api-go-client = buildGoPackage rec {
    rev = "0.0.0";
    name = "odeke-em-google-api-go-client-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/odeke-em/google-api-go-client";
    src = fetchFromGitHub {
      inherit rev;
      owner = "odeke-em";
      repo = "google-api-go-client";
      sha256 = "1fidlljxnd82i2r9yia0b9gh0vv3hwb5k65papnvw7sqpc4sriby";
    };
    buildInputs = [ net ];
    propagatedBuildInputs = [ google-api-go-client ];
  };

  gopass = buildFromGitHub {
    date = "2016-03-03";
    rev = "66487b23f2880ba32e185121d2cd51a338ea069a";
    owner = "howeyc";
    repo = "gopass";
    sha256 = "0r4kx80hq48fkipz4x7hkiqb74hygpja1h5xbzydaw4cdgc5vwjs";
    propagatedBuildInputs = [ crypto ];
  };

  gopherduty = buildFromGitHub {
    rev = "0.0.0";
    owner  = "darkcrux";
    repo   = "gopherduty";
    sha256 = "11w1yqc16fxj5q1y5ha5m99j18fg4p9lyqi542x2xbrmjqqialcf";
  };

  goproxy = buildFromGitHub {
    rev = "0.0.0";
    date   = "2015-07-26";
    owner  = "elazarl";
    repo   = "goproxy";
    sha256 = "1zz425y8byjaa9i7mslc9anz9w2jc093fjl0562rmm5hh4rc5x5f";
    buildInputs = [ go-charset ];
  };

  gopsutil = buildFromGitHub {
    rev = "0.0.0";
    owner  = "shirou";
    repo   = "gopsutil";
    sha256 = "0yys9agzbvlr8qck5x9v7am21kqqxs7jjz5lz2r0psf5v0g17f79";
  };

  goreq = buildFromGitHub {
    rev = "0.0.0";
    date   = "2015-08-18";
    owner  = "franela";
    repo   = "goreq";
    sha256 = "0dnqbijdzp2dgsf6m934nadixqbv73q0zkqglaa956zzw0pyhcxp";
  };

  gotags = buildFromGitHub {
    rev = "0.0.0";
    date   = "2015-08-03";
    owner  = "jstemmer";
    repo   = "gotags";
    sha256 = "071wyq90b06xlb3bb0l4qjz1gf4nnci4bcngiddfcxf2l41w1vja";
  };

  gosnappy = buildFromGitHub {
    rev = "0.0.0";
    owner  = "syndtr";
    repo   = "gosnappy";
    sha256 = "0ywa52kcii8g2a9lbqcx8ghdf6y56lqq96sl5nl9p6h74rdvmjr7";
  };

  gox = buildGoPackage rec {
    rev = "0.0.0";
    name = "gox-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/mitchellh/gox";
    src = fetchFromGitHub {
      inherit rev;
      owner  = "mitchellh";
      repo   = "gox";
      sha256 = "14jb2vgfr6dv7zlw8i3ilmp125m5l28ljv41a66c9b8gijhm48k1";
    };
    buildInputs = [ iochan ];
  };

  govalidator = buildFromGitHub {
    rev = "0.0.0";
    owner = "asaskevich";
    repo = "govalidator";
    sha256 = "1gvar3irb6bksskwdwi2rcspz7bjd5z6ymdq8266dbif0l5z4wjd";
    date = "2016-04-23";
  };

  gozim = buildFromGitHub {
    rev = "0.0.0";
    date   = "2016-01-15";
    owner  = "akhenakh";
    repo   = "gozim";
    sha256 = "1n50fdd56r3s1sgjbpa72nvdh50gfpf6fq55c077w2p3bxn6p8k6";
    propagatedBuildInputs = [ bleve go-liblzma groupcache go-rice goquery ];
    buildInputs = [ pkgs.zip ];
    postInstall = ''
      pushd $NIX_BUILD_TOP/go/src/$goPackagePath/cmd/gozimhttpd
      ${go-rice.bin}/bin/rice append --exec $bin/bin/gozimhttpd
      popd
    '';
    dontStrip = true;
  };

  go-assert = buildGoPackage rec {
    rev = "0.0.0";
    name = "assert-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/bmizerany/assert";
    src = fetchFromGitHub {
      inherit rev;
      owner = "bmizerany";
      repo = "assert";
      sha256 = "1lfrvqqmb09y6pcr76yjv4r84cshkd4s7fpmiy7268kfi2cvqnpc";
    };
    propagatedBuildInputs = [ pretty ];
  };

  go-backblaze = buildFromGitHub {
    buildInputs = [ go-flags go-humanize uilive uiprogress ];
    goPackagePath = "gopkg.in/kothar/go-backblaze.v0";
    rev = "0.0.0";
    owner = "kothar";
    repo = "go-backblaze";
    sha256 = "1kmlwfnnfd4h46bb9pz2gw1hxqm1pzkwvidfmnc0zkrilaywk6fx";
  };

  go-base58 = buildFromGitHub {
    rev = "0.0.0";
    owner  = "jbenet";
    repo   = "go-base58";
    sha256 = "0pqmk0q9zir6nymdffn77ngzc9npwjd3sbdkdab75bv37h0ijk6a";
    date = "2015-03-17";
  };

  go-bencode = buildGoPackage rec {
    version = "1.1.1";
    name = "go-bencode-${version}";
    goPackagePath = "github.com/ehmry/go-bencode";

    src = fetchurl {
      url = "https://${goPackagePath}/archive/v${version}.tar.gz";
      sha256 = "0y2kz2sg1f7mh6vn70kga5d0qhp04n01pf1w7k6s8j2nm62h24j6";
    };
  };

  go-bindata = buildGoPackage rec {
    rev = "0.0.0";
    date = "2015-10-23";
    version = "${date}-${stdenv.lib.strings.substring 0 7 rev}";
    name = "go-bindata-${version}";
    goPackagePath = "github.com/jteeuwen/go-bindata";
    src = fetchFromGitHub {
      inherit rev;
      repo = "go-bindata";
      owner = "jteeuwen";
      sha256 = "0d6zxv0hgh938rf59p1k5lj0ymrb8kcps2vfrb9kaarxsvg7y69v";
    };

    subPackages = [ "./" "go-bindata" ]; # don't build testdata

    meta = with stdenv.lib; {
      homepage    = "https://github.com/jteeuwen/go-bindata";
      description = "A small utility which generates Go code from any file, useful for embedding binary data in a Go program";
      maintainers = with maintainers; [ cstrahan ];
      license     = licenses.cc0 ;
      platforms   = platforms.all;
    };
  };

  go-bindata-assetfs = buildFromGitHub {
    rev = "57eb5e1fc594ad4b0b1dbea7b286d299e0cb43c2";
    owner   = "elazarl";
    repo    = "go-bindata-assetfs";
    sha256 = "0kr3jz9lfivm0q9lsl6zpa4i02qa79304kn059skr0dnsnizj2q7";

    date = "2015-12-24";

    meta = with stdenv.lib; {
      description = "Serves embedded files from jteeuwen/go-bindata with net/http";
      homepage = "https://github.com/elazarl/go-bindata-assetfs";
      maintainers = with maintainers; [ matthiasbeyer ];
      license = licenses.bsd2;
    };
  };

  pmylund.go-cache = buildGoPackage rec {
    rev = "0.0.0";
    name = "go-cache-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/pmylund/go-cache";
    goPackageAliases = [
      "github.com/robfig/go-cache"
      "github.com/influxdb/go-cache"
    ];

    src = fetchFromGitHub {
      inherit rev;
      owner = "pmylund";
      repo = "go-cache";
      sha256 = "08wfwm7nk381lv6a95p0hfgqwaksn0vhzz1xxdncjdw6w71isyy7";
    };
  };

  go-charset = buildFromGitHub {
    rev = "0.0.0";
    date   = "2014-07-13";
    owner  = "paulrosania";
    repo   = "go-charset";
    sha256 = "0jp6rwxlgl66dipk6ssk8ly55jxncvsxs7jc3abgdrhr3rzccab8";
    goPackagePath = "code.google.com/p/go-charset";

    preBuild = ''
      find go/src/$goPackagePath -name \*.go | xargs sed -i 's,github.com/paulrosania/go-charset,code.google.com/p/go-charset,g'
    '';
  };

  go-checkpoint = buildFromGitHub {
    date = "2015-10-22";
    rev = "e4b2dc34c0f698ee04750bf2035d8b9384233e1b";
    owner  = "hashicorp";
    repo   = "go-checkpoint";
    sha256 = "1lnwx8c6ny3d2smj6ap4ar0d3i7fzjbi0mhmrnpmyln0anrp4yd4";
    buildInputs = [ go-cleanhttp ];
  };

  go-cleanhttp = buildFromGitHub {
    date = "2016-04-07";
    rev = "ad28ea4487f05916463e2423a55166280e8254b5";
    owner = "hashicorp";
    repo = "go-cleanhttp";
    sha256 = "1knpnv6wg2fnnsk2h2bj4m003f7xsvwm58vnn9gc753mbr78vx00";
  };

  go-colorable = buildFromGitHub {
    rev = "0.0.0";
    owner  = "mattn";
    repo   = "go-colorable";
    sha256 = "0pwc0s5lvz209dcyamv1ba1xl0c1r5hpxwlq0w5j2xcz8hzrcwkl";
  };

  go-colortext = buildFromGitHub {
    rev = "0.0.0";
    owner  = "daviddengcn";
    repo   = "go-colortext";
    sha256 = "0618xs9lc5xfp5zkkb5j47dr7i30ps3zj5fj0zpv8afqh2cc689x";
  };

  go-difflib = buildFromGitHub {
    date = "2016-01-10";
    rev = "792786c7400a136282c1664665ae0a8db921c6c2";
    owner  = "pmezard";
    repo   = "go-difflib";
    sha256 = "0xhjjfvx97zkms5004v1k3prc5g1kljiayhf05v0n0yf89s5r28r";
  };

  go-dockerclient = buildFromGitHub {
    date = "2016-05-01";
    rev = "7764ab7e9799b613f6f5eb52254f96f01c0ac8d3";
    owner = "fsouza";
    repo = "go-dockerclient";
    sha256 = "0ivppfwbc5l5fnjpa0w0xwn3b1p3qbqcrhk2wj5pf4ibn4a4y17g";
    propagatedBuildInputs = [
      docker_for_go-dockerclient
      go-cleanhttp
      mux
    ];
  };

  go-etcd = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-10-26";
    owner = "coreos";
    repo = "go-etcd";
    sha256 = "0n78m4lwsjiaqhjizcsp25paj2l2d4fdr7c4i671ldvpggq76lrl";
    propagatedBuildInputs = [ ugorji_go ];
  };

  go-flags = buildFromGitHub {
    date = "2016-02-27";
    rev = "6b9493b3cb60367edd942144879646604089e3f7";
    owner  = "jessevdk";
    repo   = "go-flags";
    sha256 = "0h73kgavvxlv3lfp2fxq51blsk8bwafchazsan88xdz7jl17cpfj";
  };

  go-fuse = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-07-27";
    owner = "hanwen";
    repo = "go-fuse";
    sha256 = "0r5amgnpb4g7b6kpz42vnj01w515by4yhy64s5lqf3snzjygaycf";
  };

  go-getter = buildFromGitHub {
    rev = "0.0.0";
    date = "2016-04-21";
    owner = "hashicorp";
    repo = "go-getter";
    sha256 = "1588haangpadyhjmcakpj41ppx56vn958if2m463d3cq3mfnhqsm";
    buildInputs = [ aws-sdk-go ];
  };

  go-git-ignore = buildFromGitHub {
    rev = "0.0.0";
    date = "2016-01-15";
    owner = "sabhiram";
    repo = "go-git-ignore";
    sha256 = "1p1gb7gnyqhpc410385a463kh8g5vwi2vi39810dwab11xc58dp9";
  };

  go-github = buildFromGitHub {
    date = "2016-04-21";
    rev = "0.0.0";
    owner = "google";
    repo = "go-github";
    sha256 = "0b7bvspw4rnfzs8s776dz2mxfj0m3x7idjhv5yzn6gk3yn2k56x6";
    buildInputs = [ oauth2 ];
    propagatedBuildInputs = [ go-querystring ];
  };

  go-gtk-agl = buildFromGitHub {
    rev = "0.0.0";
    owner = "agl";
    repo = "go-gtk";
    sha256 = "0jnhsv7ypyhprpy0fndah22v2pbbavr3db6f9wxl1vf34qkns3p4";
    # Examples require many go libs, and gtksourceview seems ready only for
    # gtk2
    preConfigure = ''
      rm -R example gtksourceview
    '';
    nativeBuildInputs = [ pkgs.pkgconfig ];
    propagatedBuildInputs = [ pkgs.gtk3 ];
    buildInputs = [ pkgs.gtkspell3 ];
  };

  go-gypsy = buildFromGitHub {
    rev = "0.0.0";
    owner  = "kylelemons";
    repo   = "go-gypsy";
    sha256 = "04iy8rdk19n7i18bqipknrcb8lsy1vr4d1iqyxsxq6rmb7298iwj";
  };

  go-homedir = buildFromGitHub {
    date = "2016-03-01";
    rev = "0.0.0";
    owner  = "mitchellh";
    repo   = "go-homedir";
    sha256 = "1p9lsrk30lgncwq6qaarccyxwxlhryq7y5srmsanxljpd5ca1h18";
  };

  bitly_go-hostpool = buildFromGitHub {
    rev = "0.0.0";
    date   = "2015-03-31";
    owner  = "bitly";
    repo   = "go-hostpool";
    sha256 = "14ph12krn5zlg00vh9g6g08lkfjxnpw46nzadrfb718yl1hgyk3g";
  };

  hailocab_go-hostpool = buildFromGitHub {
    rev = "0.0.0";
    date = "2016-01-25";
    owner  = "hailocab";
    repo   = "go-hostpool";
    sha256 = "10z01i5nh891w3rgq73y5dp9l64drb2cwxp61mxdkc60nxl3ksh5";
  };

  go-humanize = buildFromGitHub {
    rev = "0.0.0";
    owner = "dustin";
    repo = "go-humanize";
    sha256 = "18nsp65fg5inxgclx5k5qs0bwzmvby8s19ays0h12xwbyvfr6861";
    date = "2015-11-25";
  };

  go-immutable-radix = buildFromGitHub {
    date = "2016-02-21";
    rev = "8e8ed81f8f0bf1bdd829593fdd5c29922c1ea990";
    owner = "hashicorp";
    repo = "go-immutable-radix";
    sha256 = "0zpzf4sz5y99ff8d8d4hga0860af5chhbncvhs80k66rrr6hin6h";
    propagatedBuildInputs = [ golang-lru ];
  };

  go-incremental = buildFromGitHub {
    rev = "0.0.0";
    date   = "2015-02-20";
    owner  = "GeertJohan";
    repo   = "go.incremental";
    sha256 = "160cspmq73bk6cvisa6kq1dwrrp1yqpkrpq8dl69wcnaf91cbnml";
  };

  go-ini = buildFromGitHub {
    rev = "a98ad7ee00ec53921f08832bc06ecf7fd600e6a1";
    owner = "vaughan0";
    repo = "go-ini";
    sha256 = "07i40hj47z5m6wa5bzy7sc2na3hbwh84ridl40yfybgdlyrzdkf4";
    date = "2013-09-23";
  };

  go-ipfs-api = buildFromGitHub {
    date = "2016-04-14";
    rev = "0.0.0";
    owner  = "ipfs";
    repo   = "go-ipfs-api";
    sha256 = "1scmy1sbm28ml893db7n3z7ww3xj2rwz2dspxibdab1inrz3xh2w";
    excludedPackages = "tests";
    propagatedBuildInputs = [ go-multiaddr-net go-multipart-files tar-utils ];
  };

  go-isatty = buildFromGitHub {
    rev = "v0.0.1";
    owner  = "mattn";
    repo   = "go-isatty";
    sha256 = "0ynlb7bh0c6jfcx1d5hsv3zga56x049akdv8cf7hpfsrzkzcqwx8";
  };

  go-jmespath = buildFromGitHub {
    rev = "0.2.2";
    owner = "jmespath";
    repo = "go-jmespath";
    sha256 = "141a1i19fbmcf8qsz88kfb34vvmqpz5ya6hqz9r4v92by840xczi";
  };

  go-jose = buildFromGitHub {
    rev = "v1.0.1";
    owner = "square";
    repo = "go-jose";
    sha256 = "1c8x7f3msvf01k3kb07ib0jkbgg5y9pdw22j83si8bbih4wwnb63";
    goPackagePath = "gopkg.in/square/go-jose.v1";
    goPackageAliases = [
      "github.com/square/go-jose"
    ];
    buildInputs = [
      codegangsta-cli
    ];
  };

  go-liblzma = buildFromGitHub {
    rev = "0.0.0";
    date   = "2016-01-01";
    owner  = "remyoudompheng";
    repo   = "go-liblzma";
    sha256 = "12lwjmdcv2l98097rhvjvd2yz8jl741hxcg29i1c18grwmwxa7nf";
    propagatedBuildInputs = [ pkgs.lzma ];
  };

  go-log = buildGoPackage rec {
    rev = "0.0.0";
    name = "go-log-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/coreos/go-log";

    src = fetchFromGitHub {
      inherit rev;
      owner = "coreos";
      repo = "go-log";
      sha256 = "1s95xmmhcgw4ascf4zr8c4ij2n4s3mr881nxcpmc61g0gb722b13";
    };

    propagatedBuildInputs = [ osext go-systemd ];
  };

  go-lxc = buildFromGitHub {
    rev = "0.0.0";
    owner  = "lxc";
    repo   = "go-lxc";
    sha256 = "0fkkmn7ynmzpr7j0ha1qsmh3k86ncxcbajmcb90hs0k0iaaiaahz";
    goPackagePath = "gopkg.in/lxc/go-lxc.v2";
    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = [ pkgs.lxc ];
  };

  go-lz4 = buildFromGitHub {
    date = "2015-08-21";
    rev = "74ddf82598bc4745b965729e9c6a463bedd33049";
    owner  = "bkaradzic";
    repo   = "go-lz4";
    sha256 = "1f96sh6f8mr7vdwnflaca2ldah1d4j79j9p3crqgp468an9jdi3k";
  };

  go-memdb = buildFromGitHub {
    date = "2016-03-01";
    rev = "98f52f52d7a476958fa9da671354d270c50661a7";
    owner = "hashicorp";
    repo = "go-memdb";
    sha256 = "07938b1ln4x7caflhgsvaw8kikh5xcddwrc6zj0hcmzmbpfpyxai";
    buildInputs = [ go-immutable-radix ];
  };

  rcrowley_go-metrics = buildFromGitHub {
    rev = "eeba7bd0dd01ace6e690fa833b3f22aaec29af43";
    date = "2016-02-25";
    owner = "rcrowley";
    repo = "go-metrics";
    sha256 = "0xph1i8ml681xnh9qy3prvbrgzwb0sssaxlqz2yk1p6fczvq9210";
    propagatedBuildInputs = [ stathat ];
  };

  armon_go-metrics = buildFromGitHub {
    date = "2016-03-06";
    rev = "f303b03b91d770a11a39677f1d3b55da4002bbcb";
    owner = "armon";
    repo = "go-metrics";
    sha256 = "0xvqidv4xwl7hs0cvwzshmw4w1dsydrgmfbbdwr6njgx321ry2fg";
    propagatedBuildInputs = [ prometheus_client_golang datadog-go ];
  };

  go-md2man = buildFromGitHub {
    rev = "0.0.0";
    owner  = "cpuguy83";
    repo   = "go-md2man";
    sha256 = "0hmkrq4gdzb6mwllmh4p1y7vrz7hyr8xqagpk9nyr5dhygvnnq2v";
    propagatedBuildInputs = [ blackfriday ];
  };

  go-mssqldb = buildFromGitHub {
    rev = "0.0.0";
    owner = "denisenkom";
    repo = "go-mssqldb";
    sha256 = "0gws9vdd14vsz8cvpnxis38mc1xzbgrzznv0z9akqp9vfma013d6";
    date = "2015-03-11";
    buildInputs = [ crypto ];
  };

  go-multiaddr = buildFromGitHub {
    rev = "0.0.0";
    owner  = "jbenet";
    repo   = "go-multiaddr";
    sha256 = "1h6xm7ba29wjccss2x2a29abvxigb4368jpqin52ggg4zbdj2310";
    buildInputs = [ go-multihash ];
    date = "2016-01-19";
  };

  go-multiaddr-net = buildFromGitHub {
    rev = "0.0.0";
    owner  = "jbenet";
    repo   = "go-multiaddr-net";
    sha256 = "0161f35145a7adc5b4d103e99b74c8f78259735dae7b798e96142eccf12e550f";
    date = "2015-10-11";
  };

  go-multierror = buildFromGitHub {
    date = "2015-09-16";
    rev = "d30f09973e19c1dfcd120b2d9c4f168e68d6b5d5";
    owner  = "hashicorp";
    repo   = "go-multierror";
    sha256 = "0l1410m98pklnqkr6fqi2bpcqfag5z1l3snykn46ps38lb1sc3f3";
    propagatedBuildInputs = [ errwrap ];
  };

  go-multihash = buildFromGitHub {
    rev = "0.0.0";
    owner  = "jbenet";
    repo   = "go-multihash";
    sha256 = "1kbg2yxiqq9hgbl3c7m4mjl6zsbxvhsyqcc4lmqvch5cz6w8wwjm";
    propagatedBuildInputs = [ go-base58 crypto ];
    date = "2015-04-12";
  };

  go-multipart-files = buildFromGitHub {
    rev = "0.0.0";
    owner  = "whyrusleeping";
    repo   = "go-multipart-files";
    sha256 = "0afg5wdlzmvjy2v8w3rqyr4mi1zhpxs96c67knyrnf5gncf6hcql";
    date = "2015-09-03";
  };

  go-nsq = buildFromGitHub {
    rev = "0.0.0";
    owner = "nsqio";
    repo = "go-nsq";
    sha256 = "06hrkwk84w8rshkanvfgmgbiml7n06ybv192dvibhwgk2wz2dl46";
    propagatedBuildInputs = [ go-simplejson go-snappystream ];
    goPackageAliases = [ "github.com/bitly/go-nsq" ];
  };

  go-ole = buildFromGitHub {
    rev = "0.0.0";
    owner  = "go-ole";
    repo   = "go-ole";
    sha256 = "1qrbca5ahzrs3fp0rhya9g4ncnmjmkjp3xr53cd51gj6nq25xh99";
  };

  go-options = buildFromGitHub {
    rev = "0.0.0";
    date   = "2014-12-20";
    owner  = "mreiferson";
    repo   = "go-options";
    sha256 = "0ksyi2cb4k6r2fxamljg42qbz5hdcb9kv5i7y6cx4ajjy0xznwgm";
  };

  go-plugin = buildFromGitHub {
    rev = "0.0.0";
    date = "2016-02-11";
    owner  = "hashicorp";
    repo   = "go-plugin";
    sha256 = "14bda7xignx11fq7348jlr5g19sl9f4yqkrk3z29yiq152d4vlw8";
    buildInputs = [ yamux ];
  };

  go-porterstemmer = buildFromGitHub {
    rev = "0.0.0";
    date   = "2014-12-30";
    owner  = "blevesearch";
    repo   = "go-porterstemmer";
    sha256 = "0rcfbrad79xd114h3dhy5d3zs3b5bcgqwm3h5ih1lk69zr9wi91d";
  };

  go-querystring = buildFromGitHub {
    date = "2016-03-10";
    rev = "0.0.0";
    owner  = "google";
    repo   = "go-querystring";
    sha256 = "03wipzbiaiqbwbd1yi5mhnjq1czkbmzbg9alxshmamgbx092kfxq";
  };

  go-radix = buildFromGitHub {
    rev = "4239b77079c7b5d1243b7b4736304ce8ddb6f0f2";
    owner  = "armon";
    repo   = "go-radix";
    sha256 = "0b5vksrw462w1j5ipsw7fmswhpnwsnaqgp6klw714dc6ppz57aqv";
    date = "2016-01-15";
  };

  junegunn.go-runewidth = buildGoPackage rec {
    rev = "0.0.0";
    name = "go-runewidth-${rev}";
    goPackagePath = "github.com/junegunn/go-runewidth";
    src = fetchFromGitHub {
      inherit rev;
      owner = "junegunn";
      repo = "go-runewidth";
      sha256 = "07d612val59sibqly5d6znfkp4h4gjd77783jxvmiq6h2fwb964k";
    };
  };

  go-shellwords = buildGoPackage rec {
    rev = "0.0.0";
    name = "go-shellwords-${rev}";
    goPackagePath = "github.com/junegunn/go-shellwords";
    src = fetchFromGitHub {
      inherit rev;
      owner = "junegunn";
      repo = "go-shellwords";
      sha256 = "c792abe5fda48d0dfbdc32a84edb86d884a0ccbd9ed49ad48a30cda5ba028a22";
    };
  };

  go-reap = buildFromGitHub {
    rev = "2d85522212dcf5a84c6b357094f5c44710441912";
    owner  = "hashicorp";
    repo   = "go-reap";
    sha256 = "0q90nf4mgvxb26vd7avs1mw1m9cb6x9mx6jnz4xsia71ghi3lj50";
    date = "2016-01-13";
    propagatedBuildInputs = [ sys ];
  };

  go-restful = buildFromGitHub {
    rev = "0.0.0";
    owner  = "emicklei";
    repo   = "go-restful";
    sha256 = "0gr9f53vayc6501a1kaw4p3h9pgf376cgxsfnr3f2dvp0xacvw8x";
  };

  go-repo-root = buildFromGitHub {
    rev = "0.0.0";
    date = "2014-09-11";
    owner = "cstrahan";
    repo = "go-repo-root";
    sha256 = "1rlzp8kjv0a3dnfhyqcggny0ad648j5csr2x0siq5prahlp48mg4";
    buildInputs = [ tools ];
  };

  go-rice = buildFromGitHub {
    rev = "0.0.0";
    date   = "2016-01-04";
    owner  = "GeertJohan";
    repo   = "go.rice";
    sha256 = "01q2d5iwibwdl68gn8sg6dm7byc42hax3zmiqgmdw63ir1fsv4ag";
    propagatedBuildInputs = [ osext go-spew go-flags go-zipexe rsrc
      go-incremental ];
  };

  go-runit = buildFromGitHub {
    rev = "0.0.0";
    owner  = "soundcloud";
    repo   = "go-runit";
    sha256 = "00f2rfhsaqj2wjanh5qp73phx7x12a5pwd7lc0rjfv68l6sgpg2v";
  };

  go-simplejson = buildFromGitHub {
    rev = "v0.5.0";
    owner  = "bitly";
    repo   = "go-simplejson";
    sha256 = "09svnkziaffkbax5jjnjfd0qqk9cpai2gphx4ja78vhxdn4jpiw0";
  };

  go-snappystream = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-04-16";
    owner = "mreiferson";
    repo = "go-snappystream";
    sha256 = "0jdd5whp74nvg35d9hzydsi3shnb1vrnd7shi9qz4wxap7gcrid6";
  };

  go-spew = buildFromGitHub {
    rev = "5215b55f46b2b919f50a1df0eaa5886afe4e3b3d";
    date = "2015-11-05";
    owner  = "davecgh";
    repo   = "go-spew";
    sha256 = "1l4dg2xs0vj49gk0f5d4ij3hrwi72ay4w9a7xjkz1syg4qi9jy40";
  };

  go-sqlite3 = buildFromGitHub {
    rev = "0.0.0";
    date   = "2015-07-29";
    owner  = "mattn";
    repo   = "go-sqlite3";
    sha256 = "0xq2y4am8dz9w9aaq24s1npg1sn8pf2gn4nki73ylz2fpjwq9vla";
  };

  go-syslog = buildFromGitHub {
    date = "2015-02-18";
    rev = "42a2b573b664dbf281bd48c3cc12c086b17a39ba";
    owner  = "hashicorp";
    repo   = "go-syslog";
    sha256 = "0zbnlz1l1f50k8wjn8pgrkzdhr6hq4rcbap0asynvzw89crh7h4g";
  };

  go-systemd = buildFromGitHub {
    rev = "7b2428fec40033549c68f54e26e89e7ca9a9ce31";
    owner = "coreos";
    repo = "go-systemd";
    sha256 = "0z8i7a6a68dkcgmvdxkdxk6qgn56zdizjvkfg0hin2yn4xnm9wgd";
    propagatedBuildInputs = [ pkgs.systemd_lib dbus ];
    date = "2016-02-02";
  };

  lxd-go-systemd = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-07-01";
    owner = "stgraber";
    repo = "lxd-go-systemd";
    sha256 = "006dhy3j8ld0kycm8hrjxvakd7xdn1b6z2dsjp1l4sqrxdmm188w";
    buildInputs = [ dbus ];
  };

  go-units = buildFromGitHub {
    rev = "v0.3.0";
    owner = "docker";
    repo = "go-units";
    sha256 = "15gnwpncr6ibxrvnj76r6j4fyskdixhjf6nc8vaib8lhx360avqc";
  };

  go-update-v0 = buildFromGitHub {
    rev = "0.0.0";
    owner = "inconshreveable";
    repo = "go-update";
    sha256 = "0cvkik2w368fzimx3y29ncfgw7004qkbdf2n3jy5czvzn35q7dpa";
    goPackagePath = "gopkg.in/inconshreveable/go-update.v0";
    buildInputs = [ osext binarydist ];
  };

  go-uuid = buildFromGitHub {
    rev = "0.0.0";
    date   = "2015-07-22";
    owner  = "satori";
    repo   = "go.uuid";
    sha256 = "0injxzds41v8nc0brvyrrjl66fk3hycz6im38s5r9ccbwlp68p44";
  };

  hashicorp-go-uuid = buildFromGitHub {
    rev = "73d19cdc2bf00788cc25f7d5fd74347d48ada9ac";
    date = "2016-03-29";
    owner  = "hashicorp";
    repo   = "go-uuid";
    sha256 = "1c8z6g9fyhbn35ps6agyf25mhqpsdpgr6kp3rq4kw2rsal6n8lqa";
  };

  go-version = buildFromGitHub {
    rev = "0.0.0";
    owner  = "hashicorp";
    repo   = "go-version";
    sha256 = "1b8id696xc8gfyk8d92rd2yda4pgk0gccmd73xrf4v2wmgl2h5iv";
    date = "2016-02-13";
  };

  go-vhost = buildFromGitHub {
    rev = "0.0.0";
    owner  = "inconshreveable";
    repo   = "go-vhost";
    sha256 = "1rway6sls6fl2s2jk20ajj36rrlzh9944ncc9pdd19kifix54z32";
  };

  go-zipexe = buildFromGitHub {
    rev = "0.0.0";
    date   = "2015-03-29";
    owner  = "daaku";
    repo   = "go.zipexe";
    sha256 = "0vi5pskhifb6zw78w2j97qbhs09zmrlk4b48mybgk5b3sswp6510";
  };

  go-zookeeper = buildFromGitHub {
    rev = "0.0.0";
    date = "2016-04-19";
    owner  = "samuel";
    repo   = "go-zookeeper";
    sha256 = "0imrg027lkjlwahdh0agrnkr6whkcrnimspb3znq08k7gcvr30z8";
  };

  lint = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-06-23";
    owner = "golang";
    repo = "lint";
    sha256 = "1bj7zv534hyh87bp2vsbhp94qijc5nixb06li1dzfz9n0wcmlqw9";
    excludedPackages = "testdata";
    buildInputs = [ tools ];
  };

  goquery = buildGoPackage rec {
    rev = "0.0.1"; #tag v.0.3.2
    name = "goquery-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/PuerkitoBio/goquery";
    propagatedBuildInputs = [ cascadia net ];
    buildInputs = [ cascadia net ];
    doCheck = true;
    src = fetchFromGitHub {
      inherit rev;
      owner = "PuerkitoBio";
      repo = "goquery";
      sha256 = "0bskm3nja1v3pmg7g8nqjkmpwz5p72h1h81y076x1z17zrjaw585";
    };
  };

  groupcache = buildFromGitHub {
    date = "2016-02-11";
    rev = "4eab30f13db9d8b25c752e99d1583628ac2fa422";
    owner  = "golang";
    repo   = "groupcache";
    sha256 = "0i72yji981w22sk62hxd228rs13ym3zziqm3bq89xw21mdda5gj2";
    buildInputs = [ protobuf ];
  };

  grpc = buildFromGitHub {
    rev = "b062a3c003c22bfef58fa99d689e6a892b408f9d";
    date = "2016-04-25";
    owner = "grpc";
    repo = "grpc-go";
    sha256 = "0ksc8rrzss5q5lk4a778i824l530d4pj1l8jwb74x4pwcisng4y4";
    goPackagePath = "google.golang.org/grpc";
    goPackageAliases = [ "github.com/grpc/grpc-go" ];
    propagatedBuildInputs = [ http2 net protobuf oauth2 glog ];
    excludedPackages = "\\(test\\|benchmark\\)";
  };

  gtreap = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-08-07";
    owner = "steveyen";
    repo = "gtreap";
    sha256 = "03z5j8myrpmd0jk834l318xnyfm0n4rg15yq0d35y7j1aqx26gvk";
    goPackagePath = "github.com/steveyen/gtreap";
  };

  gucumber = buildFromGitHub {
    date = "2016-01-10";
    rev = "44a4d7eb3b14a88cf82b073dfb7e06277afdc549";
    owner = "lsegal";
    repo = "gucumber";
    sha256 = "1lbck0hc7hdy720w4ilnyak0qk145l9g9xjl5gb2z5y7ngclrk23";
    buildInputs = [ testify ];
    propagatedBuildInputs = [ ansicolor ];
  };

  gx = buildFromGitHub {
    rev = "0.0.0";
    owner = "whyrusleeping";
    repo = "gx";
    sha256 = "0pv30zi5dgfz12xjcvwd5r09g656cq0c7rxailc9775ingnp10jm";
    propagatedBuildInputs = [
      go-homedir
      go-multiaddr
      go-multihash
      go-multiaddr-net
      semver
      go-git-ignore
      stump
      codegangsta-cli
      go-ipfs-api
    ];
    excludedPackages = [
      "tests"
    ];
  };

  gx-go = buildFromGitHub {
    rev = "0.0.0";
    owner = "whyrusleeping";
    repo = "gx-go";
    sha256 = "04d2fj1jy41zddpflv9b6wilyrsp56a8na0km401fgn7hj2fri7v";
    buildInputs = [
      codegangsta-cli
      fs
      gx
      stump
    ];
  };

  hashstructure = buildFromGitHub {
    date = "2016-03-30";
    rev = "0.0.0";
    owner  = "mitchellh";
    repo   = "hashstructure";
    sha256 = "1qgzgyrgbywmb9wpivb2lb3wichv5rxjz0mph2jpymybxcymxf3s";
  };

  hcl = buildFromGitHub {
    date = "2016-04-26";
    rev = "9a905a34e6280ce905da1a32344b25e81011197a";
    owner  = "hashicorp";
    repo   = "hcl";
    sha256 = "0pjyhr68pisdw6ziglskz26ql0r3ixmlsnv296bvxzfh6a46v80c";
  };

  hil = buildFromGitHub {
    date = "2016-02-16";
    rev = "0457360d54ca4d081a769eaa1617e0462153fd70";
    owner  = "hashicorp";
    repo   = "hil";
    sha256 = "5386c8fe6be992f6e8f7c40bb9275d3e5dab095e8ff7df6a9b64de915406d744";
    propagatedBuildInputs = [
      mapstructure
      reflectwalk
    ];
  };

  hipchat-go = buildGoPackage rec {
    rev = "0.0.0";
    name = "hipchat-go-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/tbruyelle/hipchat-go";

    src = fetchFromGitHub {
      inherit rev;
      owner = "tbruyelle";
      repo = "hipchat-go";
      sha256 = "060wg5yjlh28v03mvm80kwgxyny6cyj7zjpcdg032b8b1sz9z81s";
    };
  };

  hmacauth = buildGoPackage {
    name = "hmacauth";
    goPackagePath = "github.com/18F/hmacauth";
    src = fetchFromGitHub {
      rev = "0.0.0";
      owner = "18F";
      repo = "hmacauth";
      sha256 = "056mcqrf2bv0g9gn2ixv19srk613h4sasl99w9375mpvmadb3pz1";
    };
  };

  hound = buildGoPackage rec {
    rev = "0.0.0";
    name = "hound-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/etsy/hound";

    src = fetchFromGitHub {
      inherit rev;
      owner  = "etsy";
      repo   = "hound";
      sha256 = "0jhnjskpm15nfa1cvx0h214lx72zjvnkjwrbgwgqqyn9afrihc7q";
    };
    buildInputs = [ go-bindata.bin pkgs.nodejs pkgs.nodePackages.react-tools pkgs.python pkgs.rsync ];
    postInstall = ''
      pushd go
      python src/github.com/etsy/hound/tools/setup
      sed -i 's|bin/go-bindata||' Makefile
      sed -i 's|$<|#go-bindata|' Makefile
      make
    '';
  };

  hologram = buildGoPackage rec {
    rev = "0.0.0";
    name = "hologram-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/AdRoll/hologram";

    src = fetchFromGitHub {
      inherit rev;
      owner  = "AdRoll";
      repo   = "hologram";
      sha256 = "0k8g7dwrkxdvmzs4aa8zz39qa8r2danc4x40hrblcgjhfcwzxrzr";
    };
    buildInputs = [ crypto protobuf goamz rgbterm go-bindata go-homedir ldap g2s gox ];
  };

  http2 = buildFromGitHub rec {
    rev = "aa7658c0e9902e929a9ed0996ef949e59fc0f3ab";
    owner = "bradfitz";
    repo = "http2";
    sha256 = "0hzmrc9vfh83s57cvfhi26zgvwmr38yg2xxw1yhygfxn3x8ri05c";
    buildInputs = [ crypto ];
    date = "2016-01-16";
  };

  httprouter = buildFromGitHub {
    rev = "77366a47451a56bb3ba682481eed85b64fea14e8";
    owner  = "julienschmidt";
    repo   = "httprouter";
    sha256 = "12hj2pc07nzha56rcpq6js0j7gs207blasxrixbwcwcgy9pamc80";
    date = "2016-02-19";
  };

  hugo = buildFromGitHub {
    rev = "0.0.0";
    owner  = "spf13";
    repo   = "hugo";
    sha256 = "1v0z9ar5kakhib3c3c43ddwd1ga4b8icirg6kk3cnaqfckd638l5";
    buildInputs = [
      mapstructure text websocket cobra osext fsnotify.v1 afero
      jwalterweatherman cast viper yaml-v2 ace purell mmark blackfriday amber
      cssmin nitro inflect fsync
    ];
  };

  i3cat = buildFromGitHub {
    rev = "0.0.0";
    date   = "2015-03-21";
    owner  = "vincent-petithory";
    repo   = "i3cat";
    sha256 = "1xlm5c9ajdb71985nq7hcsaraq2z06przbl6r4ykvzi8w2lwgv72";
    buildInputs = [ structfield ];
  };

  inf = buildFromGitHub {
    date = "2015-09-11";
    rev = "0.0.0";
    owner  = "go-inf";
    repo   = "inf";
    sha256 = "1nlk98rb2khsj4wj96m75yljqf1x35pvpf3wwpa4cin0ijxf5k9l";
    goPackagePath = "gopkg.in/inf.v0";
    goPackageAliases = [ "github.com/go-inf/inf" ];
  };

  inflect = buildGoPackage {
    name = "inflect-2013-08-29";
    goPackagePath = "bitbucket.org/pkg/inflect";
    src = fetchFromBitbucket {
      rev = "0.0.0";
      owner  = "pkg";
      repo   = "inflect";
      sha256 = "11qdyr5gdszy24ai1bh7sf0cgrb4q7g7fsd11kbpgj5hjiigxb9a";
    };
  };

  influxdb8-client = buildFromGitHub{
    rev = "0.0.0";
    owner = "influxdb";
    repo = "influxdb";
    sha256 = "0xpigp76rlsxqj93apjzkbi98ha5g4678j584l6hg57p711gqsdv";
    subPackages = [ "client" ];
  };

  eckardt.influxdb-go = buildGoPackage rec {
    rev = "0.0.0";
    name = "influxdb-go-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/eckardt/influxdb-go";
    src = fetchgit {
      inherit rev;
      url = "https://${goPackagePath}.git";
      sha256 = "5318c7e1131ba2330c90a1b67855209e41d3c77811b1d212a96525b42d391f6e";
    };
  };

  ini = buildFromGitHub {
    rev = "v1.11.0";
    owner  = "go-ini";
    repo   = "ini";
    sha256 = "10q0nksm4z91vyzhawdrmvabr847h15zl9jwh7p6kp2cb728hmbq";
  };

  flagfile = buildFromGitHub {
    date = "2015-02-13";
    rev = "871ce569c29360f95d7596f90aa54d5ecef75738";
    owner  = "spacemonkeygo";
    repo   = "flagfile";
    sha256 = "0s7g6xsv5y75gzky43065r7mfvdbgmmr6jv0w2b3nyir3z00frxn";
  };

  iochan = buildFromGitHub {
    rev = "0.0.0";
    owner  = "mitchellh";
    repo   = "iochan";
    sha256 = "1fcwdhfci41ibpng2j4c1bqfng578cwzb3c00yw1lnbwwhaq9r6b";
  };

  ipfs = buildFromGitHub {
    rev = "0.0.0";
    owner = "ipfs";
    repo = "go-ipfs";
    sha256 = "91be049bc3cf7f209a1552af721645ef854a1e0aec2071506f978a3849671894";
    gxSha256 = "00hy40lh1y90v58i3isr3fwqj83363y3whnsyhfr89c33cdpyvrj";

    subPackages = [
      "cmd/ipfs"
    ];
  };

  json2csv = buildFromGitHub {
    rev = "0.0.0";
    owner  = "jehiah";
    repo   = "json2csv";
    sha256 = "1fw0qqaz2wj9d4rj2jkfj7rb25ra106p4znfib69p4d3qibfjcsn";
  };

  jwalterweatherman = buildFromGitHub {
    rev = "0.0.0";
    owner  = "spf13";
    repo   = "jwalterweatherman";
    sha256 = "0m8867afsvka5gp2idrmlarpjg7kxx7qacpwrz1wl8y3zxyn3945";
  };

  kagome = buildFromGitHub {
    rev = "0.0.0";
    date = "2016-01-19";
    owner = "ikawaha";
    repo = "kagome";
    sha256 = "1isnjdkn9hnrkp5g37p2k5bbsrx0ma32v3icwlmwwyc5mppa4blb";

    # I disable the parallel building, because otherwise each
    # spawned compile takes over 1.5GB of RAM.
    buildFlags = "-p 1";
    enableParallelBuilding = false;

    goPackagePath = "github.com/ikawaha/kagome";
  };

  ldap = buildFromGitHub {
    rev = "0.0.0";
    owner  = "go-ldap";
    repo   = "ldap";
    sha256 = "0a86djpx9f45aii4srpgsqlljsdrfs633ypv9wr0ics6hks5b1rl";
    goPackageAliases = [
      "github.com/nmcclain/ldap"
      "github.com/vanackere/ldap"
    ];
    propagatedBuildInputs = [ asn1-ber ];
  };

  lego = buildFromGitHub {
    rev = "v0.3.1";
    owner = "xenolf";
    repo = "lego";
    sha256 = "12bry70rgdi0i9dybhaq1vfa83ac5cdka86652xry1j7a8gq0z76";

    buildInputs = [
      aws-sdk-go
      codegangsta-cli
      crypto
      dns
      weppos-dnsimple-go
      go-ini
      go-jose
      goamz
      google-api-go-client
      oauth2
      net
      vultr
    ];

    subPackages = [
      "."
    ];
  };

  levigo = buildGoPackage rec {
    rev = "0.0.0";
    name = "levigo-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/jmhodges/levigo";

    src = fetchFromGitHub {
      inherit rev;
      owner = "jmhodges";
      repo = "levigo";
      sha256 = "1lmafyk7nglhig3n471jq4hmnqf45afj5ldb2jx0253f5ii4r2yq";
    };

    buildInputs = [ pkgs.leveldb ];
  };

  liner = buildFromGitHub {
    rev = "0.0.0";
    owner  = "peterh";
    repo   = "liner";
    sha256 = "05ihxpmp6x3hw71xzvjdgxnyvyx2s4lf23xqnfjj16s4j4qidc48";
  };

  odeke-em.log = buildFromGitHub {
    rev = "0.0.0";
    owner  = "odeke-em";
    repo   = "log";
    sha256 = "059c933qjikxlvaywzpzljqnab19svymbv6x32pc7khw156fh48w";
  };

  log15 = buildFromGitHub {
    rev = "0.0.0";
    owner  = "inconshreveable";
    repo   = "log15";
    sha256 = "15wgicl078h931n90rksgbqmfixvbfxywk3m8qkaln34v69x4vgp";
    goPackagePath = "gopkg.in/inconshreveable/log15.v2";
    propagatedBuildInputs = [ go-colorable ];
  };

  log4go = buildGoPackage rec {
    rev = "0.0.0";
    name = "log4go-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/ccpaging/log4go";
    goPackageAliases = [
      "github.com/alecthomas/log4go"
      "code.google.com/p/log4go"
    ];

    src = fetchFromGitHub {
      inherit rev;
      owner = "ccpaging";
      repo = "log4go";
      sha256 = "0l9f86zzhla9hq35q4xhgs837283qrm4gxbp5lrwwls54ifiq7k2";
    };

    propagatedBuildInputs = [ go-colortext ];
  };

  logger = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-05-23";
    owner = "calmh";
    repo = "logger";
    sha256 = "1f67xbvvf210g5cqa84l12s00ynfbkjinhl8y6m88yrdb025v1vg";
  };

  logrus = buildFromGitHub rec {
    rev = "v0.10.0";
    owner = "Sirupsen";
    repo = "logrus";
    sha256 = "1rf70m0r0x3rws8334rmhj8wik05qzxqch97c31qpfgcl96ibnfb";
  };

  logutils = buildFromGitHub {
    date = "2015-06-09";
    rev = "0dc08b1671f34c4250ce212759ebd880f743d883";
    owner  = "hashicorp";
    repo   = "logutils";
    sha256 = "11p4p01x37xcqzfncd0w151nb5izmf3sy77vdwy0dpwa9j8ccgmw";
  };

  luhn = buildFromGitHub {
    rev = "v1.0.0";
    owner  = "calmh";
    repo   = "luhn";
    sha256 = "13brkbbmj9bh0b9j3avcyrj542d78l9hg3bxj7jjvkp5n5cxwp41";
  };

  lxd = buildFromGitHub {
    rev = "0.0.0";
    owner  = "lxc";
    repo   = "lxd";
    sha256 = "1yi3dr1bgdplc6nya10k5jsj3psbf3077vqad8x8cjza2z9i48fp";
    excludedPackages = "test"; # Don't build the binary called test which causes conflicts
    buildInputs = [
      gettext-go websocket crypto log15 go-lxc yaml-v2 tomb protobuf pongo2
      lxd-go-systemd go-uuid tablewriter golang-petname mux go-sqlite3 goproxy
      pkgs.python3
    ];
    postInstall = ''
      cp go/src/$goPackagePath/scripts/lxd-images $bin/bin
    '';
  };

  mathutil = buildFromGitHub {
    date = "2016-01-19";
    rev = "38a5fe05cd94d69433fd1c928417834c604f281d";
    owner = "cznic";
    repo = "mathutil";
    sha256 = "08z3ss9lw9r9mczba2dki1q0sa24gvvwg9ky9akgk045zpsx650b";
    buildInputs = [ bigfft ];
  };

  manners = buildFromGitHub {
    rev = "0.0.0";
    owner = "braintree";
    repo = "manners";
    sha256 = "07985pbfhwlhbglr9zwh2wx8kkp0wzqr1lf0xbbxbhga4hn9q3ak";

    meta = with stdenv.lib; {
      description = "A polite Go HTTP server that shuts down gracefully";
      homepage = "https://github.com/braintree/manners";
      maintainers = with maintainers; [ matthiasbeyer ];
      license = licenses.mit;
    };
  };

  mapstructure = buildFromGitHub {
    date = "2016-02-11";
    rev = "d2dd0262208475919e1a362f675cfc0e7c10e905";
    owner  = "mitchellh";
    repo   = "mapstructure";
    sha256 = "1pmjkrlz0mvs90ysag12pp4sldhfm1m91472w50wjaqhda028ijh";
  };

  mdns = buildFromGitHub {
    date = "2015-12-05";
    rev = "9d85cf22f9f8d53cb5c81c1b2749f438b2ee333f";
    owner = "hashicorp";
    repo = "mdns";
    sha256 = "0hsbhh0v0jpm4cg3hg2ffi2phis4vq95vyja81rk7kzvml17pvag";
    propagatedBuildInputs = [ net dns ];
  };

  memberlist = buildFromGitHub {
    date = "2016-03-28";
    rev = "88ac4de0d1a0ca6def284b571342db3b777a4c37";
    owner = "hashicorp";
    repo = "memberlist";
    sha256 = "0pwd52ypmq8fp7qbafsc4ll0008wwwx62xx086fzs6dirq3vchhq";
    propagatedBuildInputs = [
      dns
      ugorji_go
      armon_go-metrics
      go-multierror
    ];
  };

  mesos-dns = buildFromGitHub {
    rev = "0.0.0";
    owner = "mesosphere";
    repo = "mesos-dns";
    sha256 = "0zs6lcgk43j7jp370qnii7n55cd9pa8gl56r8hy4nagfvlvrcm02";

    # Avoid including the benchmarking test helper in the output:
    subPackages = [ "." ];

    buildInputs = [ glog mesos-go dns go-restful ];
  };

  mesos-go = buildFromGitHub {
    rev = "0.0.0";
    owner = "mesos";
    repo = "mesos-go";
    sha256 = "01ab0jf3cfb1rdwwb21r38rcfr5vp86pkfk28mws8298mlzbpri7";
    propagatedBuildInputs = [ gogo.protobuf glog net testify go-zookeeper objx pborman_uuid ];
    excludedPackages = "test";
  };

  mesos-stats = buildGoPackage rec {
    rev = "0.0.0";
    name = "mesos-stats-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/antonlindstrom/mesos_stats";
    src = fetchFromGitHub {
      inherit rev;
      owner = "antonlindstrom";
      repo = "mesos_stats";
      sha256 = "18ggyjf4nyn77gkn16wg9krp4dsphgzdgcr3mdflv6mvbr482ar4";
    };
  };

  mgo = buildFromGitHub {
    rev = "r2016.02.04";
    owner = "go-mgo";
    repo = "mgo";
    sha256 = "0q968aml9p5x49x70ay7myfg6ibggckir3gam5n6qydj6rviqpy7";
    goPackagePath = "gopkg.in/mgo.v2";
    goPackageAliases = [ "github.com/go-mgo/mgo" ];
    buildInputs = [ pkgs.cyrus-sasl tomb ];
  };

  mmark = buildFromGitHub {
    rev = "0.0.0";
    owner  = "miekg";
    repo   = "mmark";
    sha256 = "0wsi6fb6f1qi1a8yv858bkgn8pmsspw2k6dx5fx38kvg8zsb4l1a";
    buildInputs = [ toml ];
  };

  mongo-tools = buildFromGitHub {
    rev = "r3.3.4";
    owner  = "mongodb";
    repo   = "mongo-tools";
    sha256 = "0bqm4naz2a7mkxn4s9ji9j4k9y670ymhbyrm0401v327fhss8vks";
    buildInputs = [ crypto mgo go-flags gopass openssl tomb ];

    # Mongodb incorrectly names all of their binaries main
    # Let's work around this with our own installer
    preInstall = ''
      mkdir -p $bin/bin
      while read b; do
        rm -f go/bin/main
        go install $goPackagePath/$b/main
        cp go/bin/main $bin/bin/$b
      done < <(find go/src/$goPackagePath -name main | xargs dirname | xargs basename -a)
      rm -r go/bin
    '';
  };

  mousetrap = buildFromGitHub {
    rev = "0.0.0";
    owner  = "inconshreveable";
    repo   = "mousetrap";
    sha256 = "1f9g8vm18qv1rcb745a4iahql9vfrz0jni9mnzriab2wy1pfdl5b";
  };

  mow-cli = buildFromGitHub {
    rev = "772320464101e904cd51198160eb4d489be9cc49";
    owner  = "jawher";
    repo   = "mow.cli";
    sha256 = "1dwy7pwh3mig3xj1x8bcd8cm6ilv2581vah9rwi992agx3b8318s";
    date = "2016-02-21";
  };

  msgpack = buildGoPackage rec {
    rev = "0.0.0";
    name = "msgpack-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "gopkg.in/vmihailenco/msgpack.v2";

    src = fetchFromGitHub {
      inherit rev;
      owner = "vmihailenco";
      repo = "msgpack";
      sha256 = "0nq9yb85hi3c35kwyl38ywv95vd8n7aywmj78wwylglld22nfmw2";
    };
  };

  mtpfs = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-08-01";
    owner = "hanwen";
    repo = "go-mtpfs";
    sha256 = "1f7lcialkpkwk01f7yxw77qln291sqjkspb09mh0yacmrhl231g8";

    buildInputs = [ go-fuse usb ];
  };

  mux = buildFromGitHub {
    rev = "v1.1";
    owner = "gorilla";
    repo = "mux";
    sha256 = "1iicj9v3ippji2i1jf2g0jmrvql1k2yydybim3hsb0jashnq7794";
    propagatedBuildInputs = [ context ];
  };

  muxado = buildFromGitHub {
    date = "2014-03-12";
    rev = "f693c7e88ba316d1a0ae3e205e22a01aa3ec2848";
    owner  = "inconshreveable";
    repo   = "muxado";
    sha256 = "db9a65b811003bcb48d1acefe049bb12c8de232537cf07e1a4a949a901d807a2";
  };

  mysql = buildFromGitHub {
    rev = "0.0.0";
    owner  = "go-sql-driver";
    repo   = "mysql";
    sha256 = "1h0465596qi7nr0ixw2hjw89b0ss7y55rygxrwq0kzx1ws963f4h";
    date = "2016-04-11";
  };

  net-rpc-msgpackrpc = buildFromGitHub {
    date = "2015-11-15";
    rev = "a14192a58a694c123d8fe5481d4a4727d6ae82f3";
    owner = "hashicorp";
    repo = "net-rpc-msgpackrpc";
    sha256 = "007pwdpap465b32cx1i2hmf2q67vik3wk04xisq2pxvqvx81irks";
    propagatedBuildInputs = [ ugorji_go go-multierror ];
  };

  netlink = buildFromGitHub {
    rev = "18e9389da5f0b0a7901195341c22fd93a798ca5d";
    owner  = "vishvananda";
    repo   = "netlink";
    sha256 = "1x8v9azspanhj5986h0m7z99h0yicx7i9pix22hy83d2jfjlgz3j";
    date = "2016-04-30";
  };

  ngrok = buildFromGitHub {
    rev = "0.0.0";
    owner = "inconshreveable";
    repo = "ngrok";
    sha256 = "1r4nc9knp0nxg4vglg7v7jbyd1nh1j2590l720ahll8a4fbsx5a4";
    goPackagePath = "ngrok";

    preConfigure = ''
      sed -e '/jteeuwen\/go-bindata/d' \
          -e '/export GOPATH/d' \
          -e 's/go get/#go get/' \
          -e 's|bin/go-bindata|go-bindata|' -i Makefile
      make assets BUILDTAGS=release
      export sourceRoot=$sourceRoot/src/ngrok
    '';

    buildInputs = [
      git log4go websocket go-vhost mousetrap termbox-go rcrowley_go-metrics
      yaml-v1 go-bindata.bin go-update-v0 binarydist osext
    ];

    buildFlags = [ "-tags release" ];
  };

  nitro = buildFromGitHub {
    rev = "0.0.0";
    owner  = "spf13";
    repo   = "nitro";
    sha256 = "143sbpx0jdgf8f8ayv51x6l4jg6cnv6nps6n60qxhx4vd90s6mib";
  };

  nomad = buildFromGitHub {
    rev = "0.0.0";
    owner = "hashicorp";
    repo = "nomad";
    sha256 = "0avml9v44waav4ks0zgl0brsa3c0dir2wwzrh02bd2a3mpdcsv89";

    buildInputs = [
      datadog-go wmi armon_go-metrics go-radix aws-sdk-go perks speakeasy
      bolt go-systemd docker go-units go-humanize go-dockerclient ini go-ole
      dbus protobuf cronexpr consul-api errwrap go-checkpoint go-cleanhttp
      go-getter go-immutable-radix go-memdb go-multierror go-syslog
      go-version golang-lru hcl logutils memberlist net-rpc-msgpackrpc raft
      raft-boltdb scada-client serf yamux syslogparser go-jmespath osext
      go-isatty golang_protobuf_extensions mitchellh-cli copystructure
      hashstructure mapstructure reflectwalk runc prometheus_client_golang
      prometheus_common prometheus_procfs columnize gopsutil ugorji_go sys
      go-plugin circbuf go-spew
    ];

    subPackages = [
      "."
    ];
  };

  nsq = buildFromGitHub {
    rev = "0.0.0";
    owner = "bitly";
    repo = "nsq";
    sha256 = "1r7jgplzn6bgwhd4vn8045n6cmm4iqbzssbjgj7j1c28zbficy2f";

    excludedPackages = "bench";

    buildInputs = [ go-nsq go-options semver perks toml bitly_go-hostpool timer_metrics ];
  };

  ntp = buildFromGitHub {
    rev = "0.0.0";
    owner  = "beevik";
    repo   = "ntp";
    sha256 = "03fvgbjf2aprjj1s6wdc35wwa7k1w5phkixzvp5n1j21sf6w4h24";
  };

  oauth2_proxy = buildGoPackage {
    name = "oauth2_proxy";
    goPackagePath = "github.com/bitly/oauth2_proxy";
    src = fetchFromGitHub {
      rev = "0.0.0";
      owner = "bitly";
      repo = "oauth2_proxy";
      sha256 = "13f6kaq15f6ial9gqzrsx7i94jhd5j70js2k93qwxcw1vkh1b6si";
    };
    buildInputs = [
      go-assert go-options go-simplejson toml fsnotify.v1 oauth2
      google-api-go-client hmacauth
    ];
  };

  objx = buildFromGitHub {
    date = "2015-09-28";
    rev = "1a9d0bb9f541897e62256577b352fdbc1fb4fd94";
    owner  = "stretchr";
    repo   = "objx";
    sha256 = "0ycjvfbvsq6pmlbq2v7670w1k25nydnz4scx0qgiv0f4llxnr0y9";
  };

  oglematchers = buildGoPackage rec {
    rev = "0.0.0";
    name = "oglematchers-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/jacobsa/oglematchers";
    src = fetchgit {
      inherit rev;
      url = "https://${goPackagePath}.git";
      sha256 = "4075ede31601adf8c4e92739693aebffa3718c641dfca75b09cf6b4bd6c26cc0";
    };
    #goTestInputs = [ ogletest ];
    doCheck = false; # infinite recursion
  };

  oglemock = buildGoPackage rec {
    rev = "0.0.0";
    name = "oglemock-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/jacobsa/oglemock";
    src = fetchgit {
      inherit rev;
      url = "https://${goPackagePath}.git";
      sha256 = "685e7fc4308d118ae25467ba84c64754692a7772c77c197f38d8c1b63ea81da2";
    };
    buildInputs = [ oglematchers ];
    #goTestInputs = [ ogletest ];
    doCheck = false; # infinite recursion
  };

  ogletest = buildGoPackage rec {
    rev = "0.0.0";
    name = "ogletest-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/jacobsa/ogletest";
    src = fetchgit {
      inherit rev;
      url = "https://${goPackagePath}.git";
      sha256 = "0cfc43646d59dcea5772320f968aef2f565fb5c46068d8def412b8f635365361";
    };
    buildInputs = [ oglemock oglematchers ];
    doCheck = false; # check this again
  };

  oh = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-11-21";
    owner = "michaelmacinnis";
    repo = "oh";
    sha256 = "1srl3d1flqlh2k9q9pjss72rxw82msys108x22milfylmr75v03m";
    goPackageAliases = [ "github.com/michaelmacinnis/oh" ];
    buildInputs = [ adapted liner ];
  };

  openssl = buildFromGitHub {
    date = "2015-03-30";
    rev = "4c6dbafa5ec35b3ffc6a1b1e1fe29c3eba2053ec";
    owner = "10gen";
    repo = "openssl";
    sha256 = "1yyq8acz9pb19mnr9j5hd0axpw6xlm8fbqnkp4m16mmfjd6l5kii";
    goPackageAliases = [ "github.com/spacemonkeygo/openssl" ];
    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = [ pkgs.openssl ];
    propagatedBuildInputs = [ spacelog ];

    preBuild = ''
      find go/src/$goPackagePath -name \*.go | xargs sed -i 's,spacemonkeygo/openssl,10gen/openssl,g'
    '';
  };

  # reintroduced for gocrytpfs as I don't understand the 10gen/spacemonkey split
  openssl-spacemonkey = buildFromGitHub rec {
    rev = "0.0.0";
    name = "openssl-${stdenv.lib.strings.substring 0 7 rev}";
    owner = "spacemonkeygo";
    repo = "openssl";
    sha256 = "1byxwiq4mcbsj0wgaxqmyndp6jjn5gm8fjlsxw9bg0f33a3kn5jk";
    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = [ pkgs.openssl ];
    propagatedBuildInputs = [ spacelog ];
  };

  opsgenie-go-sdk = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-08-24";
    owner = "opsgenie";
    repo = "opsgenie-go-sdk";
    sha256 = "1prvnjiqmhnp9cggp9f6882yckix2laqik35fcj32117ry26p4jm";
    propagatedBuildInputs = [ seelog go-querystring goreq ];
    excludedPackages = "samples";
  };

  osext = buildFromGitHub {
    date = "2015-12-22";
    rev = "29ae4ffbc9a6fe9fb2bc5029050ce6996ea1d3bc";
    owner = "kardianos";
    repo = "osext";
    sha256 = "05803q7snh1pcwjs5f8g35wfhv21j0mp6yk9agmcx50rjcn3x6qr";
    goPackageAliases = [
      "github.com/bugsnag/osext"
      "bitbucket.org/kardianos/osext"
    ];
  };

  pat = buildFromGitHub {
    rev = "0.0.0";
    owner  = "bmizerany";
    repo   = "pat";
    sha256 = "11zxd45rvjm6cn3wzbi18wy9j4vr1r1hgg6gzlqnxffiizkycxmz";
  };

  pb = buildFromGitHub {
    rev = "0.0.0";
    owner  = "cheggaaa";
    repo   = "pb";
    sha256 = "03k4cars7hcqqgdsd0minfls2p7gjpm8q6y8vknh1s68kvxd4xam";
  };

  perks = buildFromGitHub rec {
    date = "2014-07-16";
    owner  = "bmizerany";
    repo   = "perks";
    rev = "0.0.0";
    sha256 = "1492rrqw25ciph2l9z36kb3dxzf32hh9an7jxingzdp01bxdyrsh";
  };

  beorn7_perks = buildFromGitHub rec {
    date = "2016-02-29";
    owner  = "beorn7";
    repo   = "perks";
    rev = "3ac7bf7a47d159a033b107610db8a1b6575507a4";
    sha256 = "1swhv3v8vxgigldpgzzbqxmzdwpvjdii11a3xql677mfbvgv7mpq";
  };

  pflag = buildGoPackage rec {
    date = "20131112";
    rev = "0.0.0";
    name = "pflag-${date}-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/spf13/pflag";
    src = fetchgit {
      inherit rev;
      url = "https://${goPackagePath}.git";
      sha256 = "0z8nzdhj8nrim8fz11magdl0wxnisix9p2kcvn5kkb3bg8wmxhbg";
    };
    doCheck = false; # bad import path in tests
  };

  pflag-spf13 = buildFromGitHub rec {
    rev = "0.0.0";
    owner  = "spf13";
    repo   = "pflag";
    sha256 = "139d08cq06jia0arc6cikdnhnaqms07xfay87pzq5ym86fv0agiq";
  };

  pond = let
      isx86_64 = stdenv.lib.any (n: n == stdenv.system) stdenv.lib.platforms.x86_64;
      gui = true; # Might be implemented with nixpkgs config.
  in buildFromGitHub {
    rev = "0.0.0";
    owner = "agl";
    repo = "pond";
    sha256 = "1dmgbg4ak3jkbgmxh0lr4hga1nl623mh7pvsgby1rxl4ivbzwkh4";

    buildInputs = [ net crypto protobuf ed25519 pkgs.trousers ]
      ++ stdenv.lib.optional isx86_64 pkgs.dclxvi
      ++ stdenv.lib.optionals gui [ go-gtk-agl pkgs.wrapGAppsHook ];
    buildFlags = stdenv.lib.optionalString (!gui) "-tags nogui";
    excludedPackages = "\\(appengine\\|bn256cgo\\)";
    postPatch = stdenv.lib.optionalString isx86_64 ''
      grep -r 'bn256' | awk -F: '{print $1}' | xargs sed -i \
        -e "s,golang.org/x/crypto/bn256,github.com/agl/pond/bn256cgo,g" \
        -e "s,bn256\.,bn256cgo.,g"
    '';
  };

  pongo2 = buildFromGitHub {
    rev = "0.0.0";
    date   = "2014-10-27";
    owner  = "flosch";
    repo   = "pongo2";
    sha256 = "0fd7d79644zmcirsb1gvhmh0l5vb5nyxmkzkvqpmzzcg6yfczph8";
    goPackagePath = "gopkg.in/flosch/pongo2.v3";
  };

  pool = buildGoPackage rec {
    rev = "0.0.0";
    name = "pq-${rev}";
    goPackagePath = "gopkg.in/fatih/pool.v2";

    src = fetchFromGitHub {
      inherit rev;
      owner = "fatih";
      repo = "pool";
      sha256 = "1jlrakgnpvhi2ny87yrsj1gyrcncfzdhypa9i2mlvvzqlj4r0dn0";
    };
  };

  pq = buildFromGitHub {
    rev = "dd3290b2f71a8b30bee8e4e75a337a825263d26f";
    owner  = "lib";
    repo   = "pq";
    sha256 = "1v19lr4l9qzdx0m18kdvczpqcimair1lh68k0s010vc752b0arvm";
    date = "2016-04-26";
  };

  pretty = buildGoPackage rec {
    rev = "0.0.0";
    name = "pretty-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/kr/pretty";
    src = fetchFromGitHub {
      inherit rev;
      owner = "kr";
      repo = "pretty";
      sha256 = "1m61y592qsnwsqn76v54mm6h2pcvh4wlzbzscc1ag645x0j33vvl";
    };
    propagatedBuildInputs = [ kr.text ];
  };

  prometheus_alertmanager = buildGoPackage rec {
    name = "prometheus-alertmanager-${rev}";
    rev = "0.0.0";
    goPackagePath = "github.com/prometheus/alertmanager";

    src = fetchFromGitHub {
      owner = "prometheus";
      repo = "alertmanager";
      inherit rev;
      sha256 = "0g656rzal7m284mihqdrw23vhs7yr65ax19nvi70jl51wdallv15";
    };

    buildInputs = [
      fsnotify.v0
      httprouter
      prometheus_client_golang
      prometheus_log
      pushover
    ];

    buildFlagsArray = ''
      -ldflags=
          -X main.buildVersion=${rev}
          -X main.buildBranch=master
          -X main.buildUser=nix@nixpkgs
          -X main.buildDate=20150101-00:00:00
          -X main.goVersion=${stdenv.lib.getVersion go}
    '';
  };

  prometheus_client_golang = buildFromGitHub {
    rev = "90c15b5efa0dc32a7d259234e02ac9a99e6d3b82";
    owner = "prometheus";
    repo = "client_golang";
    sha256 = "03n3pp6kmbjh8dfskibkj4gd2mwg38nqsgg81661myjncff07x18";
    propagatedBuildInputs = [
      goautoneg
      net
      protobuf
      prometheus_client_model
      prometheus_common
      prometheus_procfs
      beorn7_perks
    ];
    date = "2016-03-17";
  };

  prometheus_cli = buildFromGitHub {
    rev = "0.0.0";
    owner = "prometheus";
    repo = "prometheus_cli";
    sha256 = "1qxqrcbd0d4mrjrgqz882jh7069nn5gz1b84rq7d7z1f1dqhczxn";

    buildInputs = [
      prometheus_client_model
      prometheus_client_golang
    ];
  };

  prometheus_client_model = buildFromGitHub {
    rev = "fa8ad6fec33561be4280a8f0514318c79d7f6cb6";
    date = "2015-02-12";
    owner  = "prometheus";
    repo   = "client_model";
    sha256 = "150fqwv7lnnx2wr8v9zmgaf4hyx1lzd4i1677ypf6x5g2fy5hh6r";
    buildInputs = [ protobuf ];
  };

  prometheus_collectd-exporter = buildFromGitHub {
    rev = "0.0.0";
    owner = "prometheus";
    repo = "collectd_exporter";
    sha256 = "165zsdn0lffb6fvxz75szmm152a6wmia5skb96k1mv59qbmn9fi1";
    buildInputs = [ prometheus_client_golang ];
  };

  prometheus_common = buildFromGitHub {
    date = "2016-03-21";
    rev = "40456948a47496dc22168e6af39297a2f8fbf38c";
    owner = "prometheus";
    repo = "common";
    sha256 = "0llb7a8v421i9x7m52icdia3ywzzl05zsklsbdgamcv52zkgyfgi";
    buildInputs = [ net prometheus_client_model httprouter logrus protobuf ];
    propagatedBuildInputs = [ golang_protobuf_extensions ];
  };

  prometheus_haproxy-exporter = buildFromGitHub {
    rev = "0.0.0";
    owner = "prometheus";
    repo = "haproxy_exporter";
    sha256 = "0cwls1d4hmzjkwc50mjkxjb4sa4q6yq581wlc5sg9mdvl6g91zxr";
    buildInputs = [ prometheus_client_golang ];
  };

  prometheus_log = buildFromGitHub {
    rev = "0.0.0";
    date   = "2015-05-29";
    owner  = "prometheus";
    repo   = "log";
    sha256 = "1fl23gsw2hn3c1y91qckr661sybqcw2gqnd1gllxn3hp6p2w6hxv";
    propagatedBuildInputs = [ logrus ];
  };

  prometheus_mesos-exporter = buildFromGitHub {
    rev = "0.0.0";
    owner = "prometheus";
    repo = "mesos_exporter";
    sha256 = "059az73j717gd960g4jigrxnvqrjh9jw1c324xpwaafa0bf10llm";
    buildInputs = [ mesos-stats prometheus_client_golang glog ];
  };

  prometheus_mysqld-exporter = buildFromGitHub {
    rev = "0.0.0";
    owner = "prometheus";
    repo = "mysqld_exporter";
    sha256 = "10xnyxyb6saz8pq3ijp424hxy59cvm1b5c9zcbw7ddzzkh1f6jd9";
    buildInputs = [ mysql prometheus_client_golang ];
  };

  prometheus_nginx-exporter = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-06-01";
    owner = "discordianfish";
    repo = "nginx_exporter";
    sha256 = "0p9j0bbr2lr734980x2p8d67lcify21glwc5k3i3j4ri4vadpxvc";
    buildInputs = [ prometheus_client_golang prometheus_log ];
  };

  prometheus_node-exporter = buildFromGitHub {
    rev = "0.0.0";
    owner = "prometheus";
    repo = "node_exporter";
    sha256 = "0dmczav52v9vi0kxl8gd2s7x7c94g0vzazhyvlq1h3729is2nf0p";

    buildInputs = [
      go-runit
      ntp
      prometheus_client_golang
      prometheus_client_model
      prometheus_log
      protobuf
    ];
  };

  prometheus_procfs = buildFromGitHub {
    rev = "abf152e5f3e97f2fafac028d2cc06c1feb87ffa5";
    date = "2016-04-11";
    owner  = "prometheus";
    repo   = "procfs";
    sha256 = "08536i8yaip8lv4zas4xa59igs4ybvnb2wrmil8rzk3a2hl9zck8";
  };

  prometheus_prom2json = buildFromGitHub {
    rev = "0.0.0";
    owner = "prometheus";
    repo = "prom2json";
    sha256 = "0wwh3mz7z81fwh8n78sshvj46akcgjhxapjgfic5afc4nv926zdl";

    buildInputs = [
      golang_protobuf_extensions
      prometheus_client_golang
      protobuf
    ];
  };

  prometheus_prometheus = buildGoPackage rec {
    name = "prometheus-${version}";
    version = "0.15.1";
    goPackagePath = "github.com/prometheus/prometheus";
    rev = "0.0.0";

    src = fetchFromGitHub {
      inherit rev;
      owner = "prometheus";
      repo = "prometheus";
      sha256 = "0gljpwnlip1fnmhbc96hji2rc56xncy97qccm7v1z5j1nhc5fam2";
    };

    buildInputs = [
      consul
      dns
      fsnotify.v1
      go-zookeeper
      goleveldb
      httprouter
      logrus
      net
      prometheus_client_golang
      prometheus_log
      yaml-v2
    ];

    preInstall = ''
      mkdir -p "$bin/share/doc/prometheus" "$bin/etc/prometheus"
      cp -a $src/documentation/* $bin/share/doc/prometheus
      cp -a $src/console_libraries $src/consoles $bin/etc/prometheus
    '';

    # Metadata that gets embedded into the binary
    buildFlagsArray = let t = "${goPackagePath}/version"; in
    ''
      -ldflags=
          -X ${t}.Version=${version}
          -X ${t}.Revision=${builtins.substring 0 6 rev}
          -X ${t}.Branch=master
          -X ${t}.BuildUser=nix@nixpkgs
          -X ${t}.BuildDate=20150101-00:00:00
          -X ${t}.GoVersion=${stdenv.lib.getVersion go}
    '';
  };

  prometheus_pushgateway = buildFromGitHub rec {
    rev = "0.0.0";
    owner = "prometheus";
    repo = "pushgateway";
    sha256 = "17q5z9msip46wh3vxcsq9lvvhbxg75akjjcr2b29zrky8bp2m230";

    buildInputs = [
      protobuf
      httprouter
      golang_protobuf_extensions
      prometheus_client_golang
    ];

    nativeBuildInputs = [ go-bindata.bin ];
    preBuild = ''
    (
      cd "go/src/$goPackagePath"
      go-bindata ./resources/
    )
    '';

    buildFlagsArray = ''
      -ldflags=
          -X main.buildVersion=${rev}
          -X main.buildRev=${rev}
          -X main.buildBranch=master
          -X main.buildUser=nix@nixpkgs
          -X main.buildDate=20150101-00:00:00
          -X main.goVersion=${stdenv.lib.getVersion go}
    '';
  };

  prometheus_statsd-bridge = buildFromGitHub {
    rev = "0.0.0";
    owner = "prometheus";
    repo = "statsd_bridge";
    sha256 = "1fndpmd1k0a3ar6f7zpisijzc60f2dng5399nld1i1cbmd8jybjr";
    buildInputs = [ fsnotify.v0 prometheus_client_golang ];
  };

  properties = buildFromGitHub {
    rev = "0.0.0";
    owner  = "magiconair";
    repo   = "properties";
    sha256 = "043jhba7qbbinsij3yc475s1i42sxaqsb82mivh9gncpvnmnf6cl";
  };

  gogo.protobuf = buildFromGitHub {
    rev = "0.0.0";
    owner = "gogo";
    repo = "protobuf";
    sha256 = "1djhv9ckqhyjnnqajjv8ivcwpmjdnml30l6zhgbjcjwdyz3nyzhx";
    excludedPackages = "test";
    goPackageAliases = [
      "code.google.com/p/gogoprotobuf"
    ];
  };

  pty = buildFromGitHub {
    rev = "0.0.0";
    owner  = "kr";
    repo   = "pty";
    sha256 = "1l3z3wbb112ar9br44m8g838z0pq2gfxcp5s3ka0xvm1hjvanw2d";
  };

  purell = buildFromGitHub {
    rev = "0.0.0";
    owner  = "PuerkitoBio";
    repo   = "purell";
    sha256 = "0nma5i25j0y223ns7482lx4klcfhfwdr8v6r9kzrs0pwlq64ghs0";
    propagatedBuildInputs = [ urlesc ];
  };

  pushover = buildFromGitHub {
    rev = "0.0.0";
    owner  = "thorduri";
    repo   = "pushover";
    sha256 = "0j4k43ppka20hmixlwhhz5mhv92p6wxbkvdabs4cf7k8jpk5argq";
  };

  qart = buildFromGitHub {
    date = "2014-04-20";
    rev = "ccb109cf25f0cd24474da73b9fee4e7a3e8a8ce0";
    owner  = "vitrun";
    repo   = "qart";
    sha256 = "0i0dw748avvskwdx7bq9yfxc44nr7v3gkn21qclzcq2rr3gz11x0";
  };

  ql = buildFromGitHub {
    rev = "v1.0.3";
    owner  = "cznic";
    repo   = "ql";
    sha256 = "1r1370h0zpkhi9fs57vx621vsj8g9j0ijki0y4mpw18nz2mq620n";
    propagatedBuildInputs = [ go4 b exp strutil ];
  };

  raft = buildFromGitHub {
    date = "2016-04-09";
    rev = "1c84b7ca86424d341b95457cf6da85fdb367c4f0";
    owner  = "hashicorp";
    repo   = "raft";
    sha256 = "0iv0kc4f1z4zrxymdranb5zic1b30cyy5b36nwjcf27kvk91zddy";
    propagatedBuildInputs = [ armon_go-metrics ugorji_go ];
  };

  raft-boltdb = buildFromGitHub {
    date = "2015-02-01";
    rev = "d1e82c1ec3f15ee991f7cc7ffd5b67ff6f5bbaee";
    owner  = "hashicorp";
    repo   = "raft-boltdb";
    sha256 = "07g818sprpnl0z15wl16wj9dvyl9igqaqa0w4y7mbfblnpydvgis";
    propagatedBuildInputs = [ bolt ugorji_go raft ];
  };

  ratelimit = buildFromGitHub {
    rev = "77ed1c8a01217656d2080ad51981f6e99adaa177";
    date = "2015-11-25";
    owner  = "juju";
    repo   = "ratelimit";
    sha256 = "0m7bvg8kg9ffl624lbcq47207n6r54z9by1wy0axslishgp1lh98";
  };

  raw = buildFromGitHub {
    rev = "724aedf6e1a5d8971aafec384b6bde3d5608fba4";
    owner  = "feyeleanor";
    repo   = "raw";
    sha256 = "0pkvvvln5cyyy0y2i82jv39gjnfgzpb5ih94iav404lfsachh8m1";
    date = "2013-03-27";
  };

  relaysrv = buildFromGitHub rec {
    rev = "v0.12.18";
    owner  = "syncthing";
    repo   = "relaysrv";
    sha256 = "152z1i3kph1rqs5sfx6mjgcx6wfyg39k6pv3qnmhrb52qplwl6bz";
    buildInputs = [ syncthing-lib du ratelimit net ];
    excludedPackages = "testutil";
  };

  reflectwalk = buildFromGitHub {
    date = "2015-05-27";
    rev = "eecf4c70c626c7cfbb95c90195bc34d386c74ac6";
    owner  = "mitchellh";
    repo   = "reflectwalk";
    sha256 = "0zpapfp4vx9zr3zlw2405clgix7jzhhdphmsyhar4yhhs04fb3qz";
  };

  restic = buildFromGitHub {
    rev = "0.0.0";
    date   = "2016-01-17";
    owner  = "restic";
    repo   = "restic";
    sha256 = "0lf40539dy2xa5l1xy1kyn1vk3w0fmapa1h65ciksrdhn89ilrxv";
    # Using its delivered dependencies. Easier.
    preBuild = "export GOPATH=$GOPATH:$NIX_BUILD_TOP/go/src/$goPackagePath/Godeps/_workspace";
  };

  rgbterm = buildFromGitHub {
    rev = "0.0.0";
    owner  = "aybabtme";
    repo   = "rgbterm";
    sha256 = "1qph7drds44jzx1whqlrh1hs58k0wv0v58zyq2a81hmm72gsgzam";
  };

  ripper = buildFromGitHub {
    rev = "0.0.0";
    owner  = "odeke-em";
    repo   = "ripper";
    sha256 = "010jsclnmkaywdlyfqdmq372q7kh3qbz2zra0c4wn91qnkmkrnw1";
  };

  rsrc = buildFromGitHub {
    rev = "0.0.0";
    date   = "2015-11-03";
    owner  = "akavel";
    repo   = "rsrc";
    sha256 = "0g9fj10xnxcv034c8hpcgbhswv6as0d8l176c5nfgh1lh6klmmzc";
  };

  runc = buildFromGitHub {
    rev = "v0.1.1";
    owner  = "opencontainers";
    repo   = "runc";
    sha256 = "05dblq6l0rrgp1nn6wy8qrcmzvbncxbkcssk53smc6g6mwflrfbs";
    propagatedBuildInputs = [
      go-units
      logrus
      docker_for_runc
      go-systemd
      protobuf
      gocapability
      netlink
      codegangsta-cli
      runtime-spec
    ];
  };

  runtime-spec = buildFromGitHub {
    rev = "45f7ada1bb62414ab5488910e30bb824cbb0f22b";
    date = "2016-05-01";
    owner  = "opencontainers";
    repo   = "runtime-spec";
    sha256 = "d7ed0d883d3a4d0dd9c135731aa55ba27794f62f0cb1c8b24e96cce3c5e151a6";
    buildInputs = [
      gojsonschema
    ];
  };

  sandblast = buildGoPackage rec {
    rev = "0.0.0";
    name = "sandblast-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/aarzilli/sandblast";

    src = fetchFromGitHub {
      inherit rev;
      owner  = "aarzilli";
      repo   = "sandblast";
      sha256 = "1pj0bic3x89v44nr8ycqxwnafkiz3cr5kya4wfdfj5ldbs5xnq9l";
    };

    buildInputs = [ net text ];
  };

  # This is the upstream package name, underscores and all. I don't like it
  # but it seems wrong to change their name when packaging it.
  sanitized_anchor_name = buildFromGitHub {
    rev = "0.0.0";
    owner  = "shurcooL";
    repo   = "sanitized_anchor_name";
    sha256 = "1cnbzcf47cn796rcjpph1s64qrabhkv5dn9sbynsy7m9zdwr5f01";
  };

  scada-client = buildFromGitHub {
    date = "2015-08-28";
    rev = "84989fd23ad4cc0e7ad44d6a871fd793eb9beb0a";
    owner  = "hashicorp";
    repo   = "scada-client";
    sha256 = "0cbc50nyax4fazckm1chxychlbqgjcs93zl4hj5mnhy73089j0pk";
    buildInputs = [ armon_go-metrics net-rpc-msgpackrpc yamux ];
  };

  seelog = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-05-26";
    owner = "cihub";
    repo = "seelog";
    sha256 = "1f0rwgqlffv1a7b05736a4gf4l9dn80wsfyqcnz6qd2skhwnzv29";
  };

  segment = buildFromGitHub {
    rev = "0.0.0";
    date   = "2016-01-05";
    owner  = "blevesearch";
    repo   = "segment";
    sha256 = "09xfdlcc6bsrr5grxp6fgnw9p4cf6jc0wwa9049fd1l0zmhj2m1g";
  };

  semver = buildFromGitHub {
    rev = "0.0.0";
    owner = "blang";
    repo = "semver";
    sha256 = "09fqisaw3wd6a0mmijwdzcl6na4nl9hnxxrkca0v20nvv8yhfj3c";
  };

  serf = buildFromGitHub {
    rev = "v0.7.0";
    owner  = "hashicorp";
    repo   = "serf";
    sha256 = "1qzphmv2kci14v5xis08by1bhl09a3yhjy0glyh1wk0s96mx2d1b";

    buildInputs = [
      net circbuf armon_go-metrics ugorji_go go-syslog logutils mdns memberlist
      dns mitchellh-cli mapstructure columnize
    ];
  };

  sets = buildFromGitHub {
    rev = "6c54cb57ea406ff6354256a4847e37298194478f";
    owner  = "feyeleanor";
    repo   = "sets";
    sha256 = "11gg27znzsay5pn9wp7rl427v8bl1rsncyk8nilpsbpwfbz7q7vm";
    date = "2013-02-27";
    propagatedBuildInputs = [
      slices
    ];
  };

  skydns = buildFromGitHub {
    rev = "0.0.0";
    owner = "skynetservices";
    repo = "skydns";
    sha256 = "01vac6bd71wky5jbd5k4a0x665bjn1cpmw7p655jrdcn5757c2lv";

    buildInputs = [
      go-etcd rcrowley_go-metrics dns go-systemd prometheus_client_golang
    ];
  };

  slices = buildFromGitHub {
    rev = "bb44bb2e4817fe71ba7082d351fd582e7d40e3ea";
    owner  = "feyeleanor";
    repo   = "slices";
    sha256 = "05i934pmfwjiany6r9jgp27nc7bvm6nmhflpsspf10d4q0y9x8zc";
    date = "2013-02-25";
    propagatedBuildInputs = [
      raw
    ];
  };

  sortutil = buildFromGitHub {
    date = "2015-06-17";
    rev = "4c7342852e65c2088c981288f2c5610d10b9f7f4";
    owner = "cznic";
    repo = "sortutil";
    sha256 = "11iykyi1d7vjmi7778chwbl86j6s1742vnd4k7n1rvrg7kq558xq";
  };

  spacelog = buildFromGitHub {
    date = "2015-03-20";
    rev = "ae95ccc1eb0c8ce2496c43177430efd61930f7e4";
    owner = "spacemonkeygo";
    repo = "spacelog";
    sha256 = "0j0s42z2mi4xx0aszaq2vrnjllz562swxcq77vdk9fcn9vy10cz3";
    buildInputs = [ flagfile ];
  };

  speakeasy = buildFromGitHub {
    date = "2015-09-02";
    rev = "36e9cfdd690967f4f690c6edcc9ffacd006014a0";
    owner = "bgentry";
    repo = "speakeasy";
    sha256 = "13ixl56gap48s78yaifrqb137rkm2fazk20wq0zs76c694m44baq";
  };

  stathat = buildFromGitHub {
    date = "2016-03-03";
    rev = "91dfa3a59c5b233fef9a346a1460f6e2bc889d93";
    owner = "stathat";
    repo = "go";
    sha256 = "1d9ahyn0w7n4kyn05b7hrm7gx9nj2rws4m6zg762v1wilq96d2nh";
  };

  statos = buildFromGitHub {
    rev = "0.0.0";
    owner  = "odeke-em";
    repo   = "statos";
    sha256 = "17cpks8bi9i7p8j38x0wy60jb9g39wbzszcmhx4hlq6yzxr04jvs";
  };

  statik = buildGoPackage rec {
    rev = "0.0.0";
    name = "statik-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/rakyll/statik";

    excludedPackages = "example";

    src = fetchFromGitHub {
      inherit rev;
      owner = "rakyll";
      repo = "statik";
      sha256 = "0llk7bxmk66wdiy42h32vj1jfk8zg351xq21hwhrq7gkfljghffp";
    };
  };

  structfield = buildFromGitHub {
    rev = "0.0.0";
    date   = "2014-08-01";
    owner  = "vincent-petithory";
    repo   = "structfield";
    sha256 = "1kyx71z13mf6hc8ly0j0b9zblgvj5lzzvgnc3fqh61wgxrsw24dw";
  };

  structs = buildFromGitHub {
    date = "2016-03-17";
    rev = "0.0.0";
    owner  = "fatih";
    repo   = "structs";
    sha256 = "1ckccl33lzfbjnahp6hyjl5ghyzw44bq4knz838sga2hllam9d5f";
  };

  stump = buildFromGitHub {
    date = "2015-11-05";
    rev = "0.0.0";
    owner = "whyrusleeping";
    repo = "stump";
    sha256 = "0kspa1aqn3plsygn6nk4i6sdcqa1xcb7pgkfpzzxcady495jc5xl";
  };

  strutil = buildFromGitHub {
    date = "2015-04-30";
    rev = "1eb03e3cc9d345307a45ec82bd3016cde4bd4464";
    owner = "cznic";
    repo = "strutil";
    sha256 = "0ipn9zaihxpzs965v3s8c9gm4rc4ckkihhjppchr3hqn2vxwgfj1";
  };

  suture = buildFromGitHub rec {
    rev = "v1.1.1";
    owner  = "thejerf";
    repo   = "suture";
    sha256 = "0hpi9swsln9nrj4c18hac8905g8nbgfd8arpi8v118pasx5pw2l0";
  };

  syncthing = buildFromGitHub rec {
    rev = "v0.12.22";
    owner = "syncthing";
    repo = "syncthing";
    sha256 = "16srvpgfzzxm7iqf9nfxmpjl2qcdmds108clg6hq7ib3n4mxgb6g";
    buildFlags = [ "-tags noupgrade,release" ];
    buildInputs = [
      go-lz4 du luhn xdr snappy ratelimit osext
      goleveldb suture qart crypto net text rcrowley_go-metrics
    ];
    postPatch = ''
      # Mostly a cosmetic change
      sed -i 's,unknown-dev,${rev},g' cmd/syncthing/main.go
    '';
  };

  syncthing-lib = buildFromGitHub {
    inherit (syncthing) rev owner repo sha256;
    subPackages = [
      "lib/sync"
      "lib/logger"
      "lib/protocol"
      "lib/osutil"
      "lib/tlsutil"
      "lib/dialer"
      "lib/relay/client"
      "lib/relay/protocol"
    ];
    propagatedBuildInputs = [ go-lz4 luhn xdr text suture du net ];
  };

  syslogparser = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-07-17";
    owner  = "jeromer";
    repo   = "syslogparser";
    sha256 = "0i45q6sdzwz55zjbq1yc2kdz1jhn01g48c3m59bh0ag2dp9i4fda";
  };

  tablewriter = buildFromGitHub {
    rev = "0.0.0";
    date   = "2015-06-03";
    owner  = "olekukonko";
    repo   = "tablewriter";
    sha256 = "0n4gqjc2dqmnbpqgi9i8vrwdk4mkgyssc7l2n4r5bqx0n3nxpbps";
  };

  tar-utils = buildFromGitHub {
    rev = "0.0.0";
    date = "2016-03-22";
    owner  = "whyrusleeping";
    repo   = "tar-utils";
    sha256 = "1i2wk9g46wy4dzgrzh0whz7b5wzhjimnc2pcvq2xxp1l5g1d4mmy";
  };

  termbox-go = buildGoPackage rec {
    rev = "0.0.0";
    name = "termbox-go-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/nsf/termbox-go";
    src = fetchFromGitHub {
      inherit rev;
      owner = "nsf";
      repo = "termbox-go";
      sha256 = "16sak07bgvmax4zxfrd4jia1dgygk733xa8vk8cdx28z98awbfsh";
    };

    subPackages = [ "./" ]; # prevent building _demos
  };

  testify = buildFromGitHub {
    rev = "v1.1.3";
    owner = "stretchr";
    repo = "testify";
    sha256 = "12r2v07zq22bk322hn8dn6nv1fg04wb5pz7j7bhgpq8ji2sassdp";
    propagatedBuildInputs = [ objx go-difflib go-spew ];
  };

  kr.text = buildGoPackage rec {
    rev = "0.0.0";
    name = "kr.text-${stdenv.lib.strings.substring 0 7 rev}";
    goPackagePath = "github.com/kr/text";
    src = fetchFromGitHub {
      inherit rev;
      owner = "kr";
      repo = "text";
      sha256 = "1wkszsg08zar3wgspl9sc8bdsngiwdqmg3ws4y0bh02sjx5a4698";
    };
    propagatedBuildInputs = [ pty ];
  };

  timer_metrics = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-02-02";
    owner = "bitly";
    repo = "timer_metrics";
    sha256 = "1b717vkwj63qb5kan4b92kx4rg6253l5mdb3lxpxrspy56a6rl0c";
  };

  tokenbucket = buildFromGitHub {
    rev = "c5a927568de7aad8a58127d80bcd36ca4e71e454";
    date = "2013-12-01";
    owner = "ChimeraCoder";
    repo = "tokenbucket";
    sha256 = "11zasaakzh4fzzmmiyfq5mjqm5md5bmznbhynvpggmhkqfbc28gz";
  };

  tomb = buildFromGitHub {
    date = "2014-06-26";
    rev = "14b3d72120e8d10ea6e6b7f87f7175734b1faab8";
    owner = "go-tomb";
    repo = "tomb";
    sha256 = "1ixpcahm1j5s9rv52al1k8047hsv7axxqvxcpdpa0lr70b33n45f";
    goPackagePath = "gopkg.in/tomb.v2";
    goPackageAliases = [ "github.com/go-tomb/tomb" ];
  };

  toml = buildFromGitHub {
    rev = "0.0.0";
    date   = "2015-05-01";
    owner  = "BurntSushi";
    repo   = "toml";
    sha256 = "0gkgkw04ndr5y7hrdy0r4v2drs5srwfcw2bs1gyas066hwl84xyw";
  };

  uilive = buildFromGitHub {
    rev = "0.0.0";
    owner = "gosuri";
    repo = "uilive";
    sha256 = "0669f21hd5cw74irrfakdpvxn608cd5xy6s2nyp5kgcy2ijrq4ab";
  };

  uiprogress = buildFromGitHub {
    buildInputs = [ uilive ];
    rev = "0.0.0";
    owner = "gosuri";
    repo = "uiprogress";
    sha256 = "1s61vp2h6n1d8y1zqr2ca613ch5n18rx28waz6a8im94sgzzawp7";
  };

  urlesc = buildFromGitHub {
    rev = "0.0.0";
    owner  = "opennota";
    repo   = "urlesc";
    sha256 = "0dppkmfs0hb5vcqli191x9yss5vvlx29qxjcywhdfirc89rn0sni";
  };

  usb = buildFromGitHub rec {
    rev = "0.0.0";
    date = "2014-12-17";
    owner = "hanwen";
    repo = "usb";
    sha256 = "01k0c2g395j65vm1w37mmrfkg6nm900khjrrizzpmx8f8yf20dky";

    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = [ pkgs.libusb1 ];
  };

  pborman_uuid = buildFromGitHub {
    rev = "0.0.0";
    date = "2015-08-24";
    owner = "pborman";
    repo = "uuid";
    sha256 = "0hswk9ihv3js5blp9pk2bpig64zkmyp5p1zhmgydfhb0dr2w8iad";
  };

  hashicorp_uuid = buildFromGitHub {
    rev = "0.0.0";
    date = "2016-03-11";
    owner = "hashicorp";
    repo = "uuid";
    sha256 = "0b6m9q7q9c4akwy2rvi11qnkwr05rsr45adm4fgiy29z5pialp6h";
  };

  vault = buildFromGitHub rec {
    rev = "0.0.0";
    owner = "hashicorp";
    repo = "vault";
    sha256 = "9279123ca97ec164c0169be1b1c48ebb23ad76ec04607f5f85fe5c1c50455ef8";

    buildInputs = [
      armon_go-metrics go-radix govalidator aws-sdk-go speakeasy etcd-client
      duo_api_golang structs ini ldap mysql gocql snappy go-github
      go-querystring hailocab_go-hostpool consul-api errwrap go-cleanhttp
      go-multierror go-syslog golang-lru logutils serf hashicorp_uuid
      go-jmespath osext pq mitchellh-cli copystructure go-homedir mapstructure
      reflectwalk columnize go-zookeeper ugorji_go crypto net oauth2 sys
      asn1-ber inf yaml yaml-v2 hashicorp-go-uuid hcl go-mssqldb
    ];
  };

  vault-api = buildFromGitHub {
    inherit (vault) rev owner repo sha256;
    subPackages = [ "api" ];
    propagatedBuildInputs = [
      hcl
      structs
      go-cleanhttp
      go-multierror
      mapstructure
    ];
  };

  vcs = buildFromGitHub {
    rev = "0.0.0";
    owner  = "Masterminds";
    repo   = "vcs";
    sha256 = "1qav4lf4ln5gs81714876q2cy9gfaxblbvawg3hxznbwakd9zmd8";
  };

  viper = buildFromGitHub {
    rev = "0.0.0";
    owner  = "spf13";
    repo   = "viper";
    sha256 = "0q0hkla23hgvc3ab6qdlrfwxa8lnhy2s2mh2c8zrh632gp8d6prl";
    propagatedBuildInputs = [
      mapstructure yaml-v2 jwalterweatherman crypt fsnotify.v1 cast properties
      pretty toml pflag-spf13
    ];
  };

  vulcand = buildGoPackage rec {
    rev = "0.0.0";
    name = "vulcand-${rev}";
    goPackagePath = "github.com/mailgun/vulcand";
    preBuild = "export GOPATH=$GOPATH:$NIX_BUILD_TOP/go/src/${goPackagePath}/Godeps/_workspace";
    src = fetchFromGitHub {
      inherit rev;
      owner = "mailgun";
      repo = "vulcand";
      sha256 = "08mal9prwlsav63r972q344zpwqfql6qw6v4ixbn1h3h32kk3ic6";
    };
    subPackages = [ "./" ];
  };

  vultr = buildFromGitHub {
    rev = "v1.8";
    owner  = "JamesClonk";
    repo   = "vultr";
    sha256 = "1p4vb6rbcfr02fml2sj8nwsy34q4n9ylidhr90vjzk99x57pcjf7";
    propagatedBuildInputs = [
      mow-cli
      tokenbucket
      ratelimit
    ];
  };

  w32 = buildFromGitHub {
    rev = "0.0.0";
    owner = "shirou";
    repo = "w32";
    sha256 = "08cy2fh5clcsis6d4krvs07427157scrqap4a37f6042n3da07g0";
    date = "2016-02-04";
  };

  websocket = buildFromGitHub {
    rev = "0.0.0";
    owner  = "gorilla";
    repo   = "websocket";
    sha256 = "0gljdfxqc94yb1kpqqrm5p94ph9dsxrzcixhdj6m92cwwa7z7p99";
  };

  wmi = buildFromGitHub {
    rev = "0.0.0";
    owner = "StackExchange";
    repo = "wmi";
    sha256 = "0fjy37pj3v7v92yb4q4ysxlzzafgpz5vyd7zb2x36k27igbmaiab";
    date = "2015-05-20";
  };

  xmpp-client = buildFromGitHub {
    rev = "0.0.0";
    date     = "2016-01-10";
    owner    = "agl";
    repo     = "xmpp-client";
    sha256   = "0a1r08zs723ikcskmn6ylkdi3frcd0i0lkx30i9q39ilf734v253";
    buildInputs = [ crypto net ];

    meta = with stdenv.lib; {
      description = "An XMPP client with OTR support";
      homepage = https://github.com/agl/xmpp-client;
      license = licenses.bsd3;
      maintainers = with maintainers; [ codsl ];
    };
  };

  yaml = buildFromGitHub {
    rev = "0.0.0";
    date = "2016-03-07";
    owner = "ghodss";
    repo = "yaml";
    sha256 = "06cjwpwgbbb250m8ffriw0kylpljh7gcq8c5fajk9xymn9y7l3v7";
    propagatedBuildInputs = [ candiedyaml ];
  };

  yaml-v1 = buildGoPackage rec {
    name = "yaml-v1-${version}";
    version = "git-2015-05-01";
    goPackagePath = "gopkg.in/yaml.v1";
    src = fetchFromGitHub {
      rev = "0.0.0";
      owner = "go-yaml";
      repo = "yaml";
      sha256 = "0jbdy41pplf2d1j24qwr8gc5qsig6ai5ch8rwgvg72kq9q0901cy";
    };
  };

  yaml-v2 = buildFromGitHub {
    rev = "a83829b6f1293c91addabc89d0571c246397bbf4";
    date = "2016-03-01";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "0jf2man0a6jz02zcgqaadqa3844jz5kihrb343jq52xp2180zwzz";
    goPackagePath = "gopkg.in/yaml.v2";
  };

  yamux = buildFromGitHub {
    date = "2016-04-20";
    rev = "c8a8a076e0858546ae6e2ee189d94e78b9b881ce";
    owner  = "hashicorp";
    repo   = "yamux";
    sha256 = "0r9gg73z84hhd06k6x2yr4gdibals7m676ghpisq72baz8jkzyhi";
  };

  xdr = buildFromGitHub {
    rev = "8cb24337527a8f0f70bd43be68676a4390ca1c14";
    date = "2016-01-28";
    owner  = "calmh";
    repo   = "xdr";
    sha256 = "e72f1e0869388c5949d99d03dcb077b1e7edf0137c42eae8cc2b5c8e77dd92f2";
  };

  xon = buildFromGitHub {
    rev = "0.0.0";
    owner  = "odeke-em";
    repo   = "xon";
    sha256 = "07a7zj01d4a23xqp01m48jp2v5mw49islf4nbq2rj13sd5w4s6sc";
  };

  zappy = buildFromGitHub {
    date = "2016-03-05";
    rev = "4f5e6ef19fd692f1ef9b01206de4f1161a314e9a";
    owner = "cznic";
    repo = "zappy";
    sha256 = "1kinbjs95hv16kn4cgm3vb1yzv09ina7br5m3ygh803qzxp7i5jz";
  };

  ninefans = buildFromGitHub {
    rev = "0.0.0";
    date   = "2015-10-24";
    owner  = "9fans";
    repo   = "go";
    sha256 = "0kzyxhs2xf0339nlnbm9gc365b2svyyjxnr86rphx5m072r32ims";
    goPackagePath = "9fans.net/go";
    goPackageAliases = [
      "github.com/9fans/go"
    ];
    excludedPackages = "\\(plan9/client/cat\\|acme/Watch\\)";
    buildInputs = [ net ];
  };

  godef = buildFromGitHub {
    rev = "0.0.0";
    date   = "2015-10-24";
    owner  = "rogpeppe";
    repo   = "godef";
    sha256 = "1wkvsz8nqwyp36wbm8vcw4449sfs46894nskrfj9qbsrjijvamyc";
    excludedPackages = "\\(go/printer/testdata\\)";
    buildInputs = [ ninefans ];
    subPackages = [ "./" ];
  };

  godep = buildFromGitHub {
    rev = "0.0.0";
    date   = "2015-10-15";
    owner  = "tools";
    repo   = "godep";
    sha256 = "0zc1ah5cvaqa3zw0ska89a40x445vwl1ixz8v42xi3zicx16ibwz";
  };

  color = buildFromGitHub {
    rev = "0.0.0";
    owner    = "fatih";
    repo     = "color";
    sha256   = "1vjcgx4xc0h4870qzz4mrh1l0f07wr79jm8pnbp6a2yd41rm8wjp";
    propagatedBuildInputs = [ net go-isatty ];
    buildInputs = [ ansicolor go-colorable ];
  };

  pup = buildFromGitHub {
    rev = "0.0.0";
    owner    = "EricChiang";
    repo     = "pup";
    sha256   = "04j3fy1vk6xap8ad7k3c05h9b5mg2n1vy9vcyg9rs02cb13d3sy0";
    propagatedBuildInputs = [ net ];
    buildInputs = [ go-colorable color ];
    postPatch = ''
      grep -sr github.com/ericchiang/pup/Godeps/_workspace/src/ |
        cut -f 1 -d : |
        sort -u |
        xargs -d '\n' sed -i -e s,github.com/ericchiang/pup/Godeps/_workspace/src/,,g
    '';
  };

  textsecure = buildFromGitHub rec {
    rev = "0.0.0";
    owner = "janimo";
    repo = "textsecure";
    sha256 = "0sdcqd89dlic0bllb6mjliz4x54rxnm1r3xqd5qdp936n7xs3mc6";
    propagatedBuildInputs = [ crypto protobuf ed25519 yaml-v2 logrus ];
  };

  interlock = buildFromGitHub rec {
    version = "2016.01.14";
    rev = "0.0.0";
    owner = "inversepath";
    repo = "interlock";
    sha256 = "0wabx6vqdxh2aprsm2rd9mh71q7c2xm6xk9a6r1bn53r9dh5wrsb";
    buildInputs = [ crypto textsecure ];
    nativeBuildInputs = [ pkgs.sudo ];
    buildFlags = [ "-tags textsecure" ];
    subPackages = [ "./cmd/interlock" ];
    postPatch = ''
      grep -lr '/s\?bin/' | xargs sed -i \
        -e 's|/bin/mount|${pkgs.utillinux}/bin/mount|' \
        -e 's|/bin/umount|${pkgs.utillinux}/bin/umount|' \
        -e 's|/bin/cp|${pkgs.coreutils}/bin/cp|' \
        -e 's|/bin/mv|${pkgs.coreutils}/bin/mv|' \
        -e 's|/bin/chown|${pkgs.coreutils}/bin/chown|' \
        -e 's|/bin/date|${pkgs.coreutils}/bin/date|' \
        -e 's|/sbin/poweroff|${pkgs.systemd}/sbin/poweroff|' \
        -e 's|/usr/bin/sudo|/var/setuid-wrappers/sudo|' \
        -e 's|/sbin/cryptsetup|${pkgs.cryptsetup}/bin/cryptsetup|'
    '';
  };
}; in self

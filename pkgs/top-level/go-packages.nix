/* This file defines the composition for Go packages. */

{ stdenv
, buildGoPackage
, fetchbzr
, fetchFromBitbucket
, fetchFromGitHub
, fetchgit
, fetchhg
, fetchpatch
, fetchurl
, fetchzip
, git
, go
, overrides
, pkgs
}:

let
  self = _self // overrides; _self = with self; {

  inherit go buildGoPackage;

  fetchGxPackage = { src, sha256 }: stdenv.mkDerivation {
    name = "gx-src-${src.name}";

    impureEnvVars = [ "IPFS_API" ];

    buildCommand = ''
      if ! [ -f /etc/ssl/certs/ca-certificates.crt ]; then
        echo "Missing /etc/ssl/certs/ca-certificates.crt" >&2
        echo "Please update to a version of nix which supports ssl." >&2
        exit 1
      fi

      start="$(date -u '+%s')"

      unpackDir="$TMPDIR/src"
      mkdir "$unpackDir"
      cd "$unpackDir"
      unpackFile "${src}"
      cd *

      mtime=$(find . -type f -print0 | xargs -0 -r stat -c '%Y' | sort -n | tail -n 1)
      if [ "$start" -lt "$mtime" ]; then
        str="The newest file is too close to the current date:\n"
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
      ${src.tar}/bin/tar --sort=name --owner=0 --group=0 --numeric-owner \
        --no-acls --no-selinux --no-xattrs \
        --mode=go=rX,u+rw,a-s \
        --clamp-mtime --mtime=@$mtime \
        -c . | ${src.brotli}/bin/brotli --quality 6 --output "$out"
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
    , version
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
            inherit rev owner repo sha256 version;
          };
        in if gxSha256 == null then
          src'
        else
          fetchGxPackage { src = src'; sha256 = gxSha256; };
      })
  );

  ## OFFICIAL GO PACKAGES

  appengine = buildFromGitHub {
    version = 2;
    rev = "v1.0.0";
    owner = "golang";
    repo = "appengine";
    sha256 = "0z0vrrwh4f4ji2v3sv40db7m5l31mw08mjwlgzibf0nfjaganwgl";
    goPackagePath = "google.golang.org/appengine";
    propagatedBuildInputs = [
      protobuf
      net
    ];
  };

  crypto = buildFromGitHub {
    version = 2;
    rev = "9477e0b78b9ac3d0b03822fd95422e2fe07627cd";
    date = "2016-10-31";
    owner    = "golang";
    repo     = "crypto";
    sha256 = "13bh912v42950rw019mnxvdyhn6z8whnrfm73pqxlwk0i6vhml2z";
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
    version = 1;
    rev = "23def4e6c14b4da8ac2ed8007337bc5eb5007998";
    date = "2016-01-25";
    owner  = "golang";
    repo   = "glog";
    sha256 = "0wj30z2r6w1zdbsi8d14cx103x13jszlqkvdhhanpglqr22mxpy0";
  };

  net = buildFromGitHub {
    version = 2;
    rev = "0e2717dc3cc05907dc23096ef3a9086ea93f567f";
    date = "2016-11-10";
    owner  = "golang";
    repo   = "net";
    sha256 = "0fxx3cfdakhcv1f0zs6h9yikakdvziwzaj6a64hk2fcj5yk8lpn7";
    goPackagePath = "golang.org/x/net";
    goPackageAliases = [
      "github.com/hashicorp/go.net"
      "github.com/golang/net"
    ];
    propagatedBuildInputs = [ text crypto ];
  };

  net_crypto_lib = buildFromGitHub {
    inherit (net) rev date owner repo sha256 version goPackagePath;
    subPackages = [
      "context"
    ];
  };

  oauth2 = buildFromGitHub {
    version = 2;
    rev = "d5040cddfc0da40b408c9a1da4728662435176a9";
    date = "2016-11-03";
    owner = "golang";
    repo = "oauth2";
    sha256 = "1psb3sp3691x4d8rb4fs6km57j9hm5r7icijfbwnx8a6345hc1gp";
    goPackagePath = "golang.org/x/oauth2";
    goPackageAliases = [ "github.com/golang/oauth2" ];
    propagatedBuildInputs = [
      net
      google-cloud-go-compute-metadata
    ];
  };


  protobuf = buildFromGitHub {
    version = 2;
    rev = "4bd1920723d7b7c925de087aa32e2187708897f7";
    date = "2016-11-08";
    owner = "golang";
    repo = "protobuf";
    sha256 = "01qdki2gdng9mqabbx7yf4qindrpsyib7l2rq92k7812lndqv24j";
    goPackagePath = "github.com/golang/protobuf";
    goPackageAliases = [
      "code.google.com/p/goprotobuf"
    ];
  };

  snappy = buildFromGitHub {
    version = 1;
    rev = "d9eb7a3d35ec988b8585d4a0068e462c27d28380";
    date = "2016-05-29";
    owner  = "golang";
    repo   = "snappy";
    sha256 = "1z7xwm1w0nh2p6gdp0cg6hvzizs4zjn43c7vrm1fmf3sdvp6pxnw";
    goPackageAliases = [
      "code.google.com/p/snappy-go/snappy"
    ];
  };

  sys = buildFromGitHub {
    version = 2;
    rev = "b699b7032584f0953262cb2788a0ca19bb494703";
    date = "2016-11-10";
    owner  = "golang";
    repo   = "sys";
    sha256 = "07zpfag9wyqga8r5cki40bh12mq7mn73535ns8qpqv71c1c8xi9c";
    goPackagePath = "golang.org/x/sys";
    goPackageAliases = [
      "github.com/golang/sys"
    ];
  };

  text = buildFromGitHub {
    version = 2;
    rev = "a263ba8db058568bb9beba166777d9c9dbe75d68";
    date = "2016-10-26";
    owner = "golang";
    repo = "text";
    sha256 = "1i2ypl1m6bv5dgp9kvg44brg8m263426njggnjv9h74yhcpr290b";
    goPackagePath = "golang.org/x/text";
    goPackageAliases = [ "github.com/golang/text" ];
    excludedPackages = "cmd";
  };

  tools = buildFromGitHub {
    version = 2;
    rev = "5061f921c7c3e66b68ad903adf57da380c327b8c";
    date = "2016-11-09";
    owner = "golang";
    repo = "tools";
    sha256 = "0kz91rjihbp9mqxdd2fq62maxdypsyg7kyx2sxk8iizsvhg04m78";
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
    version = 2;
    owner = "yosssi";
    repo = "ace";
    rev = "ea038f4770b6746c3f8f84f14fa60d9fe1205b56";
    date = "2016-07-28";
    sha256 = "15bw81d4d25q54w0a26rqfljs1iqmqv9pk4yark8n95dbrrk57rd";
    buildInputs = [
      gohtml
    ];
  };

  afero = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "afero";
    rev = "06b7e5f50606ecd49148a01a6008942d9b669217";
    date = "2016-11-08";
    sha256 = "1zm81ap9lbvnn7sr838aviwa2zjahgfd9pwajgqckmb776bpkl6a";
    propagatedBuildInputs = [
      sftp
      text
    ];
  };

  amber = buildFromGitHub {
    version = 2;
    owner = "eknkc";
    repo = "amber";
    rev = "a69a021e158c3b06700cc881c05d0923f627b578";
    date = "2016-10-12";
    sha256 = "1050dnl3vdzhhk2slbc453lfabgn4xcrdfrahjdk88ldbsh6qshn";
  };

  amqp = buildFromGitHub {
    version = 1;
    owner = "streadway";
    repo = "amqp";
    rev = "2e25825abdbd7752ff08b270d313b93519a0a232";
    date = "2016-03-11";
    sha256 = "03w1xc4adaiyywsrflrfb8hzsfvlsc1gprm5hycm6rzd6rw3c4jm";
  };

  ansi = buildFromGitHub {
    version = 1;
    owner = "mgutz";
    repo = "ansi";
    rev = "c286dcecd19ff979eeb73ea444e479b903f2cfcb";
    date = "2015-09-14";
    sha256 = "1yifpfc2bil9ljrbp6ia10xl10jd95bp4c3k5jfpjnym77a942vq";
    propagatedBuildInputs = [
      go-colorable
    ];
  };

  ansicolor = buildFromGitHub {
    version = 1;
    date = "2015-11-20";
    rev = "a422bbe96644373c5753384a59d678f7d261ff10";
    owner  = "shiena";
    repo   = "ansicolor";
    sha256 = "1qfq4ax68d7a3ixl60fb8kgyk0qx0mf7rrk562cnkpgzrhkdcm0w";
  };

  asn1-ber = buildFromGitHub {
    version = 2;
    rev = "b144e4fe15d4968eb8d6e33d70761727d124814e";
    owner  = "go-asn1-ber";
    repo   = "asn1-ber";
    sha256 = "1n5x5y71f8g1p63x5dnpj2pj79625j2j3d8swgyrbi845frrskdd";
    goPackageAliases = [
      "github.com/nmcclain/asn1-ber"
      "github.com/vanackere/asn1-ber"
      "gopkg.in/asn1-ber.v1"
    ];
    date = "2016-09-13";
  };

  auroradnsclient = buildFromGitHub {
    version = 2;
    rev = "v1.0.1";
    owner  = "edeckers";
    repo   = "auroradnsclient";
    sha256 = "0pcjz19aycd01v4v52zbfldhr81rxy6aj7jh1y09issnqr8kgc4h";
    propagatedBuildInputs = [
      logrus
    ];
  };

  aws-sdk-go = buildFromGitHub {
    version = 2;
    rev = "v1.5.3";
    owner  = "aws";
    repo   = "aws-sdk-go";
    sha256 = "0qpfypkahvbsq9kypixxcyrji8bsr63xai6k2yrwd791m80kvkgi";
    excludedPackages = "\\(awstesting\\|example\\)";
    buildInputs = [
      tools
    ];
    propagatedBuildInputs = [
      ini
      go-jmespath
      net
    ];
    preBuild = ''
      pushd go/src/$goPackagePath
      make generate
      popd
    '';
  };

  azure-sdk-for-go = buildFromGitHub {
    version = 2;
    date = "2016-11-10";
    rev = "27ae5c8b5bc5d90ab0540b4c5d0f2632c8db8b57";
    owner  = "Azure";
    repo   = "azure-sdk-for-go";
    sha256 = "03abs6qllwvhfvd5dpm0f6dhb64azhwq6n41ba6cs63ic4z9l41d";
    excludedPackages = "Gododir";
    buildInputs = [
      go-autorest
      satori_uuid
    ];
  };

  b = buildFromGitHub {
    version = 1;
    date = "2016-07-16";
    rev = "bcff30a622dbdcb425aba904792de1df606dab7c";
    owner  = "cznic";
    repo   = "b";
    sha256 = "0zjr4spbgavwq4lvxzl3h8hrkbyjk49vq14jncpydrjw4a9qql95";
  };

  bigfft = buildFromGitHub {
    version = 1;
    date = "2013-09-13";
    rev = "a8e77ddfb93284b9d58881f597c820a2875af336";
    owner = "remyoudompheng";
    repo = "bigfft";
    sha256 = "1cj9zyv3shk8n687fb67clwgzlhv47y327180mvga7z741m48hap";
  };

  binding = buildFromGitHub {
    version = 1;
    date = "2016-07-12";
    rev = "9440f336b443056c90d7d448a0a55ad8c7599880";
    owner = "go-macaron";
    repo = "binding";
    sha256 = "1pfciq2flpavqg5v140xa1w2nwrmyfkp0lx331ainbxqbqc49mqh";
    buildInputs = [
      com
      compress
      macaron_v1
    ];
  };

  blackfriday = buildFromGitHub {
    version = 2;
    owner = "russross";
    repo = "blackfriday";
    rev = "5f33e7b7878355cd2b7e6b8eefc48a5472c69f70";
    sha256 = "15j4y3a3s0p0phdi5wyzz8c4v7zlvpy78f2nkczm8k15syyrjih8";
    propagatedBuildInputs = [
      sanitized-anchor-name
    ];
    date = "2016-10-03";
  };

  blake2b-simd = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "blake2b-simd";
    date = "2016-07-23";
    rev = "3f5f724cb5b182a5c278d6d3d55b40e7f8c2efb4";
    sha256 = "5ead55b23a24393a96cb6504b0a64c48812587c4af12527101c3a7c79c2d35e5";
  };

  bolt = buildFromGitHub {
    version = 1;
    rev = "v1.3.0";
    owner  = "boltdb";
    repo   = "bolt";
    sha256 = "1kjbih12cs9x380d5fb0qrx6n63pkfb2j9hnqrr95gz2215pqczp";
  };

  btree = buildFromGitHub {
    version = 2;
    rev = "925471ac9e2131377a91e1595defec898166fe49";
    owner  = "google";
    repo   = "btree";
    sha256 = "13j2c46rzbl6zdyiwg4ddgpgfan31y20x0dy2zc93809cvdsfy3l";
    date = "2016-10-05";
  };

  bufio_v1 = buildFromGitHub {
    version = 1;
    date = "2014-06-18";
    rev = "567b2bfa514e796916c4747494d6ff5132a1dfce";
    owner  = "go-bufio";
    repo   = "bufio";
    sha256 = "07dwsbh2c584wrm72hwnqsk22mr936hshsxma2jaxpgpkf6z1f3c";
    goPackagePath = "gopkg.in/bufio.v1";
  };

  bufs = buildFromGitHub {
    version = 1;
    date = "2014-08-18";
    rev = "3dcccbd7064a1689f9c093a988ea11ac00e21f51";
    owner  = "cznic";
    repo   = "bufs";
    sha256 = "0551h2slsb7lg3r6yif65xvf6k8f0izqwyiigpipm3jhlln37c6p";
  };

  cascadia = buildFromGitHub {
    version = 2;
    date = "2016-10-18";
    rev = "65919c611220063037b1db8eb334acaf17a6d8ea";
    owner  = "andybalholm";
    repo   = "cascadia";
    sha256 = "09zq9a9m9m9qpva9hjvzlh75269rfm98v0s2qx4k8s93gk0ncrw0";
    propagatedBuildInputs = [
      net
    ];
  };

  cast = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "cast";
    rev = "2580bc98dc0e62908119e4737030cc2fdfc45e4c";
    date = "2016-09-26";
    sha256 = "0imay4f5yy39vwfmzr5yy8csc0jzcpfqllzijwhn5p7rcm14yny2";
    buildInputs = [
      jwalterweatherman
    ];
  };

  cbauth = buildFromGitHub {
    version = 1;
    date = "2016-06-09";
    rev = "ae8f8315ad044b86ced2e0be9e3598e9dd94f38e";
    owner = "couchbase";
    repo = "cbauth";
    sha256 = "185c10ab80cn4jxdp915h428lm0r9zf1cqrfsjs71im3w3ankvsn";
  };

  check = buildFromGitHub {
    version = 2;
    date = "2016-01-05";
    rev = "4f90aeace3a26ad7021961c297b22c42160c7b25";
    owner = "go-check";
    repo = "check";
    goPackagePath = "gopkg.in/check.v1";
    goPackageAliases = [
      "github.com/go-check/check"
    ];
    sha256 = "00d4623wn0d4ls3yfcs8wsva7sc6b2y3qppxmw32whcyx4syk2v1";
  };

  circbuf = buildFromGitHub {
    version = 1;
    date = "2015-08-26";
    rev = "bbbad097214e2918d8543d5201d12bfd7bca254d";
    owner  = "armon";
    repo   = "circbuf";
    sha256 = "0wgpmzh0ga2kh51r214jjhaqhpqr9l2k6p0xhy5a006qypk5fh2m";
  };

  circonus-gometrics = buildFromGitHub {
    version = 2;
    date = "2016-11-09";
    rev = "d17a8420c36e800fcb46bbd4d2a15b93c68605ea";
    owner  = "circonus-labs";
    repo   = "circonus-gometrics";
    sha256 = "0ah0dwbk128lrkvma3jjjvqjyk1haxyawpiv9a95nramdicxm0aj";
    propagatedBuildInputs = [
      circonusllhist
      go-retryablehttp
    ];
  };

  circonusllhist = buildFromGitHub {
    version = 2;
    date = "2016-11-10";
    rev = "0e8e86d926b63602c762b8b5647fe14ae2ba6757";
    owner  = "circonus-labs";
    repo   = "circonusllhist";
    sha256 = "1hcwgsvgprmrhm133nq0c85ml7z1i4x7cmiccblrnbgjsnkm95wz";
  };

  cli_minio = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "cli";
    date = "2016-09-08";
    rev = "2e10078e4de1ca37fb1bd62cc79ab87c024b3a1b";
    sha256 = "91256fee4f36fe631ab1d5acb50f58d7efc41f2dcd64ab72b9702cc99d0d5b6d";
  };

  mitchellh_cli = buildFromGitHub {
    version = 2;
    date = "2016-10-29";
    rev = "fa17b36f6c61f1ddbbb08c9f6fde94b3c065a09d";
    owner = "mitchellh";
    repo = "cli";
    sha256 = "1xjh016f6qfjdw4m89i97l8hqkrfcblyx5miw6x12as4f7mkddzz";
    propagatedBuildInputs = [ crypto go-radix speakeasy go-isatty ];
  };

  urfave_cli = buildFromGitHub {
    version = 2;
    rev = "v1.18.1";
    owner = "urfave";
    repo = "cli";
    sha256 = "0vcmwlb9cp7jxza78wm3g2xwdw06fd5my7b43a2pgfhy0621jwi3";
    goPackageAliases = [
      "github.com/codegangsta/cli"
    ];
    buildInputs = [
      yaml_v2
    ];
  };

  clockwork = buildFromGitHub {
    version = 2;
    rev = "v0.1.0";
    owner = "jonboulle";
    repo = "clockwork";
    sha256 = "1hwdrck8k4nxdc0zpbd4hbxsyh8xhip9k7d71cv4ziwlh71sci5g";
  };

  clog = buildFromGitHub {
    version = 1;
    date = "2016-06-09";
    rev = "ae8f8315ad044b86ced2e0be9e3598e9dd94f38e";
    owner = "couchbase";
    repo = "clog";
    sha256 = "185c10ab80cn4jxdp915h428lm0r9zf1cqrfsjs71im3w3ankvsn";
  };

  cmux = buildFromGitHub {
    version = 2;
    date = "2016-07-15";
    rev = "b64f5908f4945f4b11ed4a0a9d3cc1e23350866d";
    owner = "cockroachdb";
    repo = "cmux";
    sha256 = "0jzd6sq80xp558ljsiyi3i0ln7i54bzhi317yig8fiwljyz0blrz";
    propagatedBuildInputs = [
      net
    ];
  };

  cobra = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "cobra";
    rev = "6e91dded25d73176bf7f60b40dd7aa1f0bf9be8d";
    date = "2016-10-25";
    sha256 = "0345hd63rwi8q5irs4hghqmxacz50gx6sx2azrqi1m15ha0ky882";
    buildInputs = [
      pflag
      viper
    ];
    propagatedBuildInputs = [
      go-md2man
    ];
  };

  color = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner  = "fatih";
    repo   = "color";
    sha256 = "1k3vcxmy0hb7zxfakwpw90zy7fmkix9rlfvxlxag35c7xhm2xjkd";
    propagatedBuildInputs = [
      go-colorable
      go-isatty
    ];
  };

  colorstring = buildFromGitHub {
    version = 1;
    rev = "8631ce90f28644f54aeedcb3e389a85174e067d1";
    owner  = "mitchellh";
    repo   = "colorstring";
    sha256 = "14dgak39642j795miqg5x7sb4ncpjgikn7vvbymxc5azy7z764hx";
    date = "2015-09-17";
  };

  columnize = buildFromGitHub {
    version = 2;
    rev = "6f43af5ecd2928c6fef2b4f35ef6f36f96690390";
    owner  = "ryanuber";
    repo   = "columnize";
    sha256 = "1qxfmnbh1y5zia4izxjv97mc56gxwfxn6g17jhjqvjx962d4lprn";
    date = "2016-09-14";
  };

  com = buildFromGitHub {
    version = 1;
    rev = "28b053d5a2923b87ce8c5a08f3af779894a72758";
    owner  = "Unknwon";
    repo   = "com";
    sha256 = "0rl00hsj57xbpbj7bz1c9lqwq4lwh8i1yamm3gadzdxir9lysj91";
    date = "2015-10-08";
  };

  compress = buildFromGitHub {
    version = 2;
    rev = "v1.1";
    owner  = "klauspost";
    repo   = "compress";
    sha256 = "09p3scgw2l90h8nq5n4v8ym2mi8hr6nbqi71n1yyjz1hadday4s5";
    propagatedBuildInputs = [
      cpuid
      crc32
    ];
  };

  configure = buildFromGitHub {
    version = 2;
    rev = "4e0f2df8846ee9557b5c88307a769ff2f85e89cd";
    owner = "gravitational";
    repo = "configure";
    sha256 = "04qdmaz5pyd6nn7r5mdc2chzsx1zr2q0wv245xzzahx5n9m2x34x";
    date = "2016-10-02";
    propagatedBuildInputs = [
      gojsonschema
      kingpin_v2
      trace
      yaml_v2
    ];
    excludedPackages = "test";
  };

  consul = buildFromGitHub {
    version = 2;
    rev = "v0.7.1";
    owner = "hashicorp";
    repo = "consul";
    sha256 = "1gmvdg01mv9nmwf77y34x7gxg124a7hxdqkcv8rdkx1y7fl9sp9f";

    buildInputs = [
      datadog-go circbuf armon_go-metrics go-radix speakeasy bolt
      go-bindata-assetfs go-dockerclient errwrap go-checkpoint
      go-immutable-radix go-memdb ugorji_go go-multierror go-reap go-syslog
      golang-lru hcl logutils memberlist net-rpc-msgpackrpc raft_v2 raft-boltdb_v2
      scada-client yamux muxado dns mitchellh_cli mapstructure columnize
      copystructure hil hashicorp-go-uuid crypto sys aws-sdk-go
    ];

    propagatedBuildInputs = [
      go-cleanhttp
      serf
    ];

    # Keep consul.ui for backward compatability
    passthru.ui = pkgs.consul-ui;
  };

  consul_api = buildFromGitHub {
    inherit (consul) rev owner repo sha256 version;
    propagatedBuildInputs = [
      go-cleanhttp
      serf
    ];
    subPackages = [
      "api"
      "lib"
      "tlsutil"
    ];
    meta.autoUpdate = false;
  };

  consul-template = buildFromGitHub {
    version = 2;
    rev = "v0.16.0";
    owner = "hashicorp";
    repo = "consul-template";
    sha256 = "0c5wl8azm65w5pcqbqmw0cdq336r5fsvbayc6j4qhxs3sjxfcph5";

    buildInputs = [
      consul_api
      go-cleanhttp
      go-multierror
      go-reap
      go-shellwords
      go-syslog
      logutils
      mapstructure
      serf
      toml
      yaml_v2
      vault_api
    ];
  };

  context = buildFromGitHub {
    version = 1;
    rev = "v1.1";
    owner = "gorilla";
    repo = "context";
    sha256 = "0fsm31ayvgpcddx3bd8fwwz7npyd7z8d5ja0w38lv02yb634daj6";
  };

  copystructure = buildFromGitHub {
    version = 2;
    date = "2016-10-13";
    rev = "5af94aef99f597e6a9e1f6ac6be6ce0f3c96b49d";
    owner = "mitchellh";
    repo = "copystructure";
    sha256 = "1yp71islikmgmzlg3hfwih9cfca0k9lmb3bz7yv1v54vk34lq118";
    propagatedBuildInputs = [ reflectwalk ];
  };

  core = buildFromGitHub {
    version = 2;
    rev = "v0.5.6";
    owner = "go-xorm";
    repo = "core";
    sha256 = "0mrywfw7npvfz052rkkzvxgcjdp9azmh5dk36rzaj1i0yyhs06i9";
  };

  cors = buildFromGitHub {
    version = 2;
    owner = "rs";
    repo = "cors";
    rev = "v1.0";
    sha256 = "018bf66d3425cffafa913e6ebf4d5ba26a5c22313e041140ed177921b53e4852";
    propagatedBuildInputs = [
      net
      xhandler
    ];
  };

  cpuid = buildFromGitHub {
    version = 1;
    rev = "v1.0";
    owner  = "klauspost";
    repo   = "cpuid";
    sha256 = "1bwp3mx8dik8ib8smf5pwbnp6h8p2ai4ihqijncd0f981r31c6ms";
    buildInputs = [
      net
    ];
  };

  crc32 = buildFromGitHub {
    version = 2;
    rev = "cb6bfca970f6908083f26f39a79009d608efd5cd";
    owner  = "klauspost";
    repo   = "crc32";
    sha256 = "0j7zr015kcagh03w6lsqyrbq3iwldlva3mkayq5gs16gvzl3igmp";
    date = "2016-10-16";
  };

  cronexpr = buildFromGitHub {
    version = 1;
    rev = "f0984319b44273e83de132089ae42b1810f4933b";
    owner  = "gorhill";
    repo   = "cronexpr";
    sha256 = "0d2c67spcyhr4bxzmnqsxnzbn6a8sw893wvc4cx7a3js4ydy7raz";
    date = "2016-03-18";
  };

  crypt = buildFromGitHub {
    version = 1;
    owner = "xordataexchange";
    repo = "crypt";
    rev = "749e360c8f236773f28fc6d3ddfce4a470795227";
    date = "2015-05-23";
    sha256 = "0zc00mpvqv7n1pz6fn6570wf9j8dc5d2m49yrqqygs52r2iarpx5";
    propagatedBuildInputs = [
      consul_api
      crypto
      go-etcd
    ];
    postPatch = ''
      sed -i backend/consul/consul.go \
        -e 's,"github.com/armon/consul-api",consulapi "github.com/hashicorp/consul/api",'
    '';
  };

  cssmin = buildFromGitHub {
    version = 1;
    owner = "dchest";
    repo = "cssmin";
    rev = "fb8d9b44afdc258bfff6052d3667521babcb2239";
    date = "2015-12-10";
    sha256 = "1m9zqdaw2qycvymknv6vx2i4jlpdj6lcjysxd18czbf5kp6pcri4";
  };

  datadog-go = buildFromGitHub {
    version = 1;
    rev = "1.0.0";
    owner = "DataDog";
    repo = "datadog-go";
    sha256 = "13kjgqx5bs187fapqiirsaig950n2is0a35y2b7ap07dazxxxh3m";
  };

  dbus = buildFromGitHub {
    version = 2;
    rev = "850816941114ebdf6d68a20595de37db822a5e8a";
    owner = "godbus";
    repo = "dbus";
    sha256 = "1ljx6pmlhxzm9j4xm1ycfbpnqrggsyw7dg8w5wglfvzfdq76gs66";
    date = "2016-11-10";
  };

  distribution = buildFromGitHub {
    version = 2;
    rev = "v2.5.1";
    owner = "docker";
    repo = "distribution";
    sha256 = "0qygqdf8myy0cmd28bfp5vil9aslrhdsc0wn8h90pfjjg5msabxh";
  };

  distribution_engine-api = buildFromGitHub {
    inherit (distribution) rev owner repo sha256 version;
    subPackages = [
      "digest"
      "reference"
    ];
  };

  dns = buildFromGitHub {
    version = 2;
    rev = "58f52c57ce9df13460ac68200cef30a008b9c468";
    date = "2016-10-18";
    owner  = "miekg";
    repo   = "dns";
    sha256 = "0fgnkjzxfdjrpb58vl9r5zk237v7q5wyx49vqflm1ah95gbbf0d4";
  };

  weppos-dnsimple-go = buildFromGitHub {
    version = 1;
    rev = "65c1ca73cb19baf0f8b2b33219b7f57595a3ccb0";
    date = "2016-02-04";
    owner  = "weppos";
    repo   = "dnsimple-go";
    sha256 = "0v3vnp128ybzmh4fpdwhl6xmvd815f66dgdjzxarjjw8ywzdghk9";
  };

  docker = buildFromGitHub {
    version = 2;
    rev = "851d9149b1e9d67811b227ed7cdf1fc6734ccdda";
    owner = "docker";
    repo = "docker";
    sha256 = "03065dki18j543mbwxnplfw730870lzvf4iwjygdvysp3bnw3s73";
    meta.useUnstable = true;
    date = "2016-11-11";
  };

  docker_for_runc = buildFromGitHub {
    inherit (docker) rev date owner repo sha256 version meta;
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
    inherit (docker) rev date owner repo sha256 version meta;
    subPackages = [
      "api/types"
      "api/types/blkiodev"
      "api/types/container"
      "api/types/filters"
      "api/types/mount"
      "api/types/strslice"
      "api/types/swarm"
      "api/types/versions"
      "opts"
      "pkg/archive"
      "pkg/fileutils"
      "pkg/homedir"
      "pkg/idtools"
      "pkg/integration/cmd"
      "pkg/ioutils"
      "pkg/jsonlog"
      "pkg/jsonmessage"
      "pkg/pools"
      "pkg/promise"
      "pkg/stdcopy"
    ];
    propagatedBuildInputs = [
      check
      engine-api
      go-units
      logrus
      net
      runc
    ];
  };

  docker_for_teleport = buildFromGitHub {
    inherit (docker) rev date owner repo sha256 version meta;
    subPackages = [
      "pkg/term"
    ];
  };

  docopt-go = buildFromGitHub {
    version = 1;
    rev = "0.6.2";
    owner  = "docopt";
    repo   = "docopt-go";
    sha256 = "11cxmpapg7l8f4ar233f3ybvsir3ivmmbg1d4dbnqsr1hzv48xrf";
  };

  du = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "calmh";
    repo   = "du";
    sha256 = "02gri7xy9wp8szxpabcnjr18qic6078k213dr5k5712s1pg87qmj";
  };

  duo_api_golang = buildFromGitHub {
    version = 2;
    date = "2016-06-27";
    rev = "2b2d787eb38e28ce4fd906321d717af19fad26a6";
    owner = "duosecurity";
    repo = "duo_api_golang";
    sha256 = "17vi9qg1dd02pmqjajqkspvdl676f0jhfzh4vzr4rxrcwgnqxdwx";
  };

  dsync = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "dsync";
    date = "2016-10-26";
    rev = "9c7a452d3ceb9ac24894452aa184147930343e6f";
    sha256 = "1hwf5h4wy52741wgvm7wjsydsm2cy03kymm60pgzqd60hjcqx9bx";
  };

  ed25519 = buildFromGitHub {
    version = 1;
    owner = "agl";
    repo = "ed25519";
    rev = "278e1ec8e8a6e017cd07577924d6766039146ced";
    sha256 = "0jsscj4n6wcp3zyphinr461kwkxgrx5365jymbqnhqzki759xm5h";
    date = "2015-08-30";
  };

  elastic_v2 = buildFromGitHub {
    version = 2;
    owner = "olivere";
    repo = "elastic";
    rev = "v2.0.54";
    sha256 = "9360c71601d67abd5b611ff6221ad92d02985d555046c874af61ef1d9bdb7fb7";
    goPackagePath = "gopkg.in/olivere/elastic.v2";
  };

  elastic_v3 = buildFromGitHub {
    version = 2;
    owner = "olivere";
    repo = "elastic";
    rev = "v5.0.4";
    sha256 = "12mqiy6cbvi93w1hrqzli5xpv846xqgnm98avwbi38x7f68fv5wa";
    goPackagePath = "gopkg.in/olivere/elastic.v3";
    propagatedBuildInputs = [
      net
    ];
  };

  emoji = buildFromGitHub {
    version = 1;
    owner = "kyokomi";
    repo = "emoji";
    rev = "v1.4";
    sha256 = "1k87kd0h4qk2klbxx3r86g07wk9mgrb0jhdj8kgd2hlgh45j4pd2";
  };

  encoding = buildFromGitHub {
    version = 2;
    owner = "jwilder";
    repo = "encoding";
    date = "2016-09-27";
    rev = "4dada27c33277820fe35c7ee71ed34fbc9477d00";
    sha256 = "14xlhzr94x0qyrik05ijfjxpcbnnda8rhndgm02kfh2fi5kqk37z";
  };

  engine-api = buildFromGitHub {
    version = 1;
    rev = "v0.4.0";
    owner = "docker";
    repo = "engine-api";
    sha256 = "1cgqhlngxlvplp6p560jvh4p003nm93pl4wannnlhwhcjrd34vyy";
    propagatedBuildInputs = [
      distribution_engine-api
      go-connections
    ];
  };

  envpprof = buildFromGitHub {
    version = 1;
    rev = "0383bfe017e02efb418ffd595fc54777a35e48b0";
    owner = "anacrolix";
    repo = "envpprof";
    sha256 = "0i9d021hmcfkv9wv55r701p6j6r8mj55fpl1kmhdhvar8s92rjgl";
    date = "2016-05-28";
  };

  errors = buildFromGitHub {
    version = 2;
    owner = "pkg";
    repo = "errors";
    rev = "v0.8.0";
    sha256 = "00fi35kiry67anhr4lxryyw5l9c26xj2zc5wzspr4z39paxgb4km";
  };

  errwrap = buildFromGitHub {
    version = 1;
    date = "2014-10-27";
    rev = "7554cd9344cec97297fa6649b055a8c98c2a1e55";
    owner  = "hashicorp";
    repo   = "errwrap";
    sha256 = "02hsk2zbwg68w62i6shxc0lhjxz20p3svlmiyi5zjz988qm3s530";
  };

  etcd = buildFromGitHub {
    version = 2;
    owner = "coreos";
    repo = "etcd";
    rev = "v3.0.14";
    sha256 = "1q95j0zc8ffs5md2ryq74g8f01ja6y5kyl8jz7n4id1m266rzy2z";
    buildInputs = [
      bolt
      btree
      urfave_cli
      clockwork
      cobra
      cmux
      gopcap
      go-humanize
      go-semver
      go-systemd
      groupcache
      grpc
      grpc-gateway
      loghisto
      net
      pb_v1
      pflag
      pkg
      probing
      procfs
      prometheus_client_golang
      pty
      gogo_protobuf
      speakeasy
      tablewriter
      ugorji_go
      yaml

      pkgs.libpcap
    ];
  };

  etcd_client = buildFromGitHub {
    inherit (etcd) rev owner repo sha256 version;
    subPackages = [
      "client"
      "pkg/fileutil"
      "pkg/pathutil"
      "pkg/tlsutil"
      "pkg/transport"
      "pkg/types"
    ];
    buildInputs = [
      go-systemd
      net
    ];
    propagatedBuildInputs = [
      pkg
      ugorji_go
    ];
  };

  exp = buildFromGitHub {
    version = 1;
    date = "2016-07-11";
    rev = "888ba4519f76bfc1e26a9b32e52c6775677b36fd";
    owner  = "cznic";
    repo   = "exp";
    sha256 = "1a32kv2wjzz1yfgivrm1bp4hzg878jwfmv9qy9hvdx0kccy7rvpw";
    propagatedBuildInputs = [ bufs fileutil mathutil sortutil zappy ];
  };

  fileutil = buildFromGitHub {
    version = 1;
    date = "2015-07-08";
    rev = "1c9c88fbf552b3737c7b97e1f243860359687976";
    owner  = "cznic";
    repo   = "fileutil";
    sha256 = "0naps0miq8lk4k7k6c0l9583nv6wcdbs9zllvsjjv60h4fsz856a";
    buildInputs = [
      mathutil
    ];
  };

  flagfile = buildFromGitHub {
    version = 2;
    date = "2016-10-12";
    rev = "25bbc4d62e1d1375f0dbd5a506cee7b79d7b1fc5";
    owner  = "spacemonkeygo";
    repo   = "flagfile";
    sha256 = "1sigrak391jz5f4zv1scnhwkmg9dzxszf0wymhi8dpz018kmj8s7";
  };

  fs = buildFromGitHub {
    version = 1;
    date = "2013-11-07";
    rev = "2788f0dbd16903de03cb8186e5c7d97b69ad387b";
    owner  = "kr";
    repo   = "fs";
    sha256 = "16ygj65wk30cspvmrd38s6m8qjmlsviiq8zsnnvkhfy5l0gk4c86";
  };

  fsnotify = buildFromGitHub {
    version = 2;
    owner = "fsnotify";
    repo = "fsnotify";
    rev = "v1.4.2";
    sha256 = "1kbs526vl358dd9rrcdnniwnzhcxkbswkmkl80dl2sgi9x0w45g6";
    propagatedBuildInputs = [
      sys
    ];
  };

  fsnotify_v1 = buildFromGitHub {
    version = 2;
    owner = "fsnotify";
    repo = "fsnotify";
    rev = "v1.4.2";
    sha256 = "1f3zshxdd3kj08b87106gxj68fjljfb7b3r9i8xjrj0i79wy6phn";
    goPackagePath = "gopkg.in/fsnotify.v1";
    propagatedBuildInputs = [
      sys
    ];
  };

  fsync = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "fsync";
    rev = "1773df7b269b572f0fc8df916b38e3c9d15cee66";
    date = "2016-07-01";
    sha256 = "0khg3453ckyralw9dhlavf1vs433prlwpvfsk4n8z2aw8nzs2vb9";
    buildInputs = [
      afero
    ];
  };

  gabs = buildFromGitHub {
    version = 2;
    owner = "Jeffail";
    repo = "gabs";
    rev = "855034b6b7a3b7144977efcaefe72d2c64b0d039";
    date = "2016-08-09";
    sha256 = "1kq1r8ybb4a4112drskn5m6lp64np3qdsm0lfmyfv7s2yzdij9ff";
  };

  gateway = buildFromGitHub {
    version = 1;
    date = "2016-05-22";
    rev = "edad739645120eeb82866bc1901d3317b57909b1";
    owner  = "calmh";
    repo   = "gateway";
    sha256 = "0gzwns51jl2jm62ii99c7caa9p7x2c8p586q1cjz8bpv2mcd8njg";
    goPackageAliases = [
      "github.com/jackpal/gateway"
    ];
  };

  gax-go = buildFromGitHub {
    version = 2;
    date = "2016-11-07";
    rev = "da06d194a00e19ce00d9011a13931c3f6f6887c7";
    owner  = "googleapis";
    repo   = "gax-go";
    sha256 = "0qsrkf0pcf2rx086flz6p9ifcmxdkhgx7jki88w17hh3rsj39ay7";
    propagatedBuildInputs = [
      grpc
      net
    ];
  };

  genproto = buildFromGitHub {
    version = 2;
    date = "2016-11-03";
    rev = "f3350869260a1e80675c8d0e42f1f3a870db2b74";
    owner  = "google";
    repo   = "go-genproto";
    goPackagePath = "google.golang.org/genproto";
    sha256 = "1m1ks4f4l42jqyazha8s60xjs0miy31irqcxqv9nwdhxpxrcs3wm";
    propagatedBuildInputs = [
      grpc
      net
      protobuf
    ];
  };

  geoip2-golang = buildFromGitHub {
    version = 2;
    rev = "v1.0.0";
    owner = "oschwald";
    repo = "geoip2-golang";
    sha256 = "1kpc4cmfr95rml0xbb57md860qf0n544vh2s1gcwq8y7r6ihac23";
    propagatedBuildInputs = [
      maxminddb-golang
    ];
  };

  gettext = buildFromGitHub {
    version = 2;
    rev = "v0.9";
    owner = "gosexy";
    repo = "gettext";
    sha256 = "1zrxfzwlv04gadxxyn8whmdin83ij735bbggxrnf3mcbxs8svs96";
    buildInputs = [
      go-flags
      go-runewidth
    ];
  };

  ginkgo = buildFromGitHub {
    version = 2;
    rev = "00054c0bb96fc880d4e0be1b90937fad438c5290";
    owner = "onsi";
    repo = "ginkgo";
    sha256 = "1d41f560r6nsw69ghh3q5ny869pp3ar0pmhm3rmsyrs62h153c91";
    date = "2016-11-10";
  };

  gjson = buildFromGitHub {
    version = 2;
    owner = "tidwall";
    repo = "gjson";
    date = "2016-11-04";
    rev = "72b0cad1c18345c48d7ddf5ade1f2c45af35b442";
    sha256 = "16nxzy8y6ys0z1qaryhp9nbdrlmrcagpfgm9pi3k3l67539gk3cb";
    propagatedBuildInputs = [
      match
    ];
  };

  glob = buildFromGitHub {
    version = 2;
    rev = "v0.2.1";
    owner = "gobwas";
    repo = "glob";
    sha256 = "1iypjxg50089gv4sj5m6df06d479svnnvcypz73fs0pnrmqwg32s";
  };

  siddontang_go = buildFromGitHub {
    version = 2;
    date = "2016-10-05";
    rev = "1e9ce2a5ac4092fdf61e293634e40bfb49595105";
    owner = "siddontang";
    repo = "go";
    sha256 = "0gvvbvpk9yn24lhg4fzncwrs32awmll8s27qvsz2an0lvscqbhcz";
  };

  ugorji_go = buildFromGitHub {
    version = 2;
    date = "2016-09-27";
    rev = "faddd6128c66c4708f45fdc007f575f75e592a3c";
    owner = "ugorji";
    repo = "go";
    sha256 = "0gav420a4xglf7p7g9ikm8bnm51y447v6plwyngajmam2ywp16gr";
    goPackageAliases = [ "github.com/hashicorp/go-msgpack" ];
  };

  go4 = buildFromGitHub {
    version = 2;
    date = "2016-09-23";
    rev = "399a9d7bfe85437346a5ec4ef0450fc2f1084e61";
    owner = "camlistore";
    repo = "go4";
    sha256 = "1bm6a0apz38kqw5yrvw7y3qqw55hd7dq4nk52jcm5isdzvqy0vlr";
    goPackagePath = "go4.org";
    goPackageAliases = [ "github.com/camlistore/go4" ];
    buildInputs = [
      google-cloud-go-for-go4
      oauth2
      net
      sys
    ];
  };

  goamz = buildFromGitHub {
    version = 2;
    rev = "fb002ae75f50beb93874fa6ce2c861e488ce08a0";
    owner  = "goamz";
    repo   = "goamz";
    sha256 = "16z3wf5sii3cgrkccm6mijg6i028rlyf3212s0zs20az9wak4pvv";
    date = "2016-09-17";
    goPackageAliases = [
      "github.com/mitchellh/goamz"
    ];
    excludedPackages = "testutil";
    buildInputs = [
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
      version = 1;
      inherit rev;
      owner  = "ww";
      repo   = "goautoneg";
      sha256 = "9acef1c250637060a0b0ac3db033c1f679b894ef82395c15f779ec751ec7700a";
    };

    meta.autoUpdate = false;
  };

  gocapability = buildFromGitHub {
    version = 2;
    rev = "e7cb7fa329f456b3855136a2642b197bad7366ba";
    owner = "syndtr";
    repo = "gocapability";
    sha256 = "0k8nbsg4h9b8srd2ykkilf73m19b8lm6ib2cx98n5s6m0af4m7y7";
    date = "2016-09-28";
  };

  gocql = buildFromGitHub {
    version = 2;
    rev = "47f897f054183a4c891f27b235f11221683982dc";
    owner  = "gocql";
    repo   = "gocql";
    sha256 = "1wcikjgw7pli1kp3ms62z37n1h40hm60sczkalrq7fqz639axhqf";
    propagatedBuildInputs = [
      inf_v0
      snappy
      hailocab_go-hostpool
      net
    ];
    date = "2016-11-07";
  };

  gojsonpointer = buildFromGitHub {
    version = 1;
    rev = "e0fe6f68307607d540ed8eac07a342c33fa1b54a";
    owner  = "xeipuuv";
    repo   = "gojsonpointer";
    sha256 = "1gm1m5vf1nkg87qhskpqfyg9r8n0fy74nxvp6ajcqb04v3k8sd7v";
    date = "2015-10-27";
  };

  gojsonreference = buildFromGitHub {
    version = 1;
    rev = "e02fc20de94c78484cd5ffb007f8af96be030a45";
    owner  = "xeipuuv";
    repo   = "gojsonreference";
    sha256 = "1c2yhjjxjvwcniqag9i5p159xsw4452vmnc2nqxnfsh1whd8wpi5";
    date = "2015-08-08";
    propagatedBuildInputs = [ gojsonpointer ];
  };

  gojsonschema = buildFromGitHub {
    version = 2;
    rev = "3a089261b6b42d98d910b1444e36ac9347ad87f9";
    owner  = "xeipuuv";
    repo   = "gojsonschema";
    sha256 = "1shcm259n9qlxab5c7461if5qqf70j5p14vgvx267ar5akfhb469";
    date = "2016-11-05";
    propagatedBuildInputs = [ gojsonreference ];
  };

  gollectd = buildFromGitHub {
    version = 2;
    owner = "kimor79";
    repo = "gollectd";
    rev = "v1.0.0";
    sha256 = "16ax20j3ji6zqxii16kinvgrxb0xjn9qhfhhiin7k40w0aas5dhi";
  };

  gomemcache = buildFromGitHub {
    version = 1;
    rev = "fb1f79c6b65acda83063cbc69f6bba1522558bfc";
    date = "2016-01-17";
    owner = "bradfitz";
    repo = "gomemcache";
    sha256 = "0mi5f8yx2dzsh1gksmhp61vndm999d20j7aby0sgg8cfva7wryc0";
  };

  gomemcached = buildFromGitHub {
    version = 2;
    rev = "9705ad8d185ee1c55130f94024676ac490007ba7";
    date = "2016-09-29";
    owner = "couchbase";
    repo = "gomemcached";
    sha256 = "1spjd321fms46fjrkxvyfc96hshhc66r04k6d8gr6fc970rr7gqy";
    propagatedBuildInputs = [
      goutils_logging
    ];
  };

  google-cloud-go = buildFromGitHub {
    version = 2;
    date = "2016-11-08";
    rev = "3e689fc0095261d1da33d9ffd201a17843f550db";
    owner = "GoogleCloudPlatform";
    repo = "google-cloud-go";
    sha256 = "1bn1hpmxndimm60dq1in4izmk0c6ncgi21lk2ky9mxld3hlw1a3c";
    goPackagePath = "cloud.google.com/go";
    goPackageAliases = [
      "google.golang.org/cloud"
    ];
    propagatedBuildInputs = [
      net
      oauth2
      protobuf
      google-api-go-client
      grpc
    ];
    excludedPackages = "oauth2";
    meta.useUnstable = true;
  };

  google-cloud-go-for-go4 = buildFromGitHub {
    inherit (google-cloud-go) rev date owner repo sha256 version goPackagePath goPackageAliases meta;
    subPackages = [
      "storage"
    ];
    propagatedBuildInputs = [
      gax-go
      google-api-go-client
      grpc
      net
      oauth2
    ];
  };

  google-cloud-go-compute-metadata = buildFromGitHub {
    inherit (google-cloud-go) rev date owner repo sha256 version goPackagePath goPackageAliases meta;
    subPackages = [ "compute/metadata" "internal" ];
    buildInputs = [ net ];
  };

  gopcap = buildFromGitHub {
    version = 2;
    rev = "00e11033259acb75598ba416495bb708d864a010";
    date = "2015-07-28";
    owner = "akrennmair";
    repo = "gopcap";
    sha256 = "189skp51bd7aqpqs63z20xqm0pj5dra23g51m993rbq81zsvp0yq";
    buildInputs = [
      pkgs.libpcap
    ];
  };

  goredis = buildFromGitHub {
    version = 1;
    rev = "760763f78400635ed7b9b115511b8ed06035e908";
    date = "2015-03-24";
    owner = "siddontang";
    repo = "goredis";
    sha256 = "193n28jaj01q0k8lx2ijvgzmlh926jy6cg2ph3446k90pl5r118c";
  };

  goreq = buildFromGitHub {
    version = 1;
    rev = "fc08df6ca2d4a0d1a5ae24739aa268863943e723";
    date = "2016-05-07";
    owner = "franela";
    repo = "goreq";
    sha256 = "152fmchwwwgyg16i79vl09cyid8ry3ddhj09nzx2xrfg5632sn7s";
  };

  goterm = buildFromGitHub {
    version = 2;
    rev = "cc3942e537b1ab00de92d348c40acbfa6565d20f";
    date = "2016-11-03";
    owner = "buger";
    repo = "goterm";
    sha256 = "0m7q1bccdjgijhrq056rs8brizrvsiyr8k0iphprs8wmlr0hz5vi";
  };

  goutils = buildFromGitHub {
    version = 1;
    rev = "5823a0cbaaa9008406021dc5daf80125ea30bba6";
    date = "2016-03-10";
    owner = "couchbase";
    repo = "goutils";
    sha256 = "0053nk5jhn3lcwb8sg2bv39gy841ldgcl3cnvwn5mmx3658il0kn";
    buildInputs = [
      cbauth
      go-couchbase
      gomemcached
    ];
  };

  goutils_logging = buildFromGitHub {
    inherit (goutils) rev date owner repo sha256 version;
    subPackages = [
      "logging"
    ];
  };

  golang-lru = buildFromGitHub {
    version = 1;
    date = "2016-08-13";
    rev = "0a025b7e63adc15a622f29b0b2c4c3848243bbf6";
    owner  = "hashicorp";
    repo   = "golang-lru";
    sha256 = "1nq6q2l5ml3dljxm0ks4zivcci1yg2f2lmam9kvykkwm03m85qy1";
  };

  golang-petname = buildFromGitHub {
    version = 2;
    rev = "78823a505c80032a9c0adb9df42e582069475ac0";
    owner  = "dustinkirkland";
    repo   = "golang-petname";
    sha256 = "0508p3z7nwvvxnjv5j211sixmgjcrh7i4vkzvfqsy24rlfl4p9s6";
    date = "2016-09-20";
  };

  golang_protobuf_extensions = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "matttproud";
    repo   = "golang_protobuf_extensions";
    sha256 = "0r1sv4jw60rsxy5wlnr524daixzmj4n1m1nysv4vxmwiw9mbr6fm";
    buildInputs = [ protobuf ];
  };

  goleveldb = buildFromGitHub {
    version = 2;
    rev = "6b4daa5362b502898ddf367c5c11deb9e7a5c727";
    date = "2016-10-11";
    owner = "syndtr";
    repo = "goleveldb";
    sha256 = "0d54ykb9l45v4zn7k0aw8qayvnpazmdnrizqqkllyphahlppi8pz";
    propagatedBuildInputs = [ ginkgo gomega snappy ];
  };

  gomega = buildFromGitHub {
    version = 2;
    rev = "ff4bc6b6f9f5affa66635cd04d31d2a7ee21ffd6";
    owner  = "onsi";
    repo   = "gomega";
    sha256 = "1dk3kbba2qlcyxbpv3xdmddjnamrybhaz05hqcjkpi9q9x88hcb7";
    propagatedBuildInputs = [
      protobuf
      yaml_v2
    ];
    date = "2016-10-31";
  };

  google-api-go-client = buildFromGitHub {
    version = 2;
    rev = "6bc9e77383320b75dcd6810569b6d54b2e84019d";
    date = "2016-11-08";
    owner = "google";
    repo = "google-api-go-client";
    sha256 = "1r5f20vkk3arnbhvrpdqphkcwlvl51ni4wjxdxpsb2nnh7jz4w3w";
    goPackagePath = "google.golang.org/api";
    goPackageAliases = [
      "github.com/google/google-api-client"
    ];
    buildInputs = [
      genproto
      grpc
      net
      oauth2
    ];
  };

  gopass = buildFromGitHub {
    version = 2;
    date = "2016-10-03";
    rev = "f5387c492211eb133053880d23dfae62aa14123d";
    owner = "howeyc";
    repo = "gopass";
    sha256 = "0cjbnrbv0fa09jgvmwszs9cphk6vn31kcpysvxfsyfzg9bfiannf";
    propagatedBuildInputs = [
      crypto
    ];
  };

  gopsutil = buildFromGitHub {
    version = 1;
    rev = "v2.1";
    owner  = "shirou";
    repo   = "gopsutil";
    sha256 = "1bq3fpw0jpjnkla2krf9i612v8k4kyfm0g1z7maikrnxhfiza4lc";
  };

  goquery = buildFromGitHub {
    version = 2;
    rev = "v1.0.1";
    owner  = "PuerkitoBio";
    repo   = "goquery";
    sha256 = "1n0b037xxkdbzkihfi9rdbrb4rbf182gpgwmll1qlz3zhxmajnaq";
    propagatedBuildInputs = [
      cascadia
      net
    ];
  };

  goskiplist = buildFromGitHub {
    version = 1;
    rev = "2dfbae5fcf46374f166f8969cb07e167f1be6273";
    owner  = "ryszard";
    repo   = "goskiplist";
    sha256 = "1dr6n2w5ikdddq9c1fwqnc0m383p73h2hd04302cfgxqbnymabzq";
    date = "2015-03-12";
  };

  govalidator = buildFromGitHub {
    version = 2;
    rev = "7b3beb6df3c42abd3509abfc3bcacc0fbfb7c877";
    owner = "asaskevich";
    repo = "govalidator";
    sha256 = "0gn9fa7i7wfpb2wdvxbzv3a3fzals21x7hs0jszf9g0bp441s75z";
    date = "2016-10-01";
  };

  go-autorest = buildFromGitHub {
    version = 2;
    rev = "v7.2.2";
    owner  = "Azure";
    repo   = "go-autorest";
    sha256 = "1632kfmg873i58cx1fvjfx4lil2cywqq8v6lnqjln3ipwrhwkl6q";
    propagatedBuildInputs = [
      crypto
      jwt-go
    ];
  };

  go-base58 = buildFromGitHub {
    version = 1;
    rev = "1.0.0";
    owner  = "jbenet";
    repo   = "go-base58";
    sha256 = "0sbss2611iri3mclcz3k9b7kw2sqgwswg4yxzs02vjk3673dcbh2";
  };

  go-bindata-assetfs = buildFromGitHub {
    version = 1;
    rev = "9a6736ed45b44bf3835afeebb3034b57ed329f3e";
    owner   = "elazarl";
    repo    = "go-bindata-assetfs";
    sha256 = "1hm0sbnbqaw7f847i6ynwz6b92xv6v46lpwpbql9nv8w1kp1q9y5";
    date = "2016-08-22";
  };

  go-bits = buildFromGitHub {
    version = 2;
    owner = "dgryski";
    repo = "go-bits";
    date = "2016-06-01";
    rev = "2ad8d707cc05b1815ce6ff2543bb5e8d8f9298ef";
    sha256 = "d77d906fb806bb9bd9af7f54f0c3277d6b86d84015e198cb367f1d7788c8b938";
  };

  go-bitstream = buildFromGitHub {
    version = 2;
    owner = "dgryski";
    repo = "go-bitstream";
    date = "2016-07-01";
    rev = "7d46cd22db7004f0cceb6f7975824b560cf0e486";
    sha256 = "32a82d1220c6d2ec05cf2d6150ed8f2a3ce6c544f626cc7574acaa57e31bbd9c";
  };

  go-buffruneio = buildFromGitHub {
    version = 2;
    owner = "pelletier";
    repo = "go-buffruneio";
    date = "2016-01-24";
    rev = "df1e16fde7fc330a0ca68167c23bf7ed6ac31d6d";
    sha256 = "f70b9d9ee10b67102fb76c75935289cca6eda7c741b6517c25fa1a8b1dfd5198";
  };

  go-checkpoint = buildFromGitHub {
    version = 1;
    date = "2016-08-16";
    rev = "f8cfd20c53506d1eb3a55c2c43b84d009fab39bd";
    owner  = "hashicorp";
    repo   = "go-checkpoint";
    sha256 = "066rs0gbflz5jbfpvklc3vg5zs7l1fdfjrfy21y4c4j5vkm49gz5";
    buildInputs = [ go-cleanhttp ];
  };

  go-cleanhttp = buildFromGitHub {
    version = 1;
    date = "2016-04-07";
    rev = "ad28ea4487f05916463e2423a55166280e8254b5";
    owner = "hashicorp";
    repo = "go-cleanhttp";
    sha256 = "1knpnv6wg2fnnsk2h2bj4m003f7xsvwm58vnn9gc753mbr78vx00";
  };

  go-collectd = buildFromGitHub {
    version = 2;
    owner = "collectd";
    repo = "go-collectd";
    rev = "v0.3.0";
    sha256 = "0dzs6ia5y3dc6vcdqv7llgxj381jdpl17kbjgn0ncggshxly4zhf";
    goPackagePath = "collectd.org";
    buildInputs = [
      grpc
      net
      pkgs.collectd
      protobuf
    ];
    preBuild = ''
      export COLLECTD_SRC="$(pwd)/collectd-src"
      mkdir -pv "$COLLECTD_SRC"
      tar -vxjf '${pkgs.collectd.src}' -C "$COLLECTD_SRC"
      # Run configure to generate config.h
      pushd "$COLLECTD_SRC/${pkgs.collectd.name}"
        ./configure
      popd
      export CGO_CPPFLAGS="-I$COLLECTD_SRC/${pkgs.collectd.name}/src/daemon -I$COLLECTD_SRC/${pkgs.collectd.name}/src"
    '';
  };

  go-colorable = buildFromGitHub {
    version = 1;
    rev = "v0.0.6";
    owner  = "mattn";
    repo   = "go-colorable";
    sha256 = "08iwf0p0jyqcwk82vb9shqlhphhz94pdb395gpacz9r76fk5iqhq";
  };

  go-connections = buildFromGitHub {
    version = 1;
    rev = "v0.2.1";
    owner  = "docker";
    repo   = "go-connections";
    sha256 = "07rcj6rhps7jg9yywy5328zcqnxakqhbiv5vscsfjz3c021rzcgf";
    propagatedBuildInputs = [
      logrus
      net
      runc
    ];
  };

  go-couchbase = buildFromGitHub {
    version = 2;
    rev = "276a412947426396a0595c32b25984029fa64f04";
    owner  = "couchbase";
    repo   = "go-couchbase";
    sha256 = "1zb0bf50lzr4raln22zyjyfc4xvvj6dwpxv9z361hdys7y2x8a5p";
    date = "2016-10-17";
    goPackageAliases = [
      "github.com/couchbaselabs/go-couchbase"
    ];
    propagatedBuildInputs = [
      gomemcached
      goutils_logging
    ];
    excludedPackages = "\\(perf\\|example\\)";
  };

  go-crypto = buildFromGitHub {
    version = 2;
    rev = "93f5b35093ba15e0f86e412cc5c767d5c10c15fd";
    owner  = "keybase";
    repo   = "go-crypto";
    sha256 = "0gj7bvq1v452dgs5s8x276jizixq3gdgij12pfglriannn5ngq0d";
    date = "2016-10-04";
    propagatedBuildInputs = [
      ed25519
    ];
  };

  go-difflib = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "pmezard";
    repo   = "go-difflib";
    sha256 = "0zb1bmnd9kn0qbyn2b62r9apbkpj3752isgbpia9i3n9ix451cdb";
  };

  go-dockerclient = buildFromGitHub {
    version = 2;
    date = "2016-11-01";
    rev = "5cfde1d138cd2cdc13e4aa36af631beb19dcbe9c";
    owner = "fsouza";
    repo = "go-dockerclient";
    sha256 = "0fsvgxwfqf5pqxvn6im39629820zf6jj8i3gfg9r20j3pcnb5lny";
    propagatedBuildInputs = [
      docker_for_go-dockerclient
      go-cleanhttp
      mux
    ];
  };

  go-etcd = buildFromGitHub {
    version = 2;
    date = "2015-10-26";
    rev = "003851be7bb0694fe3cc457a49529a19388ee7cf";
    owner  = "coreos";
    repo   = "go-etcd";
    sha256 = "1cijiw77cy4z6p4zhagm0q7ydyn8kk24v1611arx6wmvzgi7lyc3";
    propagatedBuildInputs = [
      ugorji_go
    ];
  };

  go-flags = buildFromGitHub {
    version = 2;
    rev = "v1.1";
    owner  = "jessevdk";
    repo   = "go-flags";
    sha256 = "0bha0a59akal9apycvrv0wq4gdsfh5hz5439rb4arbny0kvb9529";
  };

  go-getter = buildFromGitHub {
    version = 2;
    rev = "2fbd997432e72fe36060c8f07ec1eaf98d098177";
    date = "2016-09-12";
    owner = "hashicorp";
    repo = "go-getter";
    sha256 = "0sp59zf5jqbhvk81n0blbz5ddz30173m3zx57m12sqizr9zvvis9";
    propagatedBuildInputs = [
      aws-sdk-go
      go-homedir
      go-netrc
    ];
  };

  go-git-ignore = buildFromGitHub {
    version = 1;
    rev = "228fcfa2a06e870a3ef238d54c45ea847f492a37";
    date = "2016-01-15";
    owner = "sabhiram";
    repo = "go-git-ignore";
    sha256 = "1a78b1as3xd2v3lawrb0y43bm3rmb452mysvzqk1309gw51lk4gx";
  };

  go-github = buildFromGitHub {
    version = 2;
    date = "2016-11-05";
    rev = "905f04725b7bcad81e475ce48474b87561ecc723";
    owner = "google";
    repo = "go-github";
    sha256 = "1j0gxv6vpff1k0riwrbrqlw2brl14mnvakmdfbnv8z9v9w3c9b00";
    buildInputs = [ oauth2 ];
    propagatedBuildInputs = [ go-querystring ];
  };

  go-homedir = buildFromGitHub {
    version = 1;
    date = "2016-06-21";
    rev = "756f7b183b7ab78acdbbee5c7f392838ed459dda";
    owner  = "mitchellh";
    repo   = "go-homedir";
    sha256 = "0lacs15dkbs9ag6mdq5xg4w72g7m8p4042f7z4lrnk3r36c53zjq";
  };

  go-homedir_minio = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "go-homedir";
    date = "2016-02-15";
    rev = "0b1069c753c94b3633cc06a1995252dbcc27c7a6";
    sha256 = "0e595179466b94fcf18515a1791319cbfdd60b3e12b06dfc2cc7778a79a201c7";
  };

  hailocab_go-hostpool = buildFromGitHub {
    version = 1;
    rev = "e80d13ce29ede4452c43dea11e79b9bc8a15b478";
    date = "2016-01-25";
    owner  = "hailocab";
    repo   = "go-hostpool";
    sha256 = "06ic8irabl0iwhmkyqq4wzq1d4pgp9vk1kmflgv1wd5d9q8qmkgf";
  };

  gohtml = buildFromGitHub {
    version = 1;
    owner = "yosssi";
    repo = "gohtml";
    rev = "ccf383eafddde21dfe37c6191343813822b30e6b";
    date = "2015-09-23";
    sha256 = "1ccniz4r354r2y4m2dz7ic9nywzi6jffnh44dy6icyqi64v9ydw7";
    propagatedBuildInputs = [
      net
    ];
  };

  go-humanize = buildFromGitHub {
    version = 2;
    rev = "bd88f87ad3a420f7bcf05e90566fd1ceb351fa7f";
    owner = "dustin";
    repo = "go-humanize";
    sha256 = "0j2dza7xz93ksmc67cc8qhfxn7wpqq4xdjdr2p9f2ilqyq31pavh";
    date = "2016-09-23";
  };

  go-i18n = buildFromGitHub {
    version = 2;
    rev = "v1.6.0";
    owner  = "nicksnyder";
    repo   = "go-i18n";
    sha256 = "1f86wxw3avwbjk3jam8p6bb2q39d43b19pjsrgg4lc82b98lsfsl";
    buildInputs = [
      yaml_v2
    ];
  };

  go-immutable-radix = buildFromGitHub {
    version = 1;
    date = "2016-06-08";
    rev = "afc5a0dbb18abdf82c277a7bc01533e81fa1d6b8";
    owner = "hashicorp";
    repo = "go-immutable-radix";
    sha256 = "1yyhag8vnr7vi4ak2rkd651k9h8221dpdsqpva95zvf9nycgzlsd";
    propagatedBuildInputs = [ golang-lru ];
  };

  go-ini = buildFromGitHub {
    version = 1;
    rev = "a98ad7ee00ec53921f08832bc06ecf7fd600e6a1";
    owner = "vaughan0";
    repo = "go-ini";
    sha256 = "07i40hj47z5m6wa5bzy7sc2na3hbwh84ridl40yfybgdlyrzdkf4";
    date = "2013-09-23";
  };

  go-ipfs-api = buildFromGitHub {
    version = 2;
    rev = "0ee867280b9b85f2fcd6a3aa324728fc775dae48";
    owner  = "ipfs";
    repo   = "go-ipfs-api";
    sha256 = "1r3d8dwf2d2p25zpf183s8syxli1yg39jr8mr0jdgpqrgkgm82kl";
    excludedPackages = "tests";
    propagatedBuildInputs = [
      go-multiaddr
      go-multiaddr-net
      go-multipart-files
      tar-utils
    ];
    meta.useUnstable = true;
    date = "2016-10-06";
  };

  go-isatty = buildFromGitHub {
    version = 1;
    rev = "66b8e73f3f5cda9f96b69efd03dd3d7fc4a5cdb8";
    owner  = "mattn";
    repo   = "go-isatty";
    sha256 = "0m60qis720b5jdfklxn2qg98ndrvdbs5ykcn7qdhbycfadv1syyf";
    date = "2016-08-06";
  };

  go-jmespath = buildFromGitHub {
    version = 1;
    rev = "bd40a432e4c76585ef6b72d3fd96fb9b6dc7b68d";
    owner = "jmespath";
    repo = "go-jmespath";
    sha256 = "1jiz511xlndrai7xkpvr045x7fsda030240gcwjc4yg4y36ck8cg";
    date = "2016-08-03";
  };

  go-jose = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner = "square";
    repo = "go-jose";
    sha256 = "b2dac3e4693bbf2ef11c8afd6aec838479acb789c1d156084776e68488bbd64e";
    goPackagePath = "gopkg.in/square/go-jose.v1";
    goPackageAliases = [
      "github.com/square/go-jose"
    ];
    buildInputs = [
      urfave_cli
      kingpin_v2
    ];
    meta.autoUpdate = false;
  };

  go-logging = buildFromGitHub {
    version = 2;
    owner = "op";
    repo = "go-logging";
    date = "2016-03-15";
    rev = "970db520ece77730c7e4724c61121037378659d9";
    sha256 = "8087016a076abb7ab630f22c6e2b0ae8ce310350aad9792123c7842b299f87a7";
  };

  go-lxc_v2 = buildFromGitHub {
    version = 2;
    rev = "ff4ce348af903a11127714c67c10efa50276e13a";
    owner  = "lxc";
    repo   = "go-lxc";
    sha256 = "14r5g45d3bjviy5d30iyxjra2i9dd1q6zw1a552mhb86gicyrh35";
    goPackagePath = "gopkg.in/lxc/go-lxc.v2";
    buildInputs = [
      pkgs.lxc
    ];
    date = "2016-11-05";
  };

  go-lz4 = buildFromGitHub {
    version = 2;
    rev = "7224d8d8f27ef618c0a95f1ae69dbb0488abc33a";
    owner  = "bkaradzic";
    repo   = "go-lz4";
    sha256 = "1hbbagvmq7kxrlwqkn0i4mz66i3n37ch7y6bm9yncnjgd97kldms";
    date = "2016-09-24";
  };

  go-md2man = buildFromGitHub {
    version = 2;
    owner = "cpuguy83";
    repo = "go-md2man";
    rev = "v1.0.6";
    sha256 = "1i67z76plrd7ygk66691bgarcx5kfkf1ryvcwdaa099hbliwbai8";
    propagatedBuildInputs = [
      blackfriday
    ];
  };

  go-memdb = buildFromGitHub {
    version = 1;
    date = "2016-03-01";
    rev = "98f52f52d7a476958fa9da671354d270c50661a7";
    owner = "hashicorp";
    repo = "go-memdb";
    sha256 = "07938b1ln4x7caflhgsvaw8kikh5xcddwrc6zj0hcmzmbpfpyxai";
    propagatedBuildInputs = [
      go-immutable-radix
    ];
  };

  rcrowley_go-metrics = buildFromGitHub {
    version = 2;
    rev = "ab2277b1c5d15c3cba104e9cbddbdfc622df5ad8";
    date = "2016-09-21";
    owner = "rcrowley";
    repo = "go-metrics";
    sha256 = "0y51jzdnvpl0iab7wqvbrkw6wnrygkfcikfwwh95pnik7m6rwlnx";
    propagatedBuildInputs = [ stathat ];
  };

  armon_go-metrics = buildFromGitHub {
    version = 2;
    date = "2016-11-04";
    rev = "97c69685293dce4c0a2d0b19535179bbc976e4d2";
    owner = "armon";
    repo = "go-metrics";
    sha256 = "075bz3ibx6i8mdlkvclnh035fpqrq6ymwcb7jj85ldr6fb7y08p3";
    propagatedBuildInputs = [
      circonus-gometrics
      datadog-go
      prometheus_client_golang
    ];
  };

  go-mssqldb = buildFromGitHub {
    version = 1;
    rev = "fbf0a491e5ec011522c8870da9b0553135e2f9da";
    owner = "denisenkom";
    repo = "go-mssqldb";
    sha256 = "0p0s7zggwgh5ryyc1f4r5p4g6k8iiskpmspvsr9r6r43x930jf57";
    date = "2016-08-14";
    buildInputs = [ crypto ];
  };

  go-multiaddr = buildFromGitHub {
    version = 2;
    rev = "b23eb95805e1a61ac0da8d019e9346376428f37f";
    date = "2016-10-21";
    owner  = "multiformats";
    repo   = "go-multiaddr";
    sha256 = "0silxnph1g8971mad978p712glxlaf1d56banpqlapnwn6vmim1d";
    goPackageAliases = [ "github.com/jbenet/go-multiaddr" ];
    propagatedBuildInputs = [
      go-multihash
    ];
  };

  go-multiaddr-net = buildFromGitHub {
    version = 2;
    rev = "4b637b03a2bb30b478bba717cafdfebbe8e1f9ae";
    owner  = "multiformats";
    repo   = "go-multiaddr-net";
    sha256 = "19kpc74jwnb44q15x2kz7vkkqav58ygfzs0kf8k6vzg3d1sdkcaq";
    date = "2016-10-14";
    goPackageAliases = [ "github.com/jbenet/go-multiaddr-net" ];
    propagatedBuildInputs = [
      go-multiaddr
      utp
    ];
  };

  go-multierror = buildFromGitHub {
    version = 2;
    date = "2016-11-06";
    rev = "8484912a3b9987857bac52e0c5fec2b95f419628";
    owner  = "hashicorp";
    repo   = "go-multierror";
    sha256 = "03if2rmn8h4dnsc2rk2fyj8b7p7m78gc9l4chyzfxx9pvv4911dj";
    propagatedBuildInputs = [ errwrap ];
  };

  go-multihash = buildFromGitHub {
    version = 2;
    rev = "3922c539dc610bb88fdbb2bcd1108802bcd7ea50";
    owner  = "multiformats";
    repo   = "go-multihash";
    sha256 = "0jbpmpm5ij64j6073c133dl4c0n3bh5m3rknyakclgd9qbb031vj";
    goPackageAliases = [ "github.com/jbenet/go-multihash" ];
    propagatedBuildInputs = [
      crypto
      go-base58
    ];
    date = "2016-11-10";
  };

  go-multipart-files = buildFromGitHub {
    version = 1;
    rev = "3be93d9f6b618f2b8564bfb1d22f1e744eabbae2";
    owner  = "whyrusleeping";
    repo   = "go-multipart-files";
    sha256 = "0fdzi6v6rshh172hzxf8v9qq3d36nw3gc7g7d79wj88pinnqf5by";
    date = "2015-09-03";
  };

  go-nat-pmp = buildFromGitHub {
    version = 1;
    rev = "452c97607362b2ab5a7839b8d1704f0396b640ca";
    owner  = "AudriusButkevicius";
    repo   = "go-nat-pmp";
    sha256 = "0jjwqvanxxs15nhnkdx0mybxnyqm37bbg6yy0jr80czv623rp2bk";
    date = "2016-05-22";
    buildInputs = [
      gateway
    ];
  };

  go-netrc = buildFromGitHub {
    version = 2;
    owner = "bgentry";
    repo = "go-netrc";
    date = "2014-05-22";
    rev = "9fd32a8b3d3d3f9d43c341bfe098430e07609480";
    sha256 = "68984543a73f4d7ad4b58708207a483bd74fc9388ac582eac532434b11361a9e";
  };

  go-oidc = buildFromGitHub {
    version = 2;
    date = "2016-09-25";
    rev = "16c5ecc505f1efa0fe4685826fd9962c4d137e87";
    owner  = "coreos";
    repo   = "go-oidc";
    sha256 = "0cxaf9wnk86n4i0dpgxwj6pfalsrr3y6xmc5lvpy3qgfabj8869s";
    propagatedBuildInputs = [
      clockwork
      pkg
    ];
  };

  go-os-rename = buildFromGitHub {
    version = 1;
    rev = "3ac97f61ef67a6b87b95c1282f6c317ed0e693c2";
    owner  = "jbenet";
    repo   = "go-os-rename";
    sha256 = "0y8rq0y654lcyl7ysijni75j8fpq4hhqnh9qiy2z4hvmnzvb85id";
    date = "2015-04-28";
  };

  go-ovh = buildFromGitHub {
    version = 2;
    rev = "d6763cca4824319e17e556858e4517b151de4558";
    owner = "ovh";
    repo = "go-ovh";
    sha256 = "0rbzh5vlmfllwmdbf6clg9nvsaybdk7cnvvc1f3rgs8dwbk3lypy";
    date = "2016-09-11";
    propagatedBuildInputs = [
      ini_v1
    ];
  };

  go-plugin = buildFromGitHub {
    version = 1;
    rev = "8cf118f7a2f0c7ef1c82f66d4f6ac77c7e27dc12";
    date = "2016-06-07";
    owner  = "hashicorp";
    repo   = "go-plugin";
    sha256 = "1mgj52aml4l2zh101ksjxllaibd5r8h1gcgcilmb8p0c3xwf7lvq";
    buildInputs = [ yamux ];
  };

  go-ps = buildFromGitHub {
    version = 1;
    rev = "e2d21980687ce16e58469d98dcee92d27fbbd7fb";
    date = "2016-08-22";
    owner  = "mitchellh";
    repo   = "go-ps";
    sha256 = "0b7rlp5ic60d4a9ibchxxb6i2lc4ish9nwwxr0p57wmlbjbq3lbf";
  };

  go-python = buildFromGitHub {
    version = 2;
    owner = "sbinet";
    repo = "go-python";
    date = "2016-08-09";
    rev = "ac4579f132fff506b2f6b3eda4c9282b4be59a08";
    sha256 = "034c9b58c1ef250eff9a46c9ac743014df110f11fa8f580033767907bfbe2750";
    nativeBuildInputs = [
      pkgs.pkgconfig
    ];
    buildInputs = [
      pkgs.python2Packages.python
    ];
  };

  go-querystring = buildFromGitHub {
    version = 1;
    date = "2016-03-10";
    rev = "9235644dd9e52eeae6fa48efd539fdc351a0af53";
    owner  = "google";
    repo   = "go-querystring";
    sha256 = "0c0rmm98vz7sk7z6a1r07dp6jyb513cyr2y753sjpnyrc28xhdwg";
  };

  go-radix = buildFromGitHub {
    version = 1;
    rev = "4239b77079c7b5d1243b7b4736304ce8ddb6f0f2";
    owner  = "armon";
    repo   = "go-radix";
    sha256 = "0b5vksrw462w1j5ipsw7fmswhpnwsnaqgp6klw714dc6ppz57aqv";
    date = "2016-01-15";
  };

  go-reap = buildFromGitHub {
    version = 2;
    rev = "04ce4d0638f3b39b8a8030e2a22c4c90771fa5d6";
    owner  = "hashicorp";
    repo   = "go-reap";
    sha256 = "023ca78dmnwzd0g0yvrbznznmdjix36cang5wp7x054ihws8igd6";
    date = "2016-09-01";
    propagatedBuildInputs = [ sys ];
  };

  go-retryablehttp = buildFromGitHub {
    version = 2;
    rev = "6e85be8fee1dcaa02c0eaaac2df5a8fbecf94145";
    owner = "hashicorp";
    repo = "go-retryablehttp";
    sha256 = "1fssinl8qxdmg3b6wvbyd44p473fbkb03wi792bhqaq15jmysqqy";
    date = "2016-09-29";
    propagatedBuildInputs = [
      go-cleanhttp
    ];
  };

  go-rootcerts = buildFromGitHub {
    version = 1;
    rev = "6bb64b370b90e7ef1fa532be9e591a81c3493e00";
    owner = "hashicorp";
    repo = "go-rootcerts";
    sha256 = "0wi9ar5av0s4a2xarxh360kml3nkicrcdzzmhq1d406p10c3qjp2";
    date = "2016-05-03";
  };

  go-runewidth = buildFromGitHub {
    version = 2;
    rev = "737072b4e32b7a5018b4a7125da8d12de90e8045";
    owner = "mattn";
    repo = "go-runewidth";
    sha256 = "15p7kn0wccmd3ynndhxqp536lzmb4ckc48gld16xmhhl00sy3x0a";
    date = "2016-10-12";
  };

  go-semver = buildFromGitHub {
    version = 2;
    rev = "v0.2.0";
    owner  = "coreos";
    repo   = "go-semver";
    sha256 = "0fmah32srkcsrz14mxkx2drry0kcrykhr1ks78qmh98i91nmkpbw";
  };

  go-shellwords = buildFromGitHub {
    version = 2;
    rev = "525bedee691b5a8df547cb5cf9f86b7fb1883e24";
    owner  = "mattn";
    repo   = "go-shellwords";
    sha256 = "0ch7f3128mac8ymfh15p2nrsis5472h9yr6dzwmmc6dbcslpvfk1";
    date = "2016-03-15";
  };

  go-simplejson = buildFromGitHub {
    version = 1;
    rev = "v0.5.0";
    owner  = "bitly";
    repo   = "go-simplejson";
    sha256 = "09svnkziaffkbax5jjnjfd0qqk9cpai2gphx4ja78vhxdn4jpiw0";
  };

  go-snappy = buildFromGitHub {
    version = 1;
    rev = "d8f7bb82a96d89c1254e5a6c967134e1433c9ee2";
    owner  = "siddontang";
    repo   = "go-snappy";
    sha256 = "18ikmwl43nqdphvni8z15jzhvqksqfbk8rspwd11zy24lmklci7b";
    date = "2014-07-04";
  };

  go-spew = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "davecgh";
    repo   = "go-spew";
    sha256 = "0xsyd00l10gsvj3yiks8f2dv21svi7nj9viich2l1wlqgq30vizi";
  };

  go-sqlite3 = buildFromGitHub {
    version = 2;
    rev = "v1.2.0";
    owner  = "mattn";
    repo   = "go-sqlite3";
    sha256 = "0s6s46achp1dczxcp9fw3n71wkhw8y5x5kd8izyllygrbs56h28c";
    excludedPackages = "test";
    buildInputs = [
      goquery
    ];
    propagatedBuildInputs = [
      net
    ];
  };

  go-syslog = buildFromGitHub {
    version = 1;
    date = "2016-08-13";
    rev = "315de0c1920b18b942603ffdc2229e2af4803c17";
    owner  = "hashicorp";
    repo   = "go-syslog";
    sha256 = "148lnmjaawk0g7006294x5jjp00q1c9cyqi7nmlsk8hmn8gcrnpa";
  };

  go-systemd = buildFromGitHub {
    version = 2;
    rev = "d7387fdbe0249794c5bdcfa53b964aa5517e81a9";
    owner = "coreos";
    repo = "go-systemd";
    sha256 = "1q8cip4h90gmvm1bvgwklq6xb59yybf3blxi9fd4jfsjzqb7zssg";
    propagatedBuildInputs = [
      dbus
      pkg
      pkgs.systemd_lib
    ];
    date = "2016-11-09";
  };

  go-systemd_journal = buildFromGitHub {
    inherit (go-systemd) rev owner repo sha256 version date;
    subPackages = [
      "journal"
    ];
  };

  go-toml = buildFromGitHub {
    version = 2;
    owner = "pelletier";
    repo = "go-toml";
    rev = "v0.3.5";
    sha256 = "5e44b9b7ed958afc8c1c8d85247cbd82f0969d6cecbffd0207ea5e5e64d9c0c7";
    propagatedBuildInputs = [
      go-buffruneio
    ];
  };

  go-units = buildFromGitHub {
    version = 1;
    rev = "v0.3.1";
    owner = "docker";
    repo = "go-units";
    sha256 = "16qsnzrhdnr8p650558p7ml4v0lkxhfign2jkz6nsdx6s4q2gpnc";
  };

  hashicorp-go-uuid = buildFromGitHub {
    version = 1;
    rev = "64130c7a86d732268a38cb04cfbaf0cc987fda98";
    date = "2016-07-16";
    owner  = "hashicorp";
    repo   = "go-uuid";
    sha256 = "072c84wn90di09qxrg0ml8vjfb5k10zk2n4k0rgxk1n45wyghkjx";
  };

  go-version = buildFromGitHub {
    version = 2;
    rev = "e96d3840402619007766590ecea8dd7af1292276";
    owner  = "hashicorp";
    repo   = "go-version";
    sha256 = "13jrvfmg7vx1zzsjbwyfaxh06y8si7f9drcpy0400pv9fv9fxfs7";
    date = "2016-10-31";
  };

  go-zookeeper = buildFromGitHub {
    version = 2;
    rev = "1d7be4effb13d2d908342d349d71a284a7542693";
    date = "2016-10-28";
    owner  = "samuel";
    repo   = "go-zookeeper";
    sha256 = "15jwlcscvqpj6yfsjmi7735q45zn5pv1h0by3dzggfry6y0h44fs";
  };

  gorequest = buildFromGitHub {
    version = 2;
    owner = "parnurzeal";
    repo = "gorequest";
    rev = "v0.2.14";
    sha256 = "4a32bc0da7c70933937f20fa0cccd9b47c8fd583155b937b2ab8349998193ad1";
    propagatedBuildInputs = [
      http2curl
      net
    ];
  };

  grafana = buildFromGitHub {
    version = 1;
    owner = "grafana";
    repo = "grafana";
    rev = "v3.1.1";
    sha256 = "0lnd5226d57iir2ffff8d13fyp4h3hczl1and57fd02q3xaqdybj";
    buildInputs = [
      amqp
      aws-sdk-go
      binding
      urfave_cli
      color
      goreq
      go-spew
      go-sqlite3
      go-version
      gzip
      inject
      ini_v1
      ldap
      log15
      macaron_v1
      net
      oauth2
      session
      slug
      toml
      websocket
      xorm
    ];
  };

  graphite-golang = buildFromGitHub {
    version = 2;
    owner = "marpaia";
    repo = "graphite-golang";
    date = "2016-09-01";
    rev = "c98f562aa632f89588e321a4f6013c3ae57aa48c";
    sha256 = "a91e293445a5de759ee3906f641ae4278e5c35196a2f88f844624f23a8278df4";
  };

  groupcache = buildFromGitHub {
    version = 1;
    date = "2016-08-03";
    rev = "a6b377e3400b08991b80d6805d627f347f983866";
    owner  = "golang";
    repo   = "groupcache";
    sha256 = "08i7y7glb6j8bd7f1y940qaagry2mwfyqm9y6w2ki7awadl87zrs";
    buildInputs = [ protobuf ];
  };

  grpc = buildFromGitHub {
    version = 2;
    rev = "e59af7a0a8bf571556b40c3f871dbc4298f77693";
    owner = "grpc";
    repo = "grpc-go";
    sha256 = "1gc1k08ws8r51j384yzan6scs15lb52kh87kmn7zz03cwa3i40gm";
    goPackagePath = "google.golang.org/grpc";
    goPackageAliases = [ "github.com/grpc/grpc-go" ];
    propagatedBuildInputs = [ http2 net protobuf oauth2 glog ];
    excludedPackages = "\\(test\\|benchmark\\)";
    meta.useUnstable = true;
    date = "2016-11-10";
  };

  grpc-gateway = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner = "grpc-ecosystem";
    repo = "grpc-gateway";
    sha256 = "1yrfg4pn053hv86aal8cr285cdnk20n7dzvvji9zsm9pp25d6jj3";
    propagatedBuildInputs = [
      glog
      grpc
      net
      protobuf
    ];
  };


  gucumber = buildFromGitHub {
    version = 1;
    date = "2016-07-14";
    rev = "71608e2f6e76fd4da5b09a376aeec7a5c0b5edbc";
    owner = "gucumber";
    repo = "gucumber";
    sha256 = "0ghz0x1zdm1ypp9ycw871r2rcklik84z7pqgs2i88sk2s4m4igar";
    buildInputs = [ testify ];
    propagatedBuildInputs = [ ansicolor ];
  };

  gx = buildFromGitHub {
    version = 2;
    rev = "v0.10.0";
    owner = "whyrusleeping";
    repo = "gx";
    sha256 = "0kyx29qiijanbd3zrx239r1knzy5iglaj0gvsmy4d0kw7ai5isc4";
    propagatedBuildInputs = [
      go-git-ignore
      go-homedir
      go-multiaddr
      go-multihash
      go-multiaddr-net
      go-os-rename
      json-filter
      semver
      stump
      urfave_cli
      go-ipfs-api
    ];
    excludedPackages = [
      "tests"
    ];
  };

  gx-go = buildFromGitHub {
    version = 2;
    rev = "v1.4.0";
    owner = "whyrusleeping";
    repo = "gx-go";
    sha256 = "08yl5kvmxb2q21sxlnd8qn79bv3dp1v5jfpli7n32wqahix3rnzi";
    buildInputs = [
      urfave_cli
      fs
      gx
      stump
    ];
  };

  gzip = buildFromGitHub {
    version = 1;
    date = "2016-02-21";
    rev = "cad1c6580a07c56f5f6bc52d66002a05985c5854";
    owner = "go-macaron";
    repo = "gzip";
    sha256 = "1myrzvymwxxck5xw9jbm1fp9aazhvqdp2sc2snymvnnlxwc8f0an";
    propagatedBuildInputs = [
      compress
      macaron_v1
    ];
  };

  gziphandler = buildFromGitHub {
    version = 2;
    date = "2016-10-24";
    rev = "172fbbbb329cf7e031dd3ab35766186fc2081eab";
    owner = "NYTimes";
    repo = "gziphandler";
    sha256 = "1wd0n5qdprdjzpan5k22s3301vsbm28ri1m8x8dcs1b9f3z5cfxw";
  };

  handlers = buildFromGitHub {
    version = 2;
    owner = "gorilla";
    repo = "handlers";
    rev = "e1b2144f2167de0e1042d1d35e5cba5119d4fb5d";
    sha256 = "0bbkmrnmbdifyq3ykx68v79p9lw6h2djwcsc48mzci476m4bnm1q";
    date = "2016-10-28";
  };

  hashstructure = buildFromGitHub {
    version = 1;
    date = "2016-06-09";
    rev = "b098c52ef6beab8cd82bc4a32422cf54b890e8fa";
    owner  = "mitchellh";
    repo   = "hashstructure";
    sha256 = "0zg0q20hzg92xxsfsf2vn1kq044j8l7dh82fm7w7iyv03nwq0cxc";
  };

  hcl = buildFromGitHub {
    version = 2;
    date = "2016-11-09";
    rev = "3d702911d9708e8fea66cd77e04bd451ff25d3b1";
    owner  = "hashicorp";
    repo   = "hcl";
    sha256 = "07ysk1dysv0gnm4mhnd8zwkzkqkx627vwws4l35llf80jwp9zmys";
  };

  hdrhistogram = buildFromGitHub {
    version = 2;
    date = "2016-10-09";
    rev = "3a0bb77429bd3a61596f5e8a3172445844342120";
    owner  = "codahale";
    repo   = "hdrhistogram";
    sha256 = "0xnsf0yzh4z1iyl0vcbj97cyl19zq37hvjfz533zq91xglgpghmc";
    propagatedBuildInputs = [
      mgo_v2
    ];
  };

  hil = buildFromGitHub {
    version = 2;
    date = "2016-10-31";
    rev = "48cf0fb0fcbb98fcc57ddbae8e235b9f528b9602";
    owner  = "hashicorp";
    repo   = "hil";
    sha256 = "1c94fg76ld2c1v2famvnmflg0bbrac02mvn4mh1l69hv0msr6j15";
    propagatedBuildInputs = [
      mapstructure
      reflectwalk
    ];
    meta.useUnstable = true;
  };

  hllpp = buildFromGitHub {
    version = 2;
    owner = "retailnext";
    repo = "hllpp";
    date = "2015-03-19";
    rev = "38a7bb71b483e855d35010808143beaf05b67f9d";
    sha256 = "3a98569b08ed14b834fb91c7da0827c74ddec9d1c057356c9d9999440bd45157";
  };

  hotp = buildFromGitHub {
    version = 2;
    rev = "c180d57d286b385101c999a60087a40d7f48fc77";
    owner  = "gokyle";
    repo   = "hotp";
    sha256 = "1sv6fq7nw7crnqn7ycg3f5j3x4g0rahxynjprwh8md3cfj1161xr";
    date = "2016-02-17";
    propagatedBuildInputs = [
      rsc
    ];
  };

  http2 = buildFromGitHub {
    version = 1;
    rev = "aa7658c0e9902e929a9ed0996ef949e59fc0f3ab";
    owner = "bradfitz";
    repo = "http2";
    sha256 = "10x76xl5b6z2w0mbq7lnx7sl3cbdsp6gc1n3bis9lc0ilclzml65";
    buildInputs = [
      crypto
    ];
    date = "2016-01-16";
  };

  http2curl = buildFromGitHub {
    version = 2;
    owner = "moul";
    repo = "http2curl";
    date = "2016-10-31";
    rev = "4e24498b31dba4683efb9d35c1c8a91e2eda28c8";
    sha256 = "1zzdplidhh77s20l6c51fqvrzppmkf830j7mxdv9lf7z5ry169sp";
  };

  httprouter = buildFromGitHub {
    version = 2;
    rev = "4563b0ba73e4db6c6423b60a26f3cadd2e9a1ec9";
    owner  = "julienschmidt";
    repo   = "httprouter";
    sha256 = "0p18bmw98m74c7ma2ayj0xgx6mw03xmxylhmi2jr99h26inpjq6l";
    date = "2016-10-23";
  };

  hugo = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "hugo";
    rev = "v0.17";
    sha256 = "025l734hc57vhxfnsrq6amr7yx3cls2p3sibgr3vmz81chmk2zky";
    buildInputs = [
      ace
      afero
      amber
      blackfriday
      cast
      cobra
      cssmin
      emoji
      go-i18n
      fsnotify
      fsync
      inflect
      jwalterweatherman
      mapstructure
      mmark
      nitro
      osext
      pflag
      purell
      text
      toml
      viper
      websocket
      yaml_v2
    ];
  };

  inf_v0 = buildFromGitHub {
    version = 1;
    rev = "v0.9.0";
    owner  = "go-inf";
    repo   = "inf";
    sha256 = "0wqf867vifpfa81a1vhazjgfjjhiykqpnkblaxxj6ppyxlzrs3cp";
    goPackagePath = "gopkg.in/inf.v0";
  };

  inflect = buildFromGitHub {
    version = 1;
    owner = "bep";
    repo = "inflect";
    rev = "b896c45f5af983b1f416bdf3bb89c4f1f0926f69";
    date = "2016-04-08";
    sha256 = "13mjcnh6g7ml0gw24rbkfdjmkznjk4hcwfbxcbj5ydyfl0acq8wn";
  };

  influxdb = buildFromGitHub {
    version = 2;
    owner = "influxdata";
    repo = "influxdb";
    rev = "v1.0.2";
    sha256 = "0rs5nnlkxxaw5vhny84pr5gvywinar2bdx744n1ar1zvcc3jmzdy";
    propagatedBuildInputs = [
      bolt
      gollectd
      crypto
      encoding
      go-bits
      go-bitstream
      go-collectd
      hllpp
      jwt-go_v2
      liner
      pat
      pool_v2
      gogo_protobuf
      ratecounter
      snappy
      statik
      toml
      usage-client
    ];
    goPackageAliases = [
      "github.com/influxdb/influxdb"
    ];
    postPatch = /* Remove broken tests */ ''
      rm -rf services/collectd/test_client
    '';
  };

  influxdb_client = buildFromGitHub {
    inherit (influxdb) owner repo rev sha256 version;
    goPackageAliases = [
      "github.com/influxdb/influxdb"
    ];
    subPackages = [
      "client"
      "models"
      "pkg/escape"
    ];
  };

  ini = buildFromGitHub {
    version = 2;
    rev = "v1.21.1";
    owner  = "go-ini";
    repo   = "ini";
    sha256 = "1icbs1ma8vinzq2bbgqjvq4kdca01q0mk5jcd0qj8zjx8pfbz444";
  };

  ini_v1 = buildFromGitHub {
    version = 2;
    rev = "v1.21.1";
    owner  = "go-ini";
    repo   = "ini";
    goPackagePath = "gopkg.in/ini.v1";
    sha256 = "12f6iyy6gdysi94vl84k3wk7jmccmw1j75ljmbmysglxakdm2n6h";
  };

  inject = buildFromGitHub {
    version = 1;
    date = "2016-06-28";
    rev = "d8a0b8677191f4380287cfebd08e462217bac7ad";
    owner = "go-macaron";
    repo = "inject";
    sha256 = "1zb5sw83grna85cgsz7nhwpbkkysnyfc6hzk7gksidf08s8s9dmg";
  };

  internal = buildFromGitHub {
    version = 1;
    rev = "fbe290d56cdd8bb25347df893b14e3454f07bf74";
    owner  = "cznic";
    repo   = "internal";
    sha256 = "0x80s83nq75xajyqspzcgj2mq5gxw9psxghvb676q8y96jn1n10k";
    date = "2016-07-19";
    buildInputs = [
      fileutil
      mathutil
      mmap-go
    ];
  };

  iter = buildFromGitHub {
    version = 1;
    rev = "454541ec3da2a73fc34fd049b19ee5777bf19345";
    owner  = "bradfitz";
    repo   = "iter";
    sha256 = "0sv6rwr05v219j5vbwamfvpp1dcavci0nwr3a2fgxx98pjw7hgry";
    date = "2014-01-23";
  };

  ipfs = buildFromGitHub {
    version = 2;
    date = "2016-11-10";
    rev = "4442498d926a25b4084affe70d15d7c8dcf9a6f8";
    owner = "ipfs";
    repo = "go-ipfs";
    sha256 = "0zs43397m5hdii0f68fsb8plx4519yfaqw0g53ji5w18kd5gvj25";
    gxSha256 = "1g9z9f4v9ca1lv90ibzfxj6in34ijbxdgj0x6s1xrfx346jncyxl";
    subPackages = [
      "cmd/ipfs"
      "cmd/ipfswatch"
    ];
    nativeBuildInputs = [
      gx-go.bin
    ];
    # Prevent our Godeps remover from work here
    preConfigure = ''
      mv Godeps "$TMPDIR"
    '';
    postConfigure = ''
      mv "$TMPDIR/Godeps" "go/src/$goPackagePath"
    '';
    meta.useUnstable = true;
  };

  json-filter = buildFromGitHub {
    version = 1;
    owner = "whyrusleeping";
    repo = "json-filter";
    rev = "ff25329a9528f01c5175414f16cc0a6a162a5b8b";
    date = "2016-06-15";
    sha256 = "0y1d6yi09ac0xlf63qrzxsi7dqf10wha3na633qzqjnpjcga97ck";
  };

  jsonx = buildFromGitHub {
    version = 2;
    owner = "jefferai";
    repo = "jsonx";
    rev = "9cc31c3135eef39b8e72585f37efa92b6ca314d0";
    date = "2016-07-21";
    sha256 = "0s5zani868a70hpacqxl1qzzwc8hdappb99qixmbfkf7wdyyzfic";
    propagatedBuildInputs = [
      gabs
    ];
  };

  jwalterweatherman = buildFromGitHub {
    version = 1;
    owner = "spf13";
    repo = "jWalterWeatherman";
    rev = "33c24e77fb80341fe7130ee7c594256ff08ccc46";
    date = "2016-03-01";
    sha256 = "0w6risn5iwx9b0sn0f6z2yfs3p1gqa22asy3hkix1p81a1xmsidc";
    goPackageAliases = [
      "github.com/spf13/jwalterweatherman"
    ];
  };

  jwt-go = buildFromGitHub {
    version = 2;
    owner = "dgrijalva";
    repo = "jwt-go";
    rev = "v3.0.0";
    sha256 = "0llmcxijl24gz6w75il6rnijc9gzda4byl5kwr4qnzpw9j0q87n9";
  };

  jwt-go_v2 = buildFromGitHub {
    version = 2;
    owner = "dgrijalva";
    repo = "jwt-go";
    rev = "v2.7.0";
    sha256 = "bee3aac16ad7dfcf79cac6442ae4ef300698b0b3125026d34c36cd46b27060e6";
    meta.autoUpdate = false;
  };

  gravitational_kingpin = buildFromGitHub {
    version = 2;
    rev = "785686550a08e8e2e77641c91714280a6dfb08ee";
    owner = "gravitational";
    repo = "kingpin";
    sha256 = "0klg0nixdy13r50xkfh7mlhdyfk0x7ymmb1m4l29zj00zmhy07if";
    propagatedBuildInputs = [
      template
      units
    ];
    meta.useUnstable = true;
    date = "2016-02-05";
  };

  kingpin_v2 = buildFromGitHub {
    version = 2;
    rev = "v2.2.3";
    owner = "alecthomas";
    repo = "kingpin";
    sha256 = "196087z4473psagd0n0wss12knqabcbh4iyikwcbiiw3hx4lx0ix";
    goPackagePath = "gopkg.in/alecthomas/kingpin.v2";
    propagatedBuildInputs = [
      template
      units
    ];
  };

  ldap = buildFromGitHub {
    version = 1;
    rev = "v2.4.1";
    owner  = "go-ldap";
    repo   = "ldap";
    sha256 = "1vgjhz2rhyfyvpmp7mgya3znivdi8z5s156nj99329yif1q6dg7j";
    goPackageAliases = [
      "github.com/nmcclain/ldap"
      "github.com/vanackere/ldap"
    ];
    propagatedBuildInputs = [ asn1-ber ];
  };

  ledisdb = buildFromGitHub {
    version = 1;
    rev = "2f7cbc730a2e48ba2bc30ec69da86503fc40acc7";
    owner  = "siddontang";
    repo   = "ledisdb";
    sha256 = "0lp895xlbldw8g2bx8rr3sx7mmd8h35mikm0xpm1r8nz8w6qhz9d";
    date = "2016-07-25";
    prePatch = ''
      dirs=($(find . -type d -name vendor | sort))
      echo "''${dirs[@]}" | xargs -n 1 rm -r
    '';
    propagatedBuildInputs = [
      siddontang_go
      ugorji_go
      goleveldb
      goredis
      liner
      mmap-go
      siddontang_rdb
      toml
    ];
  };

  lego = buildFromGitHub {
    version = 2;
    rev = "2abbe6d836b6b4c5659a672c8a5b7cab5dd0c4dd";
    owner = "xenolf";
    repo = "lego";
    sha256 = "1v8al85ia0m28spw6fd4vj1p03mn7sc25sdimwxararqc11xrvns";

    buildInputs = [
      auroradnsclient
      aws-sdk-go
      azure-sdk-for-go
      urfave_cli
      crypto
      dns
      weppos-dnsimple-go
      go-autorest
      go-ini
      go-jose
      go-ovh
      goamz
      google-api-go-client
      linode
      memcache
      ns1-go_v2
      oauth2
      net
      vultr
    ];

    subPackages = [
      "."
    ];
    date = "2016-11-10";
  };

  lemma = buildFromGitHub {
    version = 2;
    rev = "cbfbc8381e93147bc50db64509634327d0f6d626";
    owner = "mailgun";
    repo = "lemma";
    sha256 = "1rqg0fw94vavi6a9c0cgc0xg9gy6p25ps2p9bs65flda60cm59ph";
    date = "2016-09-01";
    propagatedBuildInputs = [
      crypto
      metrics
      timetools
      mailgun_ttlmap
    ];
  };

  liner = buildFromGitHub {
    version = 2;
    rev = "3c5f577f62ec95a012ea48a58dd4de3c48222a35";
    owner = "peterh";
    repo = "liner";
    sha256 = "1fwsa02az6y6mhybadqb3rxb7fxf5p5n381xgqrx5yz134mpd5vb";
    date = "2016-11-03";
  };

  linode = buildFromGitHub {
    version = 2;
    rev = "37e84520dcf74488f67654f9c775b9752c232dc1";
    owner = "timewasted";
    repo = "linode";
    sha256 = "13ypkib9nmm8pc2z8yqa97gh3karvrhwas0i4ck88pqhxwi85liw";
    date = "2016-08-29";
  };

  lldb = buildFromGitHub {
    version = 2;
    rev = "v1.0.5";
    owner  = "cznic";
    repo   = "lldb";
    sha256 = "167s53xghxy7xlxbpf4r48h7rz6yygaq4fqk1h5m5hhivh6vazsq";
    buildInputs = [
      fileutil
      mathutil
      sortutil
    ];
    propagatedBuildInputs = [
      mmap-go
    ];
    extraSrcs = [
      {
        inherit (internal)
          goPackagePath
          src;
      }
      {
        inherit (zappy)
          goPackagePath
          src;
      }
    ];
  };

  log15 = buildFromGitHub {
    version = 2;
    rev = "46a701a619de90c65a78c04d1a58bf02585e9701";
    owner  = "inconshreveable";
    repo   = "log15";
    sha256 = "11fgndc0zjkm1zc1xzr7n1k3p6rkpfa0mykr2w2d995174idgvyi";
    propagatedBuildInputs = [
      go-colorable
      stack
    ];
    date = "2016-10-26";
  };

  log15_v2 = buildFromGitHub {
    version = 1;
    rev = "v2.11";
    owner  = "inconshreveable";
    repo   = "log15";
    sha256 = "1krlgq3m0q40y8bgaf9rk7zv0xxx5z92rq8babz1f3apbdrn00nq";
    goPackagePath = "gopkg.in/inconshreveable/log15.v2";
    propagatedBuildInputs = [
      go-colorable
      stack
    ];
  };

  lunny_log = buildFromGitHub {
    version = 2;
    rev = "7887c61bf0de75586961948b286be6f7d05d9f58";
    owner = "lunny";
    repo = "log";
    sha256 = "0jsk5yc7lqlh9zicadbhxh6as3vlhln08f2wxrbnpcw0b1jncnp1";
    date = "2016-09-21";
  };

  mailgun_log = buildFromGitHub {
    version = 2;
    rev = "2f35a4607f1abf71f97f77f99b0de8493ef6f4ef";
    owner = "mailgun";
    repo = "log";
    sha256 = "1akyw7r5as06b6inn16wh9gg16zx3729nxmrgg0c46sgy23xmh9m";
    date = "2015-09-25";
  };

  loghisto = buildFromGitHub {
    version = 2;
    rev = "9d1d8c1fd2a4ac852bf2e312f2379f553345fda7";
    owner = "spacejam";
    repo = "loghisto";
    sha256 = "0dpfgzlf4n0vvppffxk5qwdb72iq6x320srkd1rzys0fd7xyvyz1";
    date = "2016-03-02";
    propagatedBuildInputs = [
      glog
    ];
  };

  logrus = buildFromGitHub {
    version = 2;
    rev = "v0.11.0";
    owner = "Sirupsen";
    repo = "logrus";
    sha256 = "06kc8ss5nrshqkxjnz3b2rbzv4mwj0k9y1jrd29xxkqz0b86n605";
  };

  logutils = buildFromGitHub {
    version = 1;
    date = "2015-06-09";
    rev = "0dc08b1671f34c4250ce212759ebd880f743d883";
    owner  = "hashicorp";
    repo   = "logutils";
    sha256 = "11p4p01x37xcqzfncd0w151nb5izmf3sy77vdwy0dpwa9j8ccgmw";
  };

  logxi = buildFromGitHub {
    version = 2;
    date = "2016-10-27";
    rev = "aebf8a7d67ab4625e0fd4a665766fef9a709161b";
    owner  = "mgutz";
    repo   = "logxi";
    sha256 = "10rvbxihgkwbdbb6pc7pn4jhgjxmq7gvxc8r5hckfi7qmc3z0ahk";
    excludedPackages = "Gododir";
    propagatedBuildInputs = [
      ansi
      go-colorable
      go-isatty
    ];
  };

  luhn = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "calmh";
    repo   = "luhn";
    sha256 = "13brkbbmj9bh0b9j3avcyrj542d78l9hg3bxj7jjvkp5n5cxwp41";
  };

  lxd = buildFromGitHub {
    version = 2;
    rev = "lxd-2.5";
    owner  = "lxc";
    repo   = "lxd";
    sha256 = "1z6837qynb115i7cmsh23z3zsiyzq75pkqxwkw9n9dc99v33rymb";
    excludedPackages = "test"; # Don't build the binary called test which causes conflicts
    buildInputs = [
      crypto
      gettext
      gocapability
      golang-petname
      go-lxc_v2
      go-sqlite3
      go-systemd
      log15_v2
      pkgs.lxc
      mux
      pborman_uuid
      pongo2-v3
      protobuf
      tablewriter
      tomb_v2
      yaml_v2
      websocket
    ];
  };

  macaron_v1 = buildFromGitHub {
    version = 2;
    rev = "v1.1.8";
    owner  = "go-macaron";
    repo   = "macaron";
    sha256 = "0d3p3kpa14n2i9azm0mr80ar379whwbdzfxjyciz30zqklb3nxz6";
    goPackagePath = "gopkg.in/macaron.v1";
    goPackageAliases = [
      "github.com/go-macaron/macaron"
    ];
    propagatedBuildInputs = [
      com
      ini_v1
      inject
    ];
  };

  mapstructure = buildFromGitHub {
    version = 2;
    date = "2016-10-20";
    rev = "f3009df150dadf309fdee4a54ed65c124afad715";
    owner  = "mitchellh";
    repo   = "mapstructure";
    sha256 = "1bcyq49psjkmln9g6qh1rvfg69qdf0s3nqa6jrrcqw70f669j8g1";
  };

  match = buildFromGitHub {
    version = 2;
    owner = "tidwall";
    repo = "match";
    date = "2016-08-30";
    rev = "173748da739a410c5b0b813b956f89ff94730b4c";
    sha256 = "362da507bd9755044b3a1f9c0f048ec8758012ca55593b9a1dd63edd76e4e5f9";
  };

  mathutil = buildFromGitHub {
    version = 2;
    date = "2016-10-12";
    rev = "4609a45a9e61188d0d69a5d8ad42600c3df35002";
    owner = "cznic";
    repo = "mathutil";
    sha256 = "02kbxfgnbyvczrcig2cgjf3b1lnd0365cny94wrxfdrcfxblzn30";
    buildInputs = [ bigfft ];
  };

  maxminddb-golang = buildFromGitHub {
    version = 2;
    rev = "v1.0.0";
    owner  = "oschwald";
    repo   = "maxminddb-golang";
    sha256 = "0nwandjs965a9jx8ibki8c2caf7h4h9vy9i6z7c0lpb11lg1lzdm";
    propagatedBuildInputs = [
      sys
    ];
  };

  mc = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "mc";
    rev = "2895b0accaad4465128e4b950bf048494de36a9f";
    sha256 = "12360gjnxff0n4wrlh53j2ldcbrbyyp6q8wv5gv324jl913cj6i0";
    propagatedBuildInputs = [
      cli_minio
      color
      go-colorable
      go-homedir_minio
      go-humanize
      go-version
      minio_pkg
      minio-go
      notify
      pb
      profile
      structs
    ];
    date = "2016-11-09";
  };

  mdns = buildFromGitHub {
    version = 1;
    date = "2015-12-05";
    rev = "9d85cf22f9f8d53cb5c81c1b2749f438b2ee333f";
    owner = "hashicorp";
    repo = "mdns";
    sha256 = "0hsbhh0v0jpm4cg3hg2ffi2phis4vq95vyja81rk7kzvml17pvag";
    propagatedBuildInputs = [
      dns
      net
    ];
  };

  memberlist = buildFromGitHub {
    version = 2;
    date = "2016-11-09";
    rev = "d16b8b733eddcffb36008dcc425a3b0824034bbb";
    owner = "hashicorp";
    repo = "memberlist";
    sha256 = "182kb32nc3nqyplfx1bba2z8h0jx5sh6wi8dk56mxx8r12082lbm";
    propagatedBuildInputs = [
      dns
      ugorji_go
      armon_go-metrics
      go-multierror
    ];
  };

  memcache = buildFromGitHub {
    version = 2;
    date = "2015-06-22";
    rev = "1031fa0ce2f20c1c0e1e1b51951d8ea02c84fa05";
    owner = "rainycape";
    repo = "memcache";
    sha256 = "0585b0rblaxn4b2p5q80x3ynlcbhvf43p18yxxhlnm0yf0w3hjl9";
  };

  metrics = buildFromGitHub {
    version = 2;
    date = "2015-01-23";
    rev = "2b3c4565aafdcd40c8069e50de08ac5379787943";
    owner = "mailgun";
    repo = "metrics";
    sha256 = "01nnm2wl2m1p1bj86rj87r1yf5f9fmvxxamd2v88p04958xbj0jk";
    propagatedBuildInputs = [
      timetools
    ];
  };

  mgo_v2 = buildFromGitHub {
    version = 1;
    rev = "r2016.08.01";
    owner = "go-mgo";
    repo = "mgo";
    sha256 = "0hq8wfypghfcz83035wdb844b39pd1qly43zrv95i99p35fwmx22";
    goPackagePath = "gopkg.in/mgo.v2";
    excludedPackages = "dbtest";
    buildInputs = [
      pkgs.cyrus-sasl
    ];
  };

  minheap = buildFromGitHub {
    version = 2;
    rev = "7c28d80e2ada649fc8ab1a37b86d30a2633bd47c";
    owner = "mailgun";
    repo = "minheap";
    sha256 = "06lyppnqhyfq1ksc8c50c2czjp3h1ra38jsm8r5mafxrn6rv7p7w";
    date = "2013-12-07";
  };

  minio = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "minio";
    rev = "RELEASE.2016-09-11T17-42-18Z";
    sha256 = "a1e43f383fe94c9e5056c4144d9fa0264d7a44b85bcc12dd7970f1acf9953445";
    buildInputs = [
      amqp
      blake2b-simd
      cli_minio
      color
      cors
      crypto
      dsync
      elastic_v3
      gjson
      go-bindata-assetfs
      go-homedir_minio
      go-humanize
      go-version
      handlers
      jwt-go
      logrus
      mc
      minio-go
      miniobrowser
      mux
      pb
      profile
      redigo
      reedsolomon
      rpc
      sha256-simd
      skyring-common
      structs
    ];
  };

  # The pkg package from minio, for bootstrapping minio
  minio_pkg = buildFromGitHub {
    inherit (minio) version owner repo rev sha256;
    propagatedBuildInputs = [
      # Propagate minio_pkg_probe from here for consistency
      minio_pkg_probe
      pb
      structs
    ];
    postUnpack = ''
      mv -v "$sourceRoot" "''${sourceRoot}.old"
      mkdir -pv "$sourceRoot"
      mv -v "''${sourceRoot}.old"/pkg "$sourceRoot"/pkg
      rm -rf "''${sourceRoot}.old"
    '';
  };

  # Probe pkg was remove in later releases, but still required by mc
  minio_pkg_probe = buildFromGitHub {
    version = 2;
    inherit (minio) owner repo;
    rev = "RELEASE.2016-04-17T22-09-24Z";
    sha256 = "41c8749f0a7c6a22ef35f7cb2577e31871bff95c4c5c035a936b220f198ed04e";
    propagatedBuildInputs = [
      go-humanize
    ];
    postUnpack = ''
      mv -v "$sourceRoot" "''${sourceRoot}.old"
      mkdir -pv "$sourceRoot"/pkg
      mv -v "''${sourceRoot}.old"/pkg/probe "$sourceRoot"/pkg/probe
      rm -rf "''${sourceRoot}.old"
    '';
    meta.autoUpdate = false;
  };

  minio-go = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "minio-go";
    rev = "88cd2fcfc8f7dad4c586918348e986cf6095bfad";
    sha256 = "14ck5qhfvh2515ydw1sd0lndnmd6k3g0i2mszxvdxy5788y0cfdn";
    meta.useUnstable = true;
    date = "2016-10-31";
  };

  miniobrowser = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "miniobrowser";
    date = "2016-11-06";
    rev = "4599bba208e449ea2917e44ec6e380c3b13c264d";
    sha256 = "0y70250wjg45yzlb9alry53b5bxk23h6ccq489qywc773jnmxnji";
    propagatedBuildInputs = [
      go-bindata-assetfs
    ];
  };

  missinggo = buildFromGitHub {
    version = 1;
    rev = "f3a48f14358dc22876048390ba49b963a476a5db";
    owner  = "anacrolix";
    repo   = "missinggo";
    sha256 = "d5c34a92445e5ec95d897f68f9f1cce2a02fdc0d6adc372a98a8bbce6a441c84";
    date = "2016-06-18";
    propagatedBuildInputs = [
      b
      btree
      docopt-go
      envpprof
      goskiplist
      iter
      net
      roaring
      tagflag
    ];
    meta.autoUpdate = false;
  };

  missinggo_lib = buildFromGitHub {
    inherit (missinggo) rev owner repo sha256 version date;
    subPackages = [
      "."
    ];
    propagatedBuildInputs = [
      iter
    ];
    meta.autoUpdate = false;
  };

  mmap-go = buildFromGitHub {
    version = 1;
    owner = "edsrzf";
    repo = "mmap-go";
    rev = "935e0e8a636ca4ba70b713f3e38a19e1b77739e8";
    sha256 = "1a9s99gwziamlw2yn7i86wh675ag2bqbp5aa13vf8kl2rfc2p6ma";
    date = "2016-05-12";
  };

  mmark = buildFromGitHub {
    version = 2;
    owner = "miekg";
    repo = "mmark";
    rev = "2d4f1dd6f87cad351b9323bbaa6f6c586f0c4bee";
    sha256 = "0r0mrsj0pz60g7ljiij0kl9b5s4r0nyl56fjgwy5fn5rpliakinc";
    buildInputs = [
      toml
    ];
    date = "2016-11-03";
  };

  mongo-tools = buildFromGitHub {
    version = 1;
    rev = "r3.3.11";
    owner  = "mongodb";
    repo   = "mongo-tools";
    sha256 = "05zpfrgxrc5szc92qm2ql0xs24hah70i3axz4rbhg2xczgr3b2wb";
    buildInputs = [
      crypto
      go-flags
      gopass
      mgo_v2
      openssl
      termbox-go
      tomb_v2
    ];

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

  mow-cli = buildFromGitHub {
    version = 2;
    rev = "660b9261e2c80bb92e5a0eaa581596084656140e";
    owner  = "jawher";
    repo   = "mow.cli";
    sha256 = "105h4g2q7rmnl3hbn2wqc0p5cg716p630fj1qbl7f357xg8fj5mb";
    date = "2016-09-19";
  };

  ns1-go_v2 = buildFromGitHub {
    version = 2;
    rev = "d8d10b7f448291ddbdce48d4594fb1b667014c8b";
    owner  = "ns1";
    repo   = "nv1-go";
    sha256 = "157dv79vyp9kap59yy6rny47nqyp2zyxdymiwksb43i9qn99fpwn";
    goPackagePath = "gopkg.in/ns1/ns1-go.v2";
    date = "2016-11-04";
  };

  multibuf = buildFromGitHub {
    version = 2;
    rev = "565402cd71fbd9c12aa7e295324ea357e970a61e";
    owner  = "mailgun";
    repo   = "multibuf";
    sha256 = "1csjfl3bcbya7dq3xm1nqb5rwrpw5migrqa4ajki242fa5i66mdr";
    date = "2015-07-14";
  };

  mux = buildFromGitHub {
    version = 2;
    rev = "757bef944d0f21880861c2dd9c871ca543023cba";
    owner = "gorilla";
    repo = "mux";
    sha256 = "1gjn61q6wfvlk6j8fvfqih15037lflx3q5vxdck93na4s7w64fqc";
    propagatedBuildInputs = [
      context
    ];
    date = "2016-09-20";
  };

  muxado = buildFromGitHub {
    version = 1;
    date = "2014-03-12";
    rev = "f693c7e88ba316d1a0ae3e205e22a01aa3ec2848";
    owner  = "inconshreveable";
    repo   = "muxado";
    sha256 = "db9a65b811003bcb48d1acefe049bb12c8de232537cf07e1a4a949a901d807a2";
    meta.autoUpdate = false;
  };

  mysql = buildFromGitHub {
    version = 2;
    rev = "8f6c67f0228a4a6a962008d6c3d1e694e4532e71";
    owner  = "go-sql-driver";
    repo   = "mysql";
    sha256 = "04r8jhbw7j3jq3r5vn35ihbazli90vvxhllyd3mayry8xr4gpd93";
    date = "2016-11-09";
  };

  net-rpc-msgpackrpc = buildFromGitHub {
    version = 1;
    date = "2015-11-15";
    rev = "a14192a58a694c123d8fe5481d4a4727d6ae82f3";
    owner = "hashicorp";
    repo = "net-rpc-msgpackrpc";
    sha256 = "007pwdpap465b32cx1i2hmf2q67vik3wk04xisq2pxvqvx81irks";
    propagatedBuildInputs = [ ugorji_go go-multierror ];
  };

  netlink = buildFromGitHub {
    version = 2;
    rev = "ffec63e1f1d04e356402671aff3f8da58b5dc585";
    owner  = "vishvananda";
    repo   = "netlink";
    sha256 = "1anrz7ldrppwvb3672r1lydq0dmbmid3jn4as11ywy0nkz9awip4";
    date = "2016-11-07";
    propagatedBuildInputs = [
      netns
    ];
  };

  netns = buildFromGitHub {
    version = 1;
    rev = "8ba1072b58e0c2a240eb5f6120165c7776c3e7b8";
    owner  = "vishvananda";
    repo   = "netns";
    sha256 = "05r4qri45ngm40kp9qdbyqrs15gx7swjj27bmc7i04wg9yd65j95";
    date = "2016-04-30";
  };

  nitro = buildFromGitHub {
    version = 1;
    owner = "spf13";
    repo = "nitro";
    rev = "24d7ef30a12da0bdc5e2eb370a79c659ddccf0e8";
    date = "2013-10-03";
    sha256 = "1dbnfac79lxc1pr1j1n3956i292ck4yjrhr8nsd2wp2jccab5zdz";
  };

  nodb = buildFromGitHub {
    version = 1;
    owner = "lunny";
    repo = "nodb";
    rev = "fc1ef06ad4af0da31cdb87e3fa5ec084c67e6597";
    date = "2016-06-21";
    sha256 = "1w46s9mgqjq0faybr743fs96jp0g1pcahrfamfiwi5hz28dqfcsp";
    propagatedBuildInputs = [
      goleveldb
      lunny_log
      go-snappy
      toml
    ];
  };

  nomad = buildFromGitHub {
    version = 1;
    rev = "v0.4.1";
    owner = "hashicorp";
    repo = "nomad";
    sha256 = "1s74493y1qxvnxmg46dxbl4lx09g6zsjr96nk040kyj1n0czgxrb";

    buildInputs = [
      gziphandler
      circbuf
      armon_go-metrics
      go-spew
      go-humanize
      go-dockerclient
      cronexpr
      consul_api
      go-checkpoint
      go-cleanhttp
      go-getter
      go-memdb
      ugorji_go
      go-multierror
      go-syslog
      go-version
      hcl
      logutils
      memberlist
      net-rpc-msgpackrpc
      raft_v1
      raft-boltdb_v1
      scada-client
      serf
      yamux
      osext
      mitchellh_cli
      colorstring
      copystructure
      go-ps
      hashstructure
      mapstructure
      runc
      columnize
      gopsutil
      sys
      go-plugin
      tail
    ];

    subPackages = [
      "."
    ];

    # Remove deprecated consul api.HealthUnknown
    postPatch = ''
      sed -i nomad/structs/structs.go \
        -e 's/api.HealthUnknown, //' \
        -e '/api.HealthUnknown/d'
    '';
  };

  notify = buildFromGitHub {
    version = 2;
    owner = "rjeczalik";
    repo = "notify";
    date = "2016-08-20";
    rev = "7e20c15e6693a7d6ad269a94b70ed68bc4a875a7";
    sha256 = "f6bd315a30a2e14d1defc64a979d1db4371122b33d330afa62b2e3179328382a";
  };

  objx = buildFromGitHub {
    version = 1;
    date = "2015-09-28";
    rev = "1a9d0bb9f541897e62256577b352fdbc1fb4fd94";
    owner  = "stretchr";
    repo   = "objx";
    sha256 = "0ycjvfbvsq6pmlbq2v7670w1k25nydnz4scx0qgiv0f4llxnr0y9";
  };

  openssl = buildFromGitHub {
    version = 2;
    date = "2016-09-22";
    rev = "5be686e264d836e7a01ca7fc7c53acdb8edbe768";
    owner = "10gen";
    repo = "openssl";
    sha256 = "0jlr0y8812ayj5xfpn7m0m1pfm8pf1g43xbw7ngs4zxcs0ip7l9g";
    goPackageAliases = [ "github.com/spacemonkeygo/openssl" ];
    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = [ pkgs.openssl ];
    propagatedBuildInputs = [ spacelog ];

    preBuild = ''
      find go/src/$goPackagePath -name \*.go | xargs sed -i 's,spacemonkeygo/openssl,10gen/openssl,g'
    '';
  };

  osext = buildFromGitHub {
    version = 1;
    date = "2016-08-10";
    rev = "c2c54e542fb797ad986b31721e1baedf214ca413";
    owner = "kardianos";
    repo = "osext";
    sha256 = "0y2fl7f2n7bwfs6vykb8p9qpx8xyp3rl7bb9ax9fhrzgkl112530";
    goPackageAliases = [
      "github.com/bugsnag/osext"
      "bitbucket.org/kardianos/osext"
    ];
  };

  oxy = buildFromGitHub {
    version = 2;
    owner = "vulcand";
    repo = "oxy";
    date = "2016-07-23";
    rev = "db85f00cac5466def1f6f2667063e6e38c1fe606";
    sha256 = "3c32677900a6399eecd80fc47798e998f47f8df502727574052d6ddc654d4a61";
    goPackageAliases = [ "github.com/mailgun/oxy" ];
    propagatedBuildInputs = [
      hdrhistogram
      mailgun_log
      multibuf
      predicate
      timetools
      mailgun_ttlmap
    ];
    meta.autoUpdate = false;
  };

  pat = buildFromGitHub {
    version = 2;
    owner = "bmizerany";
    repo = "pat";
    date = "2016-02-17";
    rev = "c068ca2f0aacee5ac3681d68e4d0a003b7d1fd2c";
    sha256 = "aad2d84661ea918168e60ed7bab467d4e0fce28fe9372e786c2714c10f6490a7";
  };

  pb = buildFromGitHub {
    version = 2;
    owner = "cheggaaa";
    repo = "pb";
    date = "2016-10-26";
    rev = "dd61faab99a777c652bb680e37715fe0cb549856";
    sha256 = "1vdh771mpmj592i9zj38zdk5j6zqyl0sxlj361sb0qsispnhvsc6";
    meta.useUnstable = true;
  };

  pb_v1 = buildFromGitHub {
    version = 2;
    owner = "cheggaaa";
    repo = "pb";
    rev = "v1.0.6";
    sha256 = "136m6c5dpqbw8laznbdci1xk38i5iv0hxzqhp54j84cyf5bj173x";
    goPackagePath = "gopkg.in/cheggaaa/pb.v1";
  };

  beorn7_perks = buildFromGitHub {
    version = 1;
    date = "2016-08-04";
    owner  = "beorn7";
    repo   = "perks";
    rev = "4c0e84591b9aa9e6dcfdf3e020114cd81f89d5f9";
    sha256 = "19dw6jcvcbnk0nq4wy9dhrb1d3k85xwnfvwn1ld03f2mzmshf9fr";
  };

  pester = buildFromGitHub {
    version = 2;
    owner = "sethgrid";
    repo = "pester";
    rev = "2a102734c18c43c74fd0664e06cd414cf9602b93";
    date = "2016-09-16";
    sha256 = "07hnn83d8pflv9zvdx93vvn99pwj4n1jmqc4l84q46bvjsgfbx1g";
  };

  pflag = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "pflag";
    rev = "5ccb023bc27df288a957c5e994cd44fd19619465";
    date = "2016-10-24";
    sha256 = "1mqaxigxb2vlrkb1w4jk1v76bq9m5qfvkrmxl04khwx751qiwmiv";
  };

  pkcs7 = buildFromGitHub {
    version = 1;
    owner = "fullsailor";
    repo = "pkcs7";
    rev = "3befe47e6c80b97ab6863a5fe1b6a611003a5ab0";
    date = "2016-07-24";
    sha256 = "1x8ldsn1kgrca5d5pjipa3nxv40dyxc70qbr8y0x4s7axm4nc0kb";
  };

  pkg = buildFromGitHub {
    version = 2;
    date = "2016-10-26";
    owner  = "coreos";
    repo   = "pkg";
    rev = "447b7ec906e523386d9c53be15b55a8ae86ea944";
    sha256 = "0yn460gwhzii5b8jbiz5fsynd30w2ikh3hbl13ci9g1ybw60qyrn";
    buildInputs = [
      crypto
      yaml_v1
    ];
    propagatedBuildInputs = [
      go-systemd_journal
    ];
  };

  pongo2-v3 = buildFromGitHub {
    version = 1;
    rev = "v3.0";
    owner  = "flosch";
    repo   = "pongo2";
    sha256 = "1qjcj7hcjskjqp03fw4lvn1cwy78dck4jcd0rcrgdchis1b84isk";
    goPackagePath = "gopkg.in/flosch/pongo2.v3";
  };

  pool_v2 = buildFromGitHub {
    version = 2;
    owner = "fatih";
    repo = "pool";
    date = "2016-07-21";
    rev = "20a0a429c5f93de45c90f5f09ea297c25e0929b3";
    sha256 = "2dad7d86c3724e9f90e373ead150d0f1f6b02bbfb98a2347e801db5ea1c67d07";
    goPackagePath = "gopkg.in/fatih/pool.v2";
  };

  pq = buildFromGitHub {
    version = 2;
    rev = "d8eeeb8bae8896dd8e1b7e514ab0d396c4f12a1b";
    owner  = "lib";
    repo   = "pq";
    sha256 = "058sbzmm703pya1n7kh0qvj9p232n0qq62axl1fmzzrjj34qgyj7";
    date = "2016-11-02";
  };

  probing = buildFromGitHub {
    version = 2;
    rev = "07dd2e8dfe18522e9c447ba95f2fe95262f63bb2";
    owner  = "xiang90";
    repo   = "probing";
    sha256 = "140b5bizry0cw2s98dscp5b8zy57h2l5ybkmr7abx9d1c2nrxqnj";
    date = "2016-08-13";
  };

  predicate = buildFromGitHub {
    version = 2;
    rev = "19b9dde14240d94c804ae5736ad0e1de10bf8fe6";
    owner  = "vulcand";
    repo   = "predicate";
    sha256 = "0i2smqnr8vldz7iiid835kgkvs55hb5vjdjj9h87xlwy7f8y9map";
    date = "2016-06-21";
  };

  profile = buildFromGitHub {
    version = 2;
    owner = "pkg";
    repo = "profile";
    rev = "v1.2.0";
    sha256 = "02mq7xinxxln3wz3pgqaklpj0ry3ipp8agvzci72l2b56v50aas2";
  };

  prometheus = buildFromGitHub {
    version = 2;
    rev = "v1.3.1";
    owner  = "prometheus";
    repo   = "prometheus";
    sha256 = "0fl38lh30940dspzl9cgwavm001fqxd9snfz4vfya8mk70nk628g";
    buildInputs = [
      aws-sdk-go
      azure-sdk-for-go
      consul_api
      dns
      fsnotify_v1
      go-autorest
      goleveldb
      govalidator
      go-zookeeper
      google-api-go-client
      grpc
      influxdb_client
      logrus
      net
      prometheus_common
      yaml_v2
    ];
  };

  prometheus_client_golang = buildFromGitHub {
    version = 1;
    rev = "v0.8.0";
    owner = "prometheus";
    repo = "client_golang";
    sha256 = "1n92bwbhymz88n3zm4cnv6xhj80g5r8dp720bwpb0ckwaxnzsbag";
    propagatedBuildInputs = [
      goautoneg
      net
      protobuf
      prometheus_client_model
      prometheus_common_for_client
      procfs
      beorn7_perks
    ];
  };

  prometheus_client_model = buildFromGitHub {
    version = 1;
    rev = "fa8ad6fec33561be4280a8f0514318c79d7f6cb6";
    date = "2015-02-12";
    owner  = "prometheus";
    repo   = "client_model";
    sha256 = "150fqwv7lnnx2wr8v9zmgaf4hyx1lzd4i1677ypf6x5g2fy5hh6r";
    buildInputs = [
      protobuf
    ];
  };

  prometheus_common = buildFromGitHub {
    version = 2;
    date = "2016-11-09";
    rev = "f36a8da2241e626287bf1adfa7bc2f66bbc6770b";
    owner = "prometheus";
    repo = "common";
    sha256 = "076zqkbs5p94i48j9kwpgc4g3dw0cgaqb9dk0n4ry1n47f2wxfam";
    buildInputs = [
      logrus
      net
      prometheus_client_model
      protobuf
    ];
    propagatedBuildInputs = [
      golang_protobuf_extensions
      httprouter
      prometheus_client_golang
    ];
  };

  prometheus_common_for_client = buildFromGitHub {
    inherit (prometheus_common) date rev owner repo sha256 version;
    subPackages = [
      "expfmt"
      "model"
      "internal/bitbucket.org/ww/goautoneg"
    ];
    propagatedBuildInputs = [
      golang_protobuf_extensions
      prometheus_client_model
      protobuf
    ];
  };

  procfs = buildFromGitHub {
    version = 1;
    rev = "abf152e5f3e97f2fafac028d2cc06c1feb87ffa5";
    date = "2016-04-11";
    owner  = "prometheus";
    repo   = "procfs";
    sha256 = "08536i8yaip8lv4zas4xa59igs4ybvnb2wrmil8rzk3a2hl9zck8";
  };

  properties = buildFromGitHub {
    version = 1;
    owner = "magiconair";
    repo = "properties";
    rev = "v1.7.0";
    sha256 = "00s9b7fmzhg3j55hs48s3pvzslfj54k1h9vicj782gg79pgid785";
  };

  gogo_protobuf = buildFromGitHub {
    version = 1;
    owner = "gogo";
    repo = "protobuf";
    rev = "v0.3";
    sha256 = "1qxlyjw7hi06byzxp3xa5sdvg5dmbq9cc6558xm8acr9xjizf78y";
    excludedPackages = "test";
  };

  pty = buildFromGitHub {
    version = 2;
    owner = "kr";
    repo = "pty";
    rev = "ce7fa45920dc37a92de8377972e52bc55ffa8d57";
    sha256 = "0dggs6g9gli2jvq3ssz14p3mblgw802211yzpn2ap3kxgpk69s40";
    date = "2016-07-16";
  };

  purell = buildFromGitHub {
    version = 2;
    owner = "PuerkitoBio";
    repo = "purell";
    rev = "v1.0.0";
    sha256 = "07kxcpb3pgk5n64445zvqb0z90nbm3i03dyz2d9j35ns0c00nnly";
    propagatedBuildInputs = [
      net
      text
      urlesc
    ];
  };

  qart = buildFromGitHub {
    version = 1;
    rev = "0.1";
    owner  = "vitrun";
    repo   = "qart";
    sha256 = "02n7f1j42jp8f4nvg83nswfy6yy0mz2axaygr6kdqwj11n44rdim";
  };

  ql = buildFromGitHub {
    version = 1;
    rev = "v1.0.6";
    owner  = "cznic";
    repo   = "ql";
    sha256 = "1cw4ilgjkx74pshrf6fzngyy1jj98y3051b6mkq4s7ksmr8s9xpy";
    propagatedBuildInputs = [
      go4
      b
      exp
      lldb
      strutil
    ];
  };

  rabbit-hole = buildFromGitHub {
    version = 2;
    rev = "1560b2e1bef4ef7a8757165a1c56be095deede15";
    owner  = "michaelklishin";
    repo   = "rabbit-hole";
    sha256 = "0fq69d4c1f23skr2mapkqpki7jvbgr2xxxh2kf8mp5kabvkyn3fi";
    date = "2016-09-06";
  };

  raft_v1 = buildFromGitHub {
    version = 2;
    date = "2016-08-23";
    rev = "5f09c4ffdbcd2a53768e78c47717415de12b6728";
    owner  = "hashicorp";
    repo   = "raft";
    sha256 = "87367c09962cfefc09cfc7c7092099086aa98412f7ad174c85c803790635fa83";
    propagatedBuildInputs = [ armon_go-metrics ugorji_go ];
  };

  raft_v2 = buildFromGitHub {
    version = 2;
    date = "2016-11-09";
    # Use the library-v2-stage-one branch until it is merged
    # into master.
    rev = "aaad9f10266e089bd401e7a6487651a69275641b";
    owner  = "hashicorp";
    repo   = "raft";
    sha256 = "b5a3392c27c22bbd44bc7978ca61f9ce90658caf51bebef7b4db11788d4d5e80";
    propagatedBuildInputs = [
      armon_go-metrics
      logxi
      ugorji_go
    ];
    meta.autoUpdate = false;
  };

  raft-boltdb_v2 = buildFromGitHub {
    version = 2;
    date = "2016-09-13";
    rev = "a8adffd05b79e3d8b1817d46bbe387a112265b3e";
    owner  = "hashicorp";
    repo   = "raft-boltdb";
    sha256 = "0kj22b0xk7avzwymkdi98f9vbbgslfd187njd7128nhgmdvfdn0m";
    propagatedBuildInputs = [
      bolt
      ugorji_go
      raft_v2
    ];
  };

  raft-boltdb_v1 = buildFromGitHub {
    inherit (raft-boltdb_v2) version rev date owner repo sha256;
    propagatedBuildInputs = [
      bolt
      ugorji_go
      raft_v1
    ];
  };

  ratecounter = buildFromGitHub {
    version = 2;
    owner = "paulbellamy";
    repo = "ratecounter";
    rev = "v0.1.0";
    sha256 = "a4f573a38ec36fbbefea687e750abce13bd8dc80134596c87f60d15179e3cbdc";
  };

  ratelimit = buildFromGitHub {
    version = 1;
    rev = "77ed1c8a01217656d2080ad51981f6e99adaa177";
    date = "2015-11-25";
    owner  = "juju";
    repo   = "ratelimit";
    sha256 = "0m7bvg8kg9ffl624lbcq47207n6r54z9by1wy0axslishgp1lh98";
  };

  raw = buildFromGitHub {
    version = 1;
    rev = "724aedf6e1a5d8971aafec384b6bde3d5608fba4";
    owner  = "feyeleanor";
    repo   = "raw";
    sha256 = "0pkvvvln5cyyy0y2i82jv39gjnfgzpb5ih94iav404lfsachh8m1";
    date = "2013-03-27";
  };

  cupcake_rdb = buildFromGitHub {
    version = 2;
    date = "2016-08-25";
    rev = "43ba34106c765f2111c0dc7b74cdf8ee437411e0";
    owner = "cupcake";
    repo = "rdb";
    sha256 = "0sqs6l4i5f2pd4i719aijbyjhdss8zqvk3b9195d0ljx2di9y84i";
  };

  siddontang_rdb = buildFromGitHub {
    version = 1;
    date = "2015-03-07";
    rev = "fc89ed2e418d27e3ea76e708e54276d2b44ae9cf";
    owner = "siddontang";
    repo = "rdb";
    sha256 = "1rf7dcxymdqjxjld6mb0fpsprnf342y1mr6m93fr073m5k5ij6kq";
    propagatedBuildInputs = [
      cupcake_rdb
    ];
  };

  redigo = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "redigo";
    date = "2016-07-23";
    rev = "5e2117cd32d677a36dcd8c9c83776a065555653b";
    sha256 = "3991316f879ff46e423e73f4006b26b620a0a98397fd649e0d667ff7cd35093a";
    meta.useUnstable = true;
  };

  redis_v2 = buildFromGitHub {
    version = 1;
    rev = "v2.3.2";
    owner  = "go-redis";
    repo   = "redis";
    sha256 = "211e91fd3b5e120ca073aecb8088ba513012ab4513b13934890aaa6791b2923b";
    goPackagePath = "gopkg.in/redis.v2";
    propagatedBuildInputs = [
      bufio_v1
    ];
    meta.autoUpdate = false;
  };

  reedsolomon = buildFromGitHub {
    version = 2;
    owner = "klauspost";
    repo = "reedsolomon";
    date = "2016-10-28";
    rev = "d0a56f72c0d40a6cdde43a1575ad9686a0098b70";
    sha256 = "0w78rwan71zmakaw2xb8zx9cxbi2658ghyhgmg2i9a175pxqg1ph";
    propagatedBuildInputs = [
      cpuid
    ];
    meta.useUnstable = true;
  };

  reflectwalk = buildFromGitHub {
    version = 2;
    date = "2016-10-04";
    rev = "9ad27c461a633e32a235a061d523aefe8f18571d";
    owner  = "mitchellh";
    repo   = "reflectwalk";
    sha256 = "02jg1vi3brfi9lnxlf65lkdh6jzwkq7ywbrqiip3p0q6xmvhvm00";
  };

  roaring = buildFromGitHub {
    version = 2;
    rev = "v0.2.8";
    owner  = "RoaringBitmap";
    repo   = "roaring";
    sha256 = "1hkm77ghjqlw2jzdvcqqa4yjxqk06xbdjhr4bc819vdgmshhijaf";
  };

  roundtrip = buildFromGitHub {
    version = 2;
    owner = "gravitational";
    repo = "roundtrip";
    date = "2016-08-24";
    rev = "70ae61f93f7a40afe910ec2703c7911497d2077c";
    sha256 = "1zd5finiqw6m5wl07g28gqhlpxwra9r9mxmh5xv3yhmhx3zjm8pb";
    propagatedBuildInputs = [
      trace
    ];
  };

  rpc = buildFromGitHub {
    version = 2;
    owner = "gorilla";
    repo = "rpc";
    date = "2016-09-24";
    rev = "22c016f3df3febe0c1f6727598b6389507e03a18";
    sha256 = "0ny16dm38zkd7j6v11vayfx8j5q6bmfhsl3hj855f79c90i4bkaq";
  };

  rsc = buildFromGitHub {
    version = 2;
    owner = "mdp";
    repo = "rsc";
    date = "2016-01-31";
    rev = "90f07065088deccf50b28eb37c93dad3078c0f3c";
    sha256 = "0nibwihq09m5chhryi20dcjg9bbk4yy0x2asz0c8ln73hrcijdm1";
    buildInputs = [
      pkgs.qrencode
    ];
  };

  runc = buildFromGitHub {
    version = 1;
    rev = "v1.0.0-rc1";
    owner = "opencontainers";
    repo = "runc";
    sha256 = "75b869ab4d184c870de0c203d5466d846c279652ba412f35af7ddeca6835ff5c";
    propagatedBuildInputs = [
      go-units
      logrus
      docker_for_runc
      go-systemd
      protobuf
      gocapability
      netlink
      urfave_cli
      runtime-spec
    ];
    meta.autoUpdate = false;
  };

  runtime-spec = buildFromGitHub {
    version = 1;
    rev = "v1.0.0-rc1";
    owner = "opencontainers";
    repo = "runtime-spec";
    sha256 = "1c112fe3b731835f244a6d7030de25e371ba4f783cdff0ae53e471908a117162";
    buildInputs = [
      gojsonschema
    ];
    meta.autoUpdate = false;
  };

  sanitized-anchor-name = buildFromGitHub {
    version = 2;
    owner = "shurcooL";
    repo = "sanitized_anchor_name";
    rev = "1dba4b3954bc059efc3991ec364f9f9a35f597d2";
    date = "2016-09-17";
    sha256 = "10gr6fqd9v4q1jfqms4v797a9769x3p9gvrzv3a65ngdqyfnikk5";
  };

  scada-client = buildFromGitHub {
    version = 1;
    date = "2016-06-01";
    rev = "6e896784f66f82cdc6f17e00052db91699dc277d";
    owner  = "hashicorp";
    repo   = "scada-client";
    sha256 = "1by4kyd2hrrrghwj7snh9p8fdlqka24q9yr6nyja2acs2zpjgh7a";
    buildInputs = [ armon_go-metrics net-rpc-msgpackrpc yamux ];
  };

  semver = buildFromGitHub {
    version = 1;
    rev = "v3.3.0";
    owner = "blang";
    repo = "semver";
    sha256 = "0vz3bzkclpgy7n55z6vx3yxzl0mgxbcwfa262kyi2bnvfgz1r10r";
  };

  serf = buildFromGitHub {
    version = 2;
    rev = "v0.8.0";
    owner  = "hashicorp";
    repo   = "serf";
    sha256 = "1ci7yav379aykvjc1xrc71fsvzb1h9vnmzk79h4p7ga7mghkkmdd";

    buildInputs = [
      net circbuf armon_go-metrics ugorji_go go-syslog logutils mdns memberlist
      dns mitchellh_cli mapstructure columnize
    ];
  };

  session = buildFromGitHub {
    version = 1;
    rev = "66031fcb37a0fff002a1f028eb0b3a815c78306b";
    owner  = "go-macaron";
    repo   = "session";
    sha256 = "1402h3a6wgjx71h8bi87k5p9inypybyp2wjcz2b9ldiczmajxfwy";
    date = "2015-10-13";
    propagatedBuildInputs = [
      gomemcache
      go-couchbase
      com
      ledisdb
      macaron_v1
      mysql
      nodb
      pq
      redis_v2
    ];
  };

  sets = buildFromGitHub {
    version = 1;
    rev = "6c54cb57ea406ff6354256a4847e37298194478f";
    owner  = "feyeleanor";
    repo   = "sets";
    sha256 = "11gg27znzsay5pn9wp7rl427v8bl1rsncyk8nilpsbpwfbz7q7vm";
    date = "2013-02-27";
    propagatedBuildInputs = [
      slices
    ];
  };

  sftp = buildFromGitHub {
    version = 2;
    owner = "pkg";
    repo = "sftp";
    rev = "4d0e916071f68db74f8a73926335f809396d6b42";
    date = "2016-10-01";
    sha256 = "0bkhab0byjdjq476hxi3as685p7x18l2np7gj2kmrzpadadv1w0a";
    propagatedBuildInputs = [
      crypto
      errors
      fs
    ];
  };

  sha256-simd = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "sha256-simd";
    date = "2016-10-15";
    rev = "f78567f7ee70e4be482ad2849f6c3bb7651b34a5";
    sha256 = "0mb6knh4bx8p4kpaq4grcc9gw7w9kliipky30sbw1nqnrymmcsja";
  };

  skyring-common = buildFromGitHub {
    version = 2;
    owner = "skyrings";
    repo = "skyring-common";
    date = "2016-09-29";
    rev = "d1c0bb1cbd5ed8438be1385c85c4f494608cde1e";
    sha256 = "0wr3bw55daf8ryz46hviwvs1wz1l2c6x3rrccr70gllg74lg1wd5";
    buildInputs = [
      go-logging
      go-python
      gorequest
      graphite-golang
      influxdb
      mgo_v2
    ];
    postPatch = /* go-python now uses float64 */ ''
      sed -i tools/gopy/gopy.go \
        -e 's/python.PyFloat_FromDouble(f32)/python.PyFloat_FromDouble(f64)/'
    '';
  };

  slices = buildFromGitHub {
    version = 1;
    rev = "bb44bb2e4817fe71ba7082d351fd582e7d40e3ea";
    owner  = "feyeleanor";
    repo   = "slices";
    sha256 = "05i934pmfwjiany6r9jgp27nc7bvm6nmhflpsspf10d4q0y9x8zc";
    date = "2013-02-25";
    propagatedBuildInputs = [
      raw
    ];
  };

  slug = buildFromGitHub {
    version = 1;
    rev = "v1.0.2";
    owner  = "gosimple";
    repo   = "slug";
    sha256 = "078zkcw98dp51mcrcl8gz341j1pgrmhkl10p3yqd8wxh6s492sfb";
    propagatedBuildInputs = [
      com
      macaron_v1
      unidecode
    ];
  };

  sortutil = buildFromGitHub {
    version = 1;
    date = "2015-06-17";
    rev = "4c7342852e65c2088c981288f2c5610d10b9f7f4";
    owner = "cznic";
    repo = "sortutil";
    sha256 = "11iykyi1d7vjmi7778chwbl86j6s1742vnd4k7n1rvrg7kq558xq";
  };

  spacelog = buildFromGitHub {
    version = 1;
    date = "2016-06-06";
    rev = "f936fb050dc6b5fe4a96b485a6f069e8bdc59aeb";
    owner = "spacemonkeygo";
    repo = "spacelog";
    sha256 = "008npp1bdza55wqyv157xd1512xbpar6hmqhhs3bi5xh7xlwpswj";
    buildInputs = [ flagfile ];
  };

  speakeasy = buildFromGitHub {
    version = 2;
    date = "2016-10-13";
    rev = "675b82c74c0ed12283ee81ba8a534c8982c07b85";
    owner = "bgentry";
    repo = "speakeasy";
    sha256 = "0k0mydv8dn6dwia05v5wz4h20baynrd0xgsrmwp496yhwq8yagkz";
  };

  stack = buildFromGitHub {
    version = 1;
    rev = "v1.5.2";
    owner = "go-stack";
    repo = "stack";
    sha256 = "0c75y18wb45n61ppgzb52k59p52g7221zcm435pz3ca0yhjz02q6";
  };

  stathat = buildFromGitHub {
    version = 1;
    date = "2016-07-15";
    rev = "74669b9f388d9d788c97399a0824adbfee78400e";
    owner = "stathat";
    repo = "go";
    sha256 = "19aki04z76qzgdr8l3zlz904mkalspfa46cja2fdjy70sfvfjdp1";
  };

  statik = buildFromGitHub {
    version = 2;
    owner = "rakyll";
    repo = "statik";
    date = "2016-09-06";
    rev = "e383bbf6b2ec1a2fb8492dfd152d945fb88919b6";
    sha256 = "3e7a626af83340a966a52f634198ede41b0a564946902e5fa1b4341a8d0dccdd";
    postPatch = /* Remove recursive import of itself */ ''
      sed -i example/main.go \
        -e '/"github.com\/rakyll\/statik\/example\/statik"/d'
    '';
  };

  structs = buildFromGitHub {
    version = 1;
    date = "2016-08-07";
    rev = "dc3312cb1a4513a366c4c9e622ad55c32df12ed3";
    owner  = "fatih";
    repo   = "structs";
    sha256 = "0qlxfpa0nqwvik6h965hrbhpvar3zd84jhfxrpa6b9r2wbaxcz6s";
  };

  stump = buildFromGitHub {
    version = 1;
    date = "2016-06-11";
    rev = "206f8f13aae1697a6fc1f4a55799faf955971fc5";
    owner = "whyrusleeping";
    repo = "stump";
    sha256 = "0qmchkr29rzscc148aw2vb2qf5dma2dka0ys96cx5fxa4p516d3i";
  };

  strutil = buildFromGitHub {
    version = 1;
    date = "2015-04-30";
    rev = "1eb03e3cc9d345307a45ec82bd3016cde4bd4464";
    owner = "cznic";
    repo = "strutil";
    sha256 = "0ipn9zaihxpzs965v3s8c9gm4rc4ckkihhjppchr3hqn2vxwgfj1";
  };

  suture = buildFromGitHub {
    version = 1;
    rev = "v2.0.0";
    owner  = "thejerf";
    repo   = "suture";
    sha256 = "0w7v4dp9pjndrrbqkpsl8xlnjs5gv8398gyyvhlb8x5h39v217vp";
  };

  swift = buildFromGitHub {
    version = 1;
    rev = "b964f2ca856aac39885e258ad25aec08d5f64ee6";
    owner  = "ncw";
    repo   = "swift";
    sha256 = "1dxhb26pa8j0rzn3w5jdfs56dzf2qv6k28jf5kn4d403y2rvfv99";
    date = "2016-06-17";
  };

  sync = buildFromGitHub {
    version = 1;
    rev = "812602587b72df6a2a4f6e30536adc75394a374b";
    owner  = "anacrolix";
    repo   = "sync";
    sha256 = "10rk5fkchbmfzihyyxxcl7bsg6z0kybbjnn1f2jk40w18vgqk50r";
    date = "2015-10-30";
    buildInputs = [
      missinggo
    ];
  };

  syncthing = buildFromGitHub rec {
    version = 2;
    rev = "v0.14.10";
    owner = "syncthing";
    repo = "syncthing";
    sha256 = "115y94anvpfc214n9841pf1cvp9vm4iyarjrx11mbjrly9da97kx";
    buildFlags = [ "-tags noupgrade" ];
    buildInputs = [
      go-lz4 du luhn xdr snappy ratelimit osext
      goleveldb suture qart crypto net text rcrowley_go-metrics
      go-nat-pmp glob gateway ql groupcache pq gogo_protobuf
      geoip2-golang sha256-simd
    ];
    postPatch = ''
      # Mostly a cosmetic change
      sed -i 's,unknown-dev,${rev},g' cmd/syncthing/main.go
    '';
    preBuild = ''
      pushd go/src/$goPackagePath
      go run script/genassets.go gui > lib/auto/gui.files.go
      popd
    '';
  };

  syncthing-lib = buildFromGitHub {
    inherit (syncthing) rev owner repo sha256 version;
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
    version = 1;
    rev = "ff71fe7a7d5279df4b964b31f7ee4adf117277f6";
    date = "2015-07-17";
    owner  = "jeromer";
    repo   = "syslogparser";
    sha256 = "1x1nq7kyvmfl019d3rlwx9nqlqwvc87376mq3xcfb7f5vxlmz9y5";
  };

  tablewriter = buildFromGitHub {
    version = 2;
    rev = "bdcc175572fd7abece6c831e643891b9331bc9e7";
    date = "2016-09-23";
    owner  = "olekukonko";
    repo   = "tablewriter";
    sha256 = "1f8mndah5b3b4ia8vssx7zaw9704fjwwgywy9vgz32a3y2ps2j2d";
    propagatedBuildInputs = [
      go-runewidth
    ];
  };

  tagflag = buildFromGitHub {
    version = 1;
    rev = "e7497e81ffa475caf0fc24e999eb29edc0335040";
    date = "2016-06-15";
    owner  = "anacrolix";
    repo   = "tagflag";
    sha256 = "3515c691c6ecc867e3e539048b9ca331ccb654c1890cde460748b9b3043eba5a";
    propagatedBuildInputs = [
      go-humanize
      missinggo_lib
      xstrings
    ];
    meta.autoUpdate = false;
  };

  tail = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "hpcloud";
    repo   = "tail";
    sha256 = "1a1k0hzyn4519b659hkxfjlzm4mf5ffhzzhifhkcc231zlxy4l5r";
    propagatedBuildInputs = [
      fsnotify_v1
      tomb_v1
    ];
  };

  tar-utils = buildFromGitHub {
    version = 1;
    rev = "beab27159606f5a7c978268dd1c3b12a0f1de8a7";
    date = "2016-03-22";
    owner  = "whyrusleeping";
    repo   = "tar-utils";
    sha256 = "0p0cmk30b22bgfv4m29nnk2359frzzgin2djhysrqznw3wjpn3nz";
  };

  teleport = buildFromGitHub {
    version = 2;
    rev = "v1.2.0";
    owner = "gravitational";
    repo = "teleport";
    sha256 = "14m8g7ris65zpvcxrnd9bjyxjirph8liarvch1bzwbq1ynyf1x20";
    buildInputs = [
      bolt
      configure
      docker_for_teleport
      etcd_client
      go-oidc
      goterm
      hotp
      httprouter
      gravitational_kingpin
      lemma
      osext
      oxy
      pty
      roundtrip
      trace
      gravitational_ttlmap
      pborman_uuid
      yaml_v2
    ];
    excludedPackages = "\\(test\\|suite\\)";
  };

  template = buildFromGitHub {
    version = 1;
    rev = "a0175ee3bccc567396460bf5acd36800cb10c49c";
    owner = "alecthomas";
    repo = "template";
    sha256 = "10albmv2bdrrgzzqh1rlr88zr2vvrabvzv59m15wazwx39mqzd7p";
    date = "2016-04-05";
  };

  termbox-go = buildFromGitHub {
    version = 2;
    rev = "b6acae516ace002cb8105a89024544a1480655a5";
    date = "2016-09-13";
    owner = "nsf";
    repo = "termbox-go";
    sha256 = "0g7r0a08c0m7nf1vig5i21my2ka0fbdy5rc87cj7wkgzd3ppi58p";
    propagatedBuildInputs = [
      go-runewidth
    ];
  };

  testify = buildFromGitHub {
    version = 1;
    rev = "v1.1.3";
    owner = "stretchr";
    repo = "testify";
    sha256 = "12r2v07zq22bk322hn8dn6nv1fg04wb5pz7j7bhgpq8ji2sassdp";
    propagatedBuildInputs = [
      go-difflib
      go-spew
      objx
    ];
  };

  timetools = buildFromGitHub {
    version = 2;
    rev = "fd192d755b00c968d312d23f521eb0cdc6f66bd0";
    date = "2015-05-05";
    owner = "mailgun";
    repo = "timetools";
    sha256 = "0ja8k6b1gp99jifm9ljkwfrqsn00c87pz7alafmy34sc0xlxdcy9";
    propagatedBuildInputs = [
      mgo_v2
    ];
  };

  tokenbucket = buildFromGitHub {
    version = 1;
    rev = "c5a927568de7aad8a58127d80bcd36ca4e71e454";
    date = "2013-12-01";
    owner = "ChimeraCoder";
    repo = "tokenbucket";
    sha256 = "11zasaakzh4fzzmmiyfq5mjqm5md5bmznbhynvpggmhkqfbc28gz";
  };

  tomb_v2 = buildFromGitHub {
    version = 1;
    date = "2014-06-26";
    rev = "14b3d72120e8d10ea6e6b7f87f7175734b1faab8";
    owner = "go-tomb";
    repo = "tomb";
    sha256 = "1ixpcahm1j5s9rv52al1k8047hsv7axxqvxcpdpa0lr70b33n45f";
    goPackagePath = "gopkg.in/tomb.v2";
  };

  tomb_v1 = buildFromGitHub {
    version = 1;
    date = "2014-10-24";
    rev = "dd632973f1e7218eb1089048e0798ec9ae7dceb8";
    owner = "go-tomb";
    repo = "tomb";
    sha256 = "1gn3f185fihpd5ccr04bp2iprj75jyx803a6i9b3avbcmn24w7xa";
    goPackagePath = "gopkg.in/tomb.v1";
  };

  toml = buildFromGitHub {
    version = 1;
    owner = "BurntSushi";
    repo = "toml";
    rev = "v0.2.0";
    sha256 = "1sqhi5rx27scpcygdzipbhx4l6x4mjjxkbh5hg00wzqhfwhy4mxw";
    goPackageAliases = [ "github.com/burntsushi/toml" ];
  };

  trace = buildFromGitHub {
    version = 2;
    owner = "gravitational";
    repo = "trace";
    rev = "6e153c7add15eb07e311f892779fb294373c4cfa";
    sha256 = "0y1ly0n5x9vgvcc86xbs70my13ih0ag7qcys08dildl7cc6c1dh8";
    date = "2016-09-29";
    propagatedBuildInputs = [
      clockwork
      grpc
      logrus
      net
    ];
  };

  gravitational_ttlmap = buildFromGitHub {
    version = 2;
    owner = "gravitational";
    repo = "ttlmap";
    rev = "348cf76cace4d93fdacc38dfdaa2306f4f0e9c16";
    sha256 = "00z54zc4g5h8qdwdqhkycyjl705sg7bb1iilkmrdh04n602wdwr0";
    date = "2016-04-07";
    propagatedBuildInputs = [
      clockwork
      minheap
    ];
  };

  mailgun_ttlmap = buildFromGitHub {
    version = 2;
    owner = "mailgun";
    repo = "ttlmap";
    rev = "8210f93bcb6393a9f36a22ac02fb3c4f53289850";
    sha256 = "1ir31h07xmjwkn0mnx3hkp6mj0x1qa58ling09czxqjqwm263ab3";
    date = "2016-08-25";
    propagatedBuildInputs = [
      minheap
      timetools
    ];
  };

  unidecode = buildFromGitHub {
    version = 1;
    rev = "cb7f23ec59bec0d61b19c56cd88cee3d0cc1870c";
    owner = "rainycape";
    repo = "unidecode";
    sha256 = "1lf6r5clkmq72hx9yjc8s7z7g1vdn8a9333aq1c0n5lwhcavh6h3";
    date = "2015-09-07";
  };

  units = buildFromGitHub {
    version = 1;
    rev = "2efee857e7cfd4f3d0138cc3cbb1b4966962b93a";
    owner = "alecthomas";
    repo = "units";
    sha256 = "1jj055kgx6mfx5zw263ci70axk3z5006db74dqhcilxwk1a2ga23";
    date = "2015-10-22";
  };

  urlesc = buildFromGitHub {
    version = 2;
    owner = "PuerkitoBio";
    repo = "urlesc";
    rev = "5bd2802263f21d8788851d5305584c82a5c75d7e";
    sate = "2015-02-08";
    sha256 = "09qypmzsr71ikqinffr5ryg4b38kclssrfnnh8n3rv0plcx8i5rr";
    date = "2016-07-26";
  };

  usage-client = buildFromGitHub {
    version = 2;
    owner = "influxdata";
    repo = "usage-client";
    date = "2016-08-29";
    rev = "6d3895376368aa52a3a81d2a16e90f0f52371967";
    sha256 = "37a9a3330c2a7fac370ccb7117c681dd6fafeef57d327b3071ec13a279fa7996";
  };

  utp = buildFromGitHub {
    version = 2;
    rev = "83bf7c81b0e1f917f18ac31b7a27b91c33737df9";
    owner  = "anacrolix";
    repo   = "utp";
    sha256 = "0zprk0nv0b79ld4cp0zxxqmxzfvrgixr5ifm98wrdymp795rplzf";
    date = "2016-10-06";
    propagatedBuildInputs = [
      envpprof
      missinggo
      sync
    ];
  };

  pborman_uuid = buildFromGitHub {
    version = 2;
    rev = "3d4f2ba23642d3cfd06bd4b54cf03d99d95c0f1b";
    owner = "pborman";
    repo = "uuid";
    sha256 = "0aisy283qlq502v7h3mc5878d94rq6mgx6ybjd1fqyvwl9nzxfcq";
    date = "2016-10-05";
  };

  satori_uuid = buildFromGitHub {
    version = 1;
    rev = "v1.1.0";
    owner = "satori";
    repo = "uuid";
    sha256 = "19xzrdm1x07s7siavy8ssilhzyn89kqqpprmql1vsbplzljl4zgl";
  };

  vault = buildFromGitHub {
    version = 2;
    rev = "v0.6.2";
    owner = "hashicorp";
    repo = "vault";
    sha256 = "088nixbi0p039cx4i19kcmgqc4kwkh2av71zwsmjkjakw2cz6qiz";

    buildInputs = [
      azure-sdk-for-go
      armon_go-metrics
      go-radix
      govalidator
      aws-sdk-go
      speakeasy
      etcd_client
      go-mssqldb
      duo_api_golang
      structs
      pkcs7
      yaml
      ini_v1
      ldap
      mysql
      gocql
      protobuf
      snappy
      go-github
      go-querystring
      hailocab_go-hostpool
      consul_api
      errwrap
      go-cleanhttp
      ugorji_go
      go-multierror
      go-rootcerts
      go-syslog
      hashicorp-go-uuid
      golang-lru
      hcl
      logutils
      net-rpc-msgpackrpc
      scada-client
      serf
      yamux
      go-jmespath
      pq
      go-isatty
      rabbit-hole
      mitchellh_cli
      copystructure
      go-homedir
      mapstructure
      reflectwalk
      swift
      columnize
      go-zookeeper
      crypto
      net
      oauth2
      sys
      appengine
      asn1-ber
      mgo_v2
      grpc
      pester
      logxi
      go-colorable
      go-crypto
      jsonx
    ];
  };

  vault_api = buildFromGitHub {
    inherit (vault) rev owner repo sha256 version;
    subPackages = [
      "api"
      "helper/compressutil"
      "helper/jsonutil"
    ];
    propagatedBuildInputs = [
      hcl
      structs
      go-cleanhttp
      go-multierror
      go-rootcerts
      mapstructure
      pester
    ];
  };

  viper = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "viper";
    rev = "651d9d916abc3c3d6a91a12549495caba5edffd2";
    date = "2016-10-29";
    sha256 = "1xh49c3350id8h70c12gi7hcyakn61wri2sh0gnjpfnkabkzask8";
    buildInputs = [
      crypt
      pflag
    ];
    propagatedBuildInputs = [
      afero
      cast
      fsnotify
      go-toml
      hcl
      jwalterweatherman
      mapstructure
      properties
      #toml
      yaml_v2
    ];
  };

  vultr = buildFromGitHub {
    version = 2;
    rev = "v1.10";
    owner  = "JamesClonk";
    repo   = "vultr";
    sha256 = "189dx9djv80lcybyfwxm7lxyicgvxrz197f8j92yzqy0c8kfswi3";
    propagatedBuildInputs = [
      mow-cli
      tokenbucket
      ratelimit
    ];
  };

  websocket = buildFromGitHub {
    version = 2;
    rev = "9fbf129ff2a3cf2467f7d0021de2eb4d3aecc109";
    owner  = "gorilla";
    repo   = "websocket";
    sha256 = "1w3dinadbdn8s4l03c6l3f88ggx557abdkqlblmsralrr6l1gvm4";
    date = "2016-11-02";
  };

  wmi = buildFromGitHub {
    version = 1;
    rev = "f3e2bae1e0cb5aef83e319133eabfee30013a4a5";
    owner = "StackExchange";
    repo = "wmi";
    sha256 = "1paiis0l4adsq68v5p4mw7g7vv39j06fawbaph1d3cglzhkvsk7q";
    date = "2015-05-20";
  };

  yaml = buildFromGitHub {
    version = 2;
    rev = "bea76d6a4713e18b7f5321a2b020738552def3ea";
    date = "2016-10-19";
    owner = "ghodss";
    repo = "yaml";
    sha256 = "0fh5r36y69pkl5byxgg7y75ks857p60gy6sliiyy21cg43hkcq61";
    propagatedBuildInputs = [
      yaml_v2
    ];
  };

  yaml_v2 = buildFromGitHub {
    version = 2;
    rev = "a5b47d31c556af34a302ce5d659e6fea44d90de0";
    date = "2016-09-28";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "1aggcvz2pw5fn7mpw533iq448s1dzfmv6jg5mqi4vavzn351zjqf";
    goPackagePath = "gopkg.in/yaml.v2";
  };

  yaml_v1 = buildFromGitHub {
    version = 1;
    rev = "9f9df34309c04878acc86042b16630b0f696e1de";
    date = "2014-09-24";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "128xs9pdz042hxl28fi2gdrz5ny0h34xzkxk5rxi9mb5mq46w8ys";
    goPackagePath = "gopkg.in/yaml.v1";
  };

  yamux = buildFromGitHub {
    version = 1;
    date = "2016-07-20";
    rev = "d1caa6c97c9fc1cc9e83bbe34d0603f9ff0ce8bd";
    owner  = "hashicorp";
    repo   = "yamux";
    sha256 = "19frd5lldxrjybdj8a3al3bq2wn0bghrnldxvrydr5ysf782qalw";
  };

  xdr = buildFromGitHub {
    version = 1;
    rev = "v2.0.0";
    owner  = "calmh";
    repo   = "xdr";
    sha256 = "017k3y66fy2azbv9iymxsixpyda9czz8v3mhpn17750vlg842dsp";
  };

  xhandler = buildFromGitHub {
    version = 2;
    owner = "rs";
    repo = "xhandler";
    date = "2016-06-18";
    rev = "ed27b6fd65218132ee50cd95f38474a3d8a2cd12";
    sha256 = "14e5d9f09a28bff8a9687e2f1d2250e034852b2dd784eb8c1ee04fac676f9357";
    propagatedBuildInputs = [
      net
    ];
  };

  xorm = buildFromGitHub {
    version = 2;
    rev = "v0.5.6";
    owner  = "go-xorm";
    repo   = "xorm";
    sha256 = "1x4r5gbq41v4c515niw4phwzsmgv5wlw35q877qr9h5fn3jfjqmv";
    propagatedBuildInputs = [
      core
    ];
  };

  xstrings = buildFromGitHub {
    version = 1;
    rev = "3959339b333561bf62a38b424fd41517c2c90f40";
    date = "2015-11-30";
    owner  = "huandu";
    repo   = "xstrings";
    sha256 = "16l1cqpqsgipa4c6q55n8vlnpg9kbylkx1ix8hsszdikj25mcig1";
  };

  zappy = buildFromGitHub {
    version = 1;
    date = "2016-07-23";
    rev = "2533cb5b45cc6c07421468ce262899ddc9d53fb7";
    owner = "cznic";
    repo = "zappy";
    sha256 = "1fn4kqiggz6b5srkqhn37nwsi381x6hx3n83cbg0fxcb7zb3b6xl";
    buildInputs = [
      mathutil
    ];
    extraSrcs = [
      {
        inherit (internal)
          goPackagePath
          src;
      }
    ];
  };
}; in self

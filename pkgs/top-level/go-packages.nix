/* This file defines the composition for Go packages. */

{ stdenv
, buildGoPackage
, fetchbzr
, fetchFromBitbucket
, fetchFromGitHub
, fetchgit
, fetchhg
, fetchTritonPatch
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
        --no-acls --no-selinux --no-xattrs \
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
    rev = "267c27e7492265b84fc6719503b14a1e17975d79";
    date = "2016-06-20";
    owner = "golang";
    repo = "appengine";
    sha256 = "0i121rgyw3sbybg6qbhrr7nrvlka221a990zf64n4ghmdzgm5kw4";
    goPackagePath = "google.golang.org/appengine";
    propagatedBuildInputs = [
      protobuf
      net
    ];
  };

  crypto = buildFromGitHub {
    rev = "911fafb28f4ee7c7bd483539a6c96190bbbccc3f";
    date = "2016-05-09";
    owner    = "golang";
    repo     = "crypto";
    sha256 = "0z447ipqf32fpj2wjr2nvd3xl0jyrh6f9a8ymy8jp9v57j36c4ib";
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

  net = buildFromGitHub {
    rev = "3797cd8864994d713d909eda5e61ede8683fdc12";
    date = "2016-07-16";
    owner  = "golang";
    repo   = "net";
    sha256 = "09jciqi3vjap271y1nrg2q654qkgnbyhw92v4wsqc0vl73haz9pp";
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
    rev = "12e1e986157ec46fb273824565d9937bd4235105";
    date = "2016-07-18";
    owner = "golang";
    repo = "oauth2";
    sha256 = "047zcxszyxk7016v46ssc9xm15b240gvvnp3iysn62g8vwgz6lpc";
    goPackagePath = "golang.org/x/oauth2";
    goPackageAliases = [ "github.com/golang/oauth2" ];
    propagatedBuildInputs = [ net gcloud-golang-compute-metadata ];
  };


  protobuf = buildFromGitHub {
    rev = "874264fbbb43f4d91e999fecb4b40143ed611400";
    date = "2016-07-11";
    owner = "golang";
    repo = "protobuf";
    sha256 = "0aqwq10vvx9wb40gfwd99jy4ih7q16qr3r0l0iwlbg6yjh3nrn4i";
    goPackagePath = "github.com/golang/protobuf";
    goPackageAliases = [
      "code.google.com/p/goprotobuf"
    ];
  };

  snappy = buildFromGitHub {
    rev = "d9eb7a3d35ec988b8585d4a0068e462c27d28380";
    date = "2016-05-29";
    owner  = "golang";
    repo   = "snappy";
    sha256 = "1z7xwm1w0nh2p6gdp0cg6hvzizs4zjn43c7vrm1fmf3sdvp6pxnw";
    goPackageAliases = [ "code.google.com/p/snappy-go/snappy" ];
  };

  sys = buildFromGitHub {
    rev = "a646d33e2ee3172a661fc09bca23bb4889a41bc8";
    date = "2016-07-15";
    owner  = "golang";
    repo   = "sys";
    sha256 = "0lcxx9gp11zjl2qgrdjn6ha160w3dv5zjf9n8vi6sx4isf2rpj7w";
    goPackagePath = "golang.org/x/sys";
    goPackageAliases = [
      "github.com/golang/sys"
    ];
  };

  text = buildFromGitHub {
    rev = "0a5a09ee4409a616bfa03115120f0bffacdff508";
    date = "2016-07-19";
    owner = "golang";
    repo = "text";
    sha256 = "1j09cv4y2zsrdvjfa0glw0i46h25f84mxbzm7zsknxdpnzc83nwh";
    goPackagePath = "golang.org/x/text";
    goPackageAliases = [ "github.com/golang/text" ];
  };

  tools = buildFromGitHub {
    rev = "d4a8e583a10c1e702d1accc9e66c104f992115c8";
    date = "2016-07-19";
    owner = "golang";
    repo = "tools";
    sha256 = "0rg6x12plw5z48y1llnl4b2nhnk2cwvdas8cyy6fnsapm0viivmj";
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
    owner = "yosssi";
    repo = "ace";
    rev = "71afeb714739f9d5f7e1849bcd4a0a5938e1a70d";
    date = "2016-01-02";
    sha256 = "1alfpk0wa73bxpl5g2my7xbimxqii7l24znm5b2cn0307qj0pclz";
    buildInputs = [
      gohtml
    ];
  };

  afero = buildFromGitHub {
    owner = "spf13";
    repo = "afero";
    rev = "1a8ecf8b9da1fb5306e149e83128fc447957d2a8";
    date = "2016-06-06";
    sha256 = "0987ijvvzba5xwkkiwp89czsp1s0sfaiv4nnsd0yvlf2zswp2zbk";
    propagatedBuildInputs = [
      sftp
      text
    ];
  };

  amber = buildFromGitHub {
    owner = "eknkc";
    repo = "amber";
    rev = "91774f050c1453128146169b626489e60108ec03";
    date = "2016-04-21";
    sha256 = "0mimywnfvvjkvpyda48qr1xqijkz5k5qinf9qcwzydahjmif7j7q";
  };

  ansicolor = buildFromGitHub {
    date = "2015-11-20";
    rev = "a422bbe96644373c5753384a59d678f7d261ff10";
    owner  = "shiena";
    repo   = "ansicolor";
    sha256 = "1qfq4ax68d7a3ixl60fb8kgyk0qx0mf7rrk562cnkpgzrhkdcm0w";
  };

  asciinema = buildFromGitHub {
    rev = "v1.3.0";
    owner  = "asciinema";
    repo   = "asciinema";
    sha256 = "03dznhwa2wxyqdhjkjrjmlw185kx8bi29cn2hb1zlq27nqsfv5ly";
  };

  asn1-ber = buildFromGitHub {
    rev = "v1.1";
    owner  = "go-asn1-ber";
    repo   = "asn1-ber";
    sha256 = "1mi96bl0jn3nrp4v5aqxgqf5zdndif1qdhdjgjayigjkl67770s3";
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
    rev = "v1.2.6";
    owner  = "aws";
    repo   = "aws-sdk-go";
    sha256 = "0nw8zd2375xpd4baf2sbijcyh9y90byclp9xms83q7yjp2mbgbhw";
    buildInputs = [ testify gucumber tools ];
    propagatedBuildInputs = [ ini go-jmespath ];

    preBuild = ''
      pushd go/src/$goPackagePath
      make generate
      popd
    '';
  };

  azure-sdk-for-go = buildFromGitHub {
    date = "2016-07-05";
    rev = "58a13e378daf3b06e65925397185684b16321111";
    owner  = "Azure";
    repo   = "azure-sdk-for-go";
    sha256 = "0g92xrlb6n59x159fwlfki7mscxxbwp0v0hpg5izgp7kflyrv05x";
    buildInputs = [
      go-autorest
    ];
  };

  b = buildFromGitHub {
    date = "2016-07-16";
    rev = "bcff30a622dbdcb425aba904792de1df606dab7c";
    owner  = "cznic";
    repo   = "b";
    sha256 = "0zjr4spbgavwq4lvxzl3h8hrkbyjk49vq14jncpydrjw4a9qql95";
  };

  bigfft = buildFromGitHub {
    date = "2013-09-13";
    rev = "a8e77ddfb93284b9d58881f597c820a2875af336";
    owner = "remyoudompheng";
    repo = "bigfft";
    sha256 = "1cj9zyv3shk8n687fb67clwgzlhv47y327180mvga7z741m48hap";
  };

  blackfriday = buildFromGitHub {
    owner = "russross";
    repo = "blackfriday";
    rev = "1d6b8e9301e720b08a8938b8c25c018285885438";
    sha256 = "1cc7mqmgj55k3sz79iff3b4s7vjgf5afjqrdlm218wyjsszihq8k";
    propagatedBuildInputs = [
      sanitized-anchor-name
    ];
    date = "2016-05-31";
  };

  bolt = buildFromGitHub {
    rev = "v1.2.1";
    owner  = "boltdb";
    repo   = "bolt";
    sha256 = "1fm23v09n43f61pzkd0znl9nwlss8kj076pqycsj7vq1bjf1lw0v";
  };

  btree = buildFromGitHub {
    rev = "7d79101e329e5a3adf994758c578dab82b90c017";
    owner  = "google";
    repo   = "btree";
    sha256 = "0ky9a9r1i3awnjisk8bkw4d9v5jkcm9w6sphd889vxdhvizvkskl";
    date = "2016-05-24";
  };

  bufs = buildFromGitHub {
    date = "2014-08-18";
    rev = "3dcccbd7064a1689f9c093a988ea11ac00e21f51";
    owner  = "cznic";
    repo   = "bufs";
    sha256 = "0551h2slsb7lg3r6yif65xvf6k8f0izqwyiigpipm3jhlln37c6p";
  };

  candiedyaml = buildFromGitHub {
    date = "2016-04-29";
    rev = "99c3df83b51532e3615f851d8c2dbb638f5313bf";
    owner  = "cloudfoundry-incubator";
    repo   = "candiedyaml";
    sha256 = "104giv2wjiispfsm82q3lk5qjvfjgrqhhnxm2yma9i21klmvir0y";
  };

  cast = buildFromGitHub {
    owner = "spf13";
    repo = "cast";
    rev = "27b586b42e29bec072fe7379259cc719e1289da6";
    date = "2016-03-03";
    sha256 = "1b2wmjq68h6g2g8b9yjnip26xkyqfnqppnmaixlpk43hakhxxggf";
    buildInputs = [
      jwalterweatherman
    ];
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

  mitchellh_cli = buildFromGitHub {
    date = "2016-03-23";
    rev = "168daae10d6ff81b8b1201b0a4c9607d7e9b82e3";
    owner = "mitchellh";
    repo = "cli";
    sha256 = "1ihlx94djy3npy88kv1ahsgk4vh4jchsgmyj2pkrawf8chf1i4v3";
    propagatedBuildInputs = [ crypto go-radix speakeasy go-isatty ];
  };

  urfave_cli = buildFromGitHub {
    rev = "v1.18.0";
    owner = "urfave";
    repo = "cli";
    sha256 = "1s25rph38nkmb78v0faackklrfjqvqwl3md5nci0qlb1wvfb1f7c";
    goPackageAliases = [
      "github.com/codegangsta/cli"
    ];
    buildInputs = [
      yaml-v2
    ];
  };

  cobra = buildFromGitHub {
    owner = "spf13";
    repo = "cobra";
    rev = "6a8bd97bdb1fc0d08a83459940498ea49d3e8c93";
    date = "2016-06-21";
    sha256 = "13kgjxjm19lv6fxkvbqny4dgzqyqhsx444an9xzr7hm6lzb1g8hc";
    buildInputs = [
      pflag
      viper
    ];
    propagatedBuildInputs = [
      go-md2man
    ];
  };

  colorstring = buildFromGitHub {
    rev = "8631ce90f28644f54aeedcb3e389a85174e067d1";
    owner  = "mitchellh";
    repo   = "colorstring";
    sha256 = "14dgak39642j795miqg5x7sb4ncpjgikn7vvbymxc5azy7z764hx";
    date = "2015-09-17";
  };

  columnize = buildFromGitHub {
    rev = "9b3edd62028f107d7cabb19353292afd29311a4e";
    owner  = "ryanuber";
    repo   = "columnize";
    sha256 = "1j5qis2fc2a3241bmwzkmf7xcmasgh8717g939riizi9nx9n7nls";
    date = "2016-07-12";
  };

  consul = buildFromGitHub {
    rev = "v0.6.4";
    owner = "hashicorp";
    repo = "consul";
    sha256 = "0jvhhzbkdxcqj1jwc2h25qd996g3rv3csjaix14v6hds9nniqyww";

    buildInputs = [
      datadog-go circbuf armon_go-metrics go-radix speakeasy bolt
      go-bindata-assetfs go-dockerclient errwrap go-checkpoint
      go-immutable-radix go-memdb ugorji_go go-multierror go-reap go-syslog
      golang-lru hcl logutils memberlist net-rpc-msgpackrpc raft raft-boltdb
      scada-client yamux muxado dns mitchellh_cli mapstructure columnize
      copystructure hil hashicorp-go-uuid crypto sys
    ];

    propagatedBuildInputs = [
      go-cleanhttp
      serf
    ];

    # Keep consul.ui for backward compatability
    passthru.ui = pkgs.consul-ui;
  };

  consul-api = buildFromGitHub {
    inherit (consul) owner repo;
    date = "2016-07-13";
    rev = "2e2edb3304bc6e2abc678e5a2567424059c1d0ab";
    sha256 = "bb5b458dc958c6adc10cd7e0602e72b239049beda62418ce6b774599fdf60d6e";
    buildInputs = [
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
    rev = "v0.15.0";
    owner = "hashicorp";
    repo = "consul-template";
    sha256 = "04fppwf7hr11s15rgzfpnhgqrwzn6akp9phjrn9gymlp7ak3i4jc";

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

  copystructure = buildFromGitHub {
    date = "2016-06-09";
    rev = "ae8f8315ad044b86ced2e0be9e3598e9dd94f38e";
    owner = "mitchellh";
    repo = "copystructure";
    sha256 = "185c10ab80cn4jxdp915h428lm0r9zf1cqrfsjs71im3w3ankvsn";
    propagatedBuildInputs = [ reflectwalk ];
  };

  cronexpr = buildFromGitHub {
    rev = "f0984319b44273e83de132089ae42b1810f4933b";
    owner  = "gorhill";
    repo   = "cronexpr";
    sha256 = "0d2c67spcyhr4bxzmnqsxnzbn6a8sw893wvc4cx7a3js4ydy7raz";
    date = "2016-03-18";
  };

  crypt = buildFromGitHub {
    owner = "xordataexchange";
    repo = "crypt";
    rev = "749e360c8f236773f28fc6d3ddfce4a470795227";
    date = "2015-05-23";
    sha256 = "0zc00mpvqv7n1pz6fn6570wf9j8dc5d2m49yrqqygs52r2iarpx5";
    propagatedBuildInputs = [
      consul
      crypto
    ];
    patches = [
      (fetchTritonPatch {
       rev = "77ff70bae635d2ac5bae8c647120d336070a579e";
       file = "crypt/crypt-2015-05-remove-etcd-support.patch";
       sha256 = "e942558fc230884e4ddbbafd97f7a3ea56bacdfea90a24f8790d37c399265904";
      })
    ];
    postPatch = ''
      sed -i backend/consul/consul.go \
        -e 's,"github.com/armon/consul-api",consulapi "github.com/hashicorp/consul/api",'
    '';
  };

  cssmin = buildFromGitHub {
    owner = "dchest";
    repo = "cssmin";
    rev = "fb8d9b44afdc258bfff6052d3667521babcb2239";
    date = "2015-12-10";
    sha256 = "1m9zqdaw2qycvymknv6vx2i4jlpdj6lcjysxd18czbf5kp6pcri4";
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

  dns = buildFromGitHub {
    rev = "5d001d020961ae1c184f9f8152fdc73810481677";
    date = "2016-06-14";
    owner  = "miekg";
    repo   = "dns";
    sha256 = "0vb4cjlb05znl81byk46v7jc4hwln1qxsbbzq8siwxhxr3d7p5ck";
  };

  weppos-dnsimple-go = buildFromGitHub {
    rev = "65c1ca73cb19baf0f8b2b33219b7f57595a3ccb0";
    date = "2016-02-04";
    owner  = "weppos";
    repo   = "dnsimple-go";
    sha256 = "0v3vnp128ybzmh4fpdwhl6xmvd815f66dgdjzxarjjw8ywzdghk9";
  };

  docker = buildFromGitHub {
    rev = "v1.11.2";
    owner = "docker";
    repo = "docker";
    sha256 = "1ycf0gj3whpjbalskshb2k4qblhdj8pqb8fji1h1wsqhabsnrz6x";
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
    rev = "0.6.2";
    owner  = "docopt";
    repo   = "docopt-go";
    sha256 = "11cxmpapg7l8f4ar233f3ybvsir3ivmmbg1d4dbnqsr1hzv48xrf";
  };

  duo_api_golang = buildFromGitHub {
    date = "2016-06-24";
    rev = "60cf4266ffce4f3d8b332fb4af4558c8383dc970";
    owner = "duosecurity";
    repo = "duo_api_golang";
    sha256 = "1k865gc1x14fmlx2i0g19iwbj09zfkjxmdws8pzxzdns5dvxwbp4";
  };

  emoji = buildFromGitHub {
    owner = "kyokomi";
    repo = "emoji";
    rev = "v1.4";
    sha256 = "1k87kd0h4qk2klbxx3r86g07wk9mgrb0jhdj8kgd2hlgh45j4pd2";
  };

  envpprof = buildFromGitHub {
    rev = "0383bfe017e02efb418ffd595fc54777a35e48b0";
    owner = "anacrolix";
    repo = "envpprof";
    sha256 = "0i9d021hmcfkv9wv55r701p6j6r8mj55fpl1kmhdhvar8s92rjgl";
    date = "2016-05-28";
  };

  du = buildFromGitHub {
    rev = "v1.0.0";
    owner  = "calmh";
    repo   = "du";
    sha256 = "02gri7xy9wp8szxpabcnjr18qic6078k213dr5k5712s1pg87qmj";
  };

  errors = buildFromGitHub {
    owner = "pkg";
    repo = "errors";
    rev = "v0.7.0";
    sha256 = "0nshc2ziy81cmnj8gv0v28875bk2q49kv5cqa04zk87kmh6bvkfj";
  };

  errwrap = buildFromGitHub {
    date = "2014-10-27";
    rev = "7554cd9344cec97297fa6649b055a8c98c2a1e55";
    owner  = "hashicorp";
    repo   = "errwrap";
    sha256 = "02hsk2zbwg68w62i6shxc0lhjxz20p3svlmiyi5zjz988qm3s530";
  };

  etcd = buildFromGitHub {
    owner = "coreos";
    repo = "etcd";
    rev = "v3.0.2";
    sha256 = "13pvlhvc7picfp58wcdd9k17g07l71d1rmkmhl34gdg47r9rnq26";
    buildInputs = [
      pkgs.libpcap
      tablewriter
    ];
  };

  etcd-client = buildFromGitHub {
    inherit (etcd) rev owner repo sha256;
    subPackages = [
      "client"
      "pkg/fileutil"
      "pkg/pathutil"
      "pkg/tlsutil"
      "pkg/transport"
      "pkg/types"
    ];
    buildInputs = [
      ugorji_go
      go-systemd
      net
    ];
    propagatedBuildInputs = [
      pkg
    ];
  };

  exp = buildFromGitHub {
    date = "2016-07-11";
    rev = "888ba4519f76bfc1e26a9b32e52c6775677b36fd";
    owner  = "cznic";
    repo   = "exp";
    sha256 = "1a32kv2wjzz1yfgivrm1bp4hzg878jwfmv9qy9hvdx0kccy7rvpw";
    propagatedBuildInputs = [ bufs fileutil mathutil sortutil zappy ];
  };

  fileutil = buildFromGitHub {
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
    date = "2016-06-27";
    rev = "b6d6c459091af71c7ebb587296936c8dfe79d797";
    owner  = "spacemonkeygo";
    repo   = "flagfile";
    sha256 = "0rqhbijrp7i136pay3q6zp54rv29nzjbvw76i4ycalqd2kg22r7s";
  };

  fs = buildFromGitHub {
    date = "2013-11-07";
    rev = "2788f0dbd16903de03cb8186e5c7d97b69ad387b";
    owner  = "kr";
    repo   = "fs";
    sha256 = "16ygj65wk30cspvmrd38s6m8qjmlsviiq8zsnnvkhfy5l0gk4c86";
  };

  fsnotify = buildFromGitHub {
    owner = "fsnotify";
    repo = "fsnotify";
    rev = "v1.3.0";
    sha256 = "1gazf2b3srhr8i9dxisjq9pf71ln5qcbcfknics31rc1d1sii2hy";
    propagatedBuildInputs = [
      sys
    ];
  };

  fsync = buildFromGitHub {
    owner = "spf13";
    repo = "fsync";
    rev = "eefee59ad7de621617d4ff085cf768aab4b919b1";
    date = "2016-03-01";
    sha256 = "1qakm902mpdikkz7fngxvy6xczq7mvcmj0dkz6gr20h9l7h95lnh";
    buildInputs = [
      afero
    ];
  };

  gateway = buildFromGitHub {
    date = "2016-05-22";
    rev = "edad739645120eeb82866bc1901d3317b57909b1";
    owner  = "calmh";
    repo   = "gateway";
    sha256 = "0gzwns51jl2jm62ii99c7caa9p7x2c8p586q1cjz8bpv2mcd8njg";
    goPackageAliases = [
      "github.com/jackpal/gateway"
    ];
  };

  gcloud-golang = buildFromGitHub {
    rev = "6b0a9a7885816ca5868f56f4be1abbe98c6e1f37";
    owner = "GoogleCloudPlatform";
    repo = "gcloud-golang";
    sha256 = "17bd8bgpzippn4hyhdpx7whd8kkwxp05vyna28yj959kx98xkxj9";
    goPackagePath = "google.golang.org/cloud";
    propagatedBuildInputs = [
      net
      oauth2
      protobuf
      google-api-go-client
      grpc
    ];
    excludedPackages = "oauth2";
    meta.hydraPlatforms = [ ];
    date = "2016-07-14";
  };

  gcloud-golang-for-go4 = buildFromGitHub {
    inherit (gcloud-golang) rev owner repo sha256 date goPackagePath;
    subPackages = [
      "storage"
    ];
    propagatedBuildInputs = [
      google-api-go-client
      grpc
      net
      oauth2
    ];
  };

  gcloud-golang-compute-metadata = buildFromGitHub {
    inherit (gcloud-golang) rev owner repo sha256 date goPackagePath;
    subPackages = [ "compute/metadata" "internal" ];
    buildInputs = [ net ];
  };

  geoip2-golang = buildFromGitHub {
    rev = "51714a0e79df40e00a94ae5086ec2a5532c9ee57";
    owner = "oschwald";
    repo = "geoip2-golang";
    sha256 = "1ckw7s0p5pw337g2km0cixz73bfph9sj3akk7ynnf522fiyf7lcs";
    date = "2016-07-03";
    propagatedBuildInputs = [
      maxminddb-golang
    ];
  };

  gettext = buildFromGitHub {
    rev = "305f360aee30243660f32600b87c3c1eaa947187";
    owner = "gosexy";
    repo = "gettext";
    sha256 = "0s1f99llg462mbcdmg2yp8l6ifq56v6qp8bw33ng5yrws91xflj7";
    date = "2016-06-02";
    buildInputs = [
      go-flags
      go-runewidth
    ];
  };

  ginkgo = buildFromGitHub {
    rev = "7d3240191d7b2311b60090fcbc96e56bffc45ec0";
    owner = "onsi";
    repo = "ginkgo";
    sha256 = "11j2yn2894krxk4xg4a4mwd1qp7mf9myjfjq69asx9kanif7gmqd";
    date = "2016-07-15";
  };

  glob = buildFromGitHub {
    rev = "0.2.0";
    owner = "gobwas";
    repo = "glob";
    sha256 = "1lbijdwchj6v7qpy9mr0xzs3v2y868vrmsxk1y24dm6wpacz50jd";
  };

  ugorji_go = buildFromGitHub {
    date = "2016-05-31";
    rev = "b94837a2404ab90efe9289e77a70694c355739cb";
    owner = "ugorji";
    repo = "go";
    sha256 = "0419rraxl5hwpwmwf6ac5201as1456r128llwa49qnl3jg4s98rz";
    goPackageAliases = [ "github.com/hashicorp/go-msgpack" ];
  };

  go4 = buildFromGitHub {
    date = "2016-06-27";
    rev = "85455cb60c902182109ca27131042a41bc4cb85d";
    owner = "camlistore";
    repo = "go4";
    sha256 = "917b644c6b5b884c3beb512e20cde5599623849f9dc32b23081c000caf1f5ddd";
    goPackagePath = "go4.org";
    goPackageAliases = [ "github.com/camlistore/go4" ];
    buildInputs = [
      gcloud-golang-for-go4
      oauth2
      net
      sys
    ];
    autoUpdatePath = "github.com/camlistore/go4";
  };

  goamz = buildFromGitHub {
    rev = "ff7846e9c73d32649a7f2d77728c7d6984fde108";
    owner  = "goamz";
    repo   = "goamz";
    sha256 = "066n5w19kd0ifc2spyhhf4jjhvsygp3ynb180viv1v6ij90p42ac";
    date = "2016-07-15";
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

  gocapability = buildFromGitHub {
    rev = "2c00daeb6c3b45114c80ac44119e7b8801fdd852";
    owner = "syndtr";
    repo = "gocapability";
    sha256 = "0kwcqvj2fq6wl453hcc3q4fmyrv3yk9m3igxwksx9rmpnzaclz8r";
    date = "2015-07-16";
  };

  gocql = buildFromGitHub {
    rev = "9924437647a7cd58f0c79c07d7d5ecf3cc8aa1fa";
    owner  = "gocql";
    repo   = "gocql";
    sha256 = "0jrm4bynkjl8i08bhqpf7lsian8lwm6g777z1radvgqzxsqfgr2s";
    propagatedBuildInputs = [ inf snappy hailocab_go-hostpool net ];
    date = "2016-07-14";
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
    rev = "66a3de92def23708184148ae337750915875e7c1";
    owner  = "xeipuuv";
    repo   = "gojsonschema";
    sha256 = "0j0m0rhkckagbilh0h2fh4vwxn4iccny8rva8p08m8mq4jandya5";
    date = "2016-07-08";
    propagatedBuildInputs = [ gojsonreference ];
  };

  govers = buildFromGitHub {
    rev = "77fd787551fc5e7ae30696e009e334d52d2d3a43";
    date = "2016-06-23";
    owner = "rogpeppe";
    repo = "govers";
    sha256 = "07kf02gg1i1bnyl0k4rl2ylfb3pdj0gkggmcg9ivd6m1r50f8lvp";
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
    rev = "24f8e34b1e915c4a22aab6c5d6903e549ba9fbb8";
    owner  = "dustinkirkland";
    repo   = "golang-petname";
    sha256 = "1cdf7h9cpig19gisp81nq97865vxm4z91s2w8bqymkc1g8ijqxdq";
    date = "2016-06-27";
  };

  golang_protobuf_extensions = buildFromGitHub {
    rev = "v1.0.0";
    owner  = "matttproud";
    repo   = "golang_protobuf_extensions";
    sha256 = "0r1sv4jw60rsxy5wlnr524daixzmj4n1m1nysv4vxmwiw9mbr6fm";
    buildInputs = [ protobuf ];
  };

  goleveldb = buildFromGitHub {
    rev = "ab8b5dcf1042e818ab68e770d465112a899b668e";
    date = "2016-06-29";
    owner = "syndtr";
    repo = "goleveldb";
    sha256 = "09v30rj91dgkvwqc4kq62xkcdkx5krxkhq0x2bjhv9vd0i54ysly";
    propagatedBuildInputs = [ ginkgo gomega snappy ];
  };

  gomega = buildFromGitHub {
    rev = "9ed8da19f2156b87a803a8fdf6d126f627a12db1";
    owner  = "onsi";
    repo   = "gomega";
    sha256 = "19z52787qf4bd99wd71qysvkpgahz6lhkxy690djh3pyxph4c9h7";
    propagatedBuildInputs = [
      protobuf
      yaml-v2
    ];
    date = "2016-07-18";
  };

  google-api-go-client = buildFromGitHub {
    rev = "1f15007067029efc20c6f09037b4f489312c634f";
    date = "2016-07-19";
    owner = "google";
    repo = "google-api-go-client";
    sha256 = "0dzgvdg7nr358dnkfy3wh04bflm5pifvfjkv7p024rywcsziri3b";
    goPackagePath = "google.golang.org/api";
    goPackageAliases = [
      "github.com/google/google-api-client"
    ];
    buildInputs = [
      grpc
      net
      oauth2
    ];
  };

  gopass = buildFromGitHub {
    date = "2016-03-03";
    rev = "66487b23f2880ba32e185121d2cd51a338ea069a";
    owner = "howeyc";
    repo = "gopass";
    sha256 = "0r4kx80hq48fkipz4x7hkiqb74hygpja1h5xbzydaw4cdgc5vwjs";
    propagatedBuildInputs = [ crypto ];
  };

  gopsutil = buildFromGitHub {
    rev = "v2.1";
    owner  = "shirou";
    repo   = "gopsutil";
    sha256 = "1bq3fpw0jpjnkla2krf9i612v8k4kyfm0g1z7maikrnxhfiza4lc";
  };

  goskiplist = buildFromGitHub {
    rev = "2dfbae5fcf46374f166f8969cb07e167f1be6273";
    owner  = "ryszard";
    repo   = "goskiplist";
    sha256 = "1dr6n2w5ikdddq9c1fwqnc0m383p73h2hd04302cfgxqbnymabzq";
    date = "2015-03-12";
  };

  govalidator = buildFromGitHub {
    rev = "df81827fdd59d8b4fb93d8910b286ab7a3919520";
    owner = "asaskevich";
    repo = "govalidator";
    sha256 = "0bhnv6fd6msyi7y258jkrqr28gmnc34aj5fxii85494di8g2ww5z";
    date = "2016-05-19";
  };

  go-autorest = buildFromGitHub {
    rev = "v7.0.6";
    owner  = "Azure";
    repo   = "go-autorest";
    sha256 = "0fqd3il0plga5n5drwkiwyjc2vrxgxnwmj8k3gy65gal7fhan585";
    propagatedBuildInputs = [
      crypto
      jwt-go
    ];
  };

  go-base58 = buildFromGitHub {
    rev = "1.0.0";
    owner  = "jbenet";
    repo   = "go-base58";
    sha256 = "0sbss2611iri3mclcz3k9b7kw2sqgwswg4yxzs02vjk3673dcbh2";
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

  go-bindata-assetfs = buildFromGitHub {
    rev = "57eb5e1fc594ad4b0b1dbea7b286d299e0cb43c2";
    owner   = "elazarl";
    repo    = "go-bindata-assetfs";
    sha256 = "0kr3jz9lfivm0q9lsl6zpa4i02qa79304kn059skr0dnsnizj2q7";
    date = "2015-12-24";
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
    rev = "v0.0.5";
    owner  = "mattn";
    repo   = "go-colorable";
    sha256 = "1cj5wp5b0c5xg6hd5v9207b47aysji2zyg7zcs3z4rimzhnlbbnc";
  };

  go-difflib = buildFromGitHub {
    date = "2016-01-10";
    rev = "792786c7400a136282c1664665ae0a8db921c6c2";
    owner  = "pmezard";
    repo   = "go-difflib";
    sha256 = "0xhjjfvx97zkms5004v1k3prc5g1kljiayhf05v0n0yf89s5r28r";
  };

  go-dockerclient = buildFromGitHub {
    date = "2016-07-12";
    rev = "3213df8880de560ee41e30dbc6605eb04b1f80a4";
    owner = "fsouza";
    repo = "go-dockerclient";
    sha256 = "158bs0sv5pww6qrxfmz2vbkx04f0qrjsl76xicqs9l20x3bswrdl";
    propagatedBuildInputs = [
      docker_for_go-dockerclient
      go-cleanhttp
      mux
    ];
  };

  go-flags = buildFromGitHub {
    date = "2016-06-26";
    rev = "f2785f5820ec967043de79c8be97edfc464ca745";
    owner  = "jessevdk";
    repo   = "go-flags";
    sha256 = "0hv9z1xny18f1pn0424gafzpn1hjkgphsvd91jnjghnx904ghrpg";
  };

  go-getter = buildFromGitHub {
    rev = "3d6040e1c4b972f6634c5aafb08901f916c5ee3c";
    date = "2016-06-03";
    owner = "hashicorp";
    repo = "go-getter";
    sha256 = "0msy19c1gnrqbfrg2yc298ysdy8fiw6q2j6db35cm9698bcfc078";
    propagatedBuildInputs = [
      aws-sdk-go
    ];
  };

  go-git-ignore = buildFromGitHub {
    rev = "228fcfa2a06e870a3ef238d54c45ea847f492a37";
    date = "2016-01-15";
    owner = "sabhiram";
    repo = "go-git-ignore";
    sha256 = "1a78b1as3xd2v3lawrb0y43bm3rmb452mysvzqk1309gw51lk4gx";
  };

  go-github = buildFromGitHub {
    date = "2016-06-17";
    rev = "1c08387e4c91df86627d0853f155a4efc8cb8a2d";
    owner = "google";
    repo = "go-github";
    sha256 = "6a0b97eee6a54c188f8de2b46b2b8ea2ed5632aaebdaba6e7e8a331ea729f852";
    buildInputs = [ oauth2 ];
    propagatedBuildInputs = [ go-querystring ];
    meta.autoUpdate = false;
  };

  go-homedir = buildFromGitHub {
    date = "2016-06-21";
    rev = "756f7b183b7ab78acdbbee5c7f392838ed459dda";
    owner  = "mitchellh";
    repo   = "go-homedir";
    sha256 = "0lacs15dkbs9ag6mdq5xg4w72g7m8p4042f7z4lrnk3r36c53zjq";
  };

  hailocab_go-hostpool = buildFromGitHub {
    rev = "e80d13ce29ede4452c43dea11e79b9bc8a15b478";
    date = "2016-01-25";
    owner  = "hailocab";
    repo   = "go-hostpool";
    sha256 = "06ic8irabl0iwhmkyqq4wzq1d4pgp9vk1kmflgv1wd5d9q8qmkgf";
  };

  go-humanize = buildFromGitHub {
    rev = "fef948f2d241bd1fd0631108ecc2c9553bae60bf";
    owner = "dustin";
    repo = "go-humanize";
    sha256 = "19fsp2g44dn084dbsn2zmc2p4chmnwmsv1lyxp7hjks2pgb65vcm";
    date = "2016-06-23";
  };

  go-immutable-radix = buildFromGitHub {
    date = "2016-06-08";
    rev = "afc5a0dbb18abdf82c277a7bc01533e81fa1d6b8";
    owner = "hashicorp";
    repo = "go-immutable-radix";
    sha256 = "1yyhag8vnr7vi4ak2rkd651k9h8221dpdsqpva95zvf9nycgzlsd";
    propagatedBuildInputs = [ golang-lru ];
  };

  go-ini = buildFromGitHub {
    rev = "a98ad7ee00ec53921f08832bc06ecf7fd600e6a1";
    owner = "vaughan0";
    repo = "go-ini";
    sha256 = "07i40hj47z5m6wa5bzy7sc2na3hbwh84ridl40yfybgdlyrzdkf4";
    date = "2013-09-23";
  };

  go-ipfs-api = buildFromGitHub {
    rev = "v1.0.0";
    owner  = "ipfs";
    repo   = "go-ipfs-api";
    sha256 = "0c54r9g10rcnrm9rzj815gjkcgmr5z3pjgh3b4b19vbsgm2rx7hf";
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
    rev = "v1.0.2";
    owner = "square";
    repo = "go-jose";
    sha256 = "0pp117a464kj8br9pqk9xha87plndfg8mhfc9k1bq0v4qs7awyiq";
    goPackagePath = "gopkg.in/square/go-jose.v1";
    goPackageAliases = [
      "github.com/square/go-jose"
    ];
    buildInputs = [
      urfave_cli
      kingpin-v2
    ];
  };

  go-lxc-v2 = buildFromGitHub {
    rev = "7b26a5beacfc2598c491cfa0863dfe362e039083";
    owner  = "lxc";
    repo   = "go-lxc";
    sha256 = "16klgb5qwzkzmpj560jbylx2ik3lqc71i1l86a207000kzlry4db";
    goPackagePath = "gopkg.in/lxc/go-lxc.v2";
    buildInputs = [ pkgs.lxc ];
    date = "2016-07-08";
  };

  go-lz4 = buildFromGitHub {
    rev = "v1.0.0";
    owner  = "bkaradzic";
    repo   = "go-lz4";
    sha256 = "1bdh2wqp2hh81x00wmsb4px9fzj13jcrdl6w52pabqkr2wyyqwkf";
  };

  go-md2man = buildFromGitHub {
    owner = "cpuguy83";
    repo = "go-md2man";
    rev = "v1.0.5";
    sha256 = "06kr1j092afkz609mrzbdcgl9lzw4z0ry32jfv8q2c8f4lmjk8lx";
    propagatedBuildInputs = [
      blackfriday
    ];
  };

  go-memdb = buildFromGitHub {
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
    rev = "bdb33529eca3e55eac7328e07c57012a797af602";
    date = "2016-07-18";
    owner = "rcrowley";
    repo = "go-metrics";
    sha256 = "1p981khvpll9j50vd7n5czicmk2nnb9rbmhbyr5wivqr0qlx3c07";
    propagatedBuildInputs = [ stathat ];
  };

  armon_go-metrics = buildFromGitHub {
    date = "2016-05-20";
    rev = "fbf75676ee9c0a3a23eb0a4d9220a3612cfbd1ed";
    owner = "armon";
    repo = "go-metrics";
    sha256 = "0wrkka9y0w8arfy08aghawwxxj36cgm6i0dw9ri6vhbb821nfar0";
    propagatedBuildInputs = [ prometheus_client_golang datadog-go ];
  };

  go-mssqldb = buildFromGitHub {
    rev = "c5885153c18c8e4cdde7608f3fa65c2df212d3cb";
    owner = "denisenkom";
    repo = "go-mssqldb";
    sha256 = "1kjkan9qrc1kz7i30kwvg62fy60n4wxsm50ijw2s4fyjf1bc1rbd";
    date = "2016-06-23";
    buildInputs = [ crypto ];
  };

  go-multiaddr = buildFromGitHub {
    rev = "f3dff105e44513821be8fbe91c89ef15eff1b4d4";
    date = "2016-05-09";
    owner  = "jbenet";
    repo   = "go-multiaddr";
    sha256 = "0qdma38d4bmib063hh899h2491kgzgg16kgqdvypncchawq8nqlj";
    propagatedBuildInputs = [
      go-multihash
    ];
  };

  go-multiaddr-net = buildFromGitHub {
    rev = "d4cfd691db9f50e430528f682ca603237b0eaae0";
    owner  = "jbenet";
    repo   = "go-multiaddr-net";
    sha256 = "0nwqaqfn30qxhwa0v2sbxankkj41krbwd30bp92y0xrkz5ivvi16";
    date = "2016-05-16";
    propagatedBuildInputs = [
      go-multiaddr
      utp
    ];
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
    rev = "dfd3350f10a27ba2cfcd0e5e2d12c43a69f6e408";
    owner  = "jbenet";
    repo   = "go-multihash";
    sha256 = "0bc8k9l4920c48dr6ivpvdrlh3zkdy60714lmpsyrgiadqyhi3cx";
    propagatedBuildInputs = [ go-base58 crypto ];
    date = "2016-06-21";
  };

  go-multipart-files = buildFromGitHub {
    rev = "3be93d9f6b618f2b8564bfb1d22f1e744eabbae2";
    owner  = "whyrusleeping";
    repo   = "go-multipart-files";
    sha256 = "0fdzi6v6rshh172hzxf8v9qq3d36nw3gc7g7d79wj88pinnqf5by";
    date = "2015-09-03";
  };

  go-nat-pmp = buildFromGitHub {
    rev = "452c97607362b2ab5a7839b8d1704f0396b640ca";
    owner  = "AudriusButkevicius";
    repo   = "go-nat-pmp";
    sha256 = "0jjwqvanxxs15nhnkdx0mybxnyqm37bbg6yy0jr80czv623rp2bk";
    date = "2016-05-22";
    buildInputs = [
      gateway
    ];
  };

  go-ole = buildFromGitHub {
    rev = "v1.2.0";
    owner  = "go-ole";
    repo   = "go-ole";
    sha256 = "1bkvi5l2sshjrg1g9x1a4i337adrv1vhk8p1xrkx5z05nfwazvx0";
  };

  go-os-rename = buildFromGitHub {
    rev = "3ac97f61ef67a6b87b95c1282f6c317ed0e693c2";
    owner  = "jbenet";
    repo   = "go-os-rename";
    sha256 = "0y8rq0y654lcyl7ysijni75j8fpq4hhqnh9qiy2z4hvmnzvb85id";
    date = "2015-04-28";
  };

  go-plugin = buildFromGitHub {
    rev = "8cf118f7a2f0c7ef1c82f66d4f6ac77c7e27dc12";
    date = "2016-06-07";
    owner  = "hashicorp";
    repo   = "go-plugin";
    sha256 = "1mgj52aml4l2zh101ksjxllaibd5r8h1gcgcilmb8p0c3xwf7lvq";
    buildInputs = [ yamux ];
  };

  go-ps = buildFromGitHub {
    rev = "e6c6068076470196af082b1ff896e24a51a87b2a";
    date = "2015-07-10";
    owner  = "mitchellh";
    repo   = "go-ps";
    sha256 = "0cfl9ffgwncki3mfm68dywg588shr151yk5dgfpi8f3p08hbsx8v";
  };

  go-querystring = buildFromGitHub {
    date = "2016-03-10";
    rev = "9235644dd9e52eeae6fa48efd539fdc351a0af53";
    owner  = "google";
    repo   = "go-querystring";
    sha256 = "0c0rmm98vz7sk7z6a1r07dp6jyb513cyr2y753sjpnyrc28xhdwg";
  };

  go-radix = buildFromGitHub {
    rev = "4239b77079c7b5d1243b7b4736304ce8ddb6f0f2";
    owner  = "armon";
    repo   = "go-radix";
    sha256 = "0b5vksrw462w1j5ipsw7fmswhpnwsnaqgp6klw714dc6ppz57aqv";
    date = "2016-01-15";
  };

  go-reap = buildFromGitHub {
    rev = "2d85522212dcf5a84c6b357094f5c44710441912";
    owner  = "hashicorp";
    repo   = "go-reap";
    sha256 = "0q90nf4mgvxb26vd7avs1mw1m9cb6x9mx6jnz4xsia71ghi3lj50";
    date = "2016-01-13";
    propagatedBuildInputs = [ sys ];
  };

  go-rootcerts = buildFromGitHub {
    rev = "6bb64b370b90e7ef1fa532be9e591a81c3493e00";
    owner = "hashicorp";
    repo = "go-rootcerts";
    sha256 = "0wi9ar5av0s4a2xarxh360kml3nkicrcdzzmhq1d406p10c3qjp2";
    date = "2016-05-03";
  };

  go-runewidth = buildFromGitHub {
    rev = "v0.0.1";
    owner = "mattn";
    repo = "go-runewidth";
    sha256 = "1sf0a2fbp2fp0lgizh2bjd3cgni35czvshx5clb2m6b604k7by9a";
  };

  go-simplejson = buildFromGitHub {
    rev = "v0.5.0";
    owner  = "bitly";
    repo   = "go-simplejson";
    sha256 = "09svnkziaffkbax5jjnjfd0qqk9cpai2gphx4ja78vhxdn4jpiw0";
  };

  go-spew = buildFromGitHub {
    rev = "5215b55f46b2b919f50a1df0eaa5886afe4e3b3d";
    date = "2015-11-05";
    owner  = "davecgh";
    repo   = "go-spew";
    sha256 = "1l4dg2xs0vj49gk0f5d4ij3hrwi72ay4w9a7xjkz1syg4qi9jy40";
  };

  go-sqlite3 = buildFromGitHub {
    rev = "38ee283dabf11c9cbdb968eebd79b1fa7acbabe6";
    date = "2016-05-14";
    owner  = "mattn";
    repo   = "go-sqlite3";
    sha256 = "1kahwmicakvkwi2k8mg97b7sfll2v506a50nksv2054x3gxdfw9q";
  };

  go-syslog = buildFromGitHub {
    date = "2015-02-18";
    rev = "42a2b573b664dbf281bd48c3cc12c086b17a39ba";
    owner  = "hashicorp";
    repo   = "go-syslog";
    sha256 = "0zbnlz1l1f50k8wjn8pgrkzdhr6hq4rcbap0asynvzw89crh7h4g";
  };

  go-systemd = buildFromGitHub {
    rev = "d4039021cfc2d0ea21d34afda21631314e83f75a";
    owner = "coreos";
    repo = "go-systemd";
    sha256 = "0drp277m1rwahr0n7i0gpam9s4fawlhgm24547cdggp00fyn7fdy";
    propagatedBuildInputs = [
      dbus
      pkg
      pkgs.systemd_lib
    ];
    date = "2016-07-13";
  };

  go-systemd_journal = buildFromGitHub {
    inherit (go-systemd) rev owner repo sha256 date;
    subPackages = [
      "journal"
    ];
  };

  go-units = buildFromGitHub {
    rev = "v0.3.1";
    owner = "docker";
    repo = "go-units";
    sha256 = "16qsnzrhdnr8p650558p7ml4v0lkxhfign2jkz6nsdx6s4q2gpnc";
  };

  hashicorp-go-uuid = buildFromGitHub {
    rev = "019a056b214daca363b1b78f6aaf0843839efbbc";
    date = "2016-07-11";
    owner  = "hashicorp";
    repo   = "go-uuid";
    sha256 = "113zzsp9lyds24f5wgzry2nyl4yf7mx0fpps1xgj4kh1pxz89ymz";
  };

  go-version = buildFromGitHub {
    rev = "0181db47023708a38c2d20d2fe25a5fa034d5743";
    owner  = "hashicorp";
    repo   = "go-version";
    sha256 = "04kryh7dmz8zwd2kdma119fg6ydw2gm9zr041i8hr6dnjvrrp177";
    date = "2016-05-19";
  };

  go-zookeeper = buildFromGitHub {
    rev = "e64db453f3512cade908163702045e0f31137843";
    date = "2016-06-15";
    owner  = "samuel";
    repo   = "go-zookeeper";
    sha256 = "13rqz6v8q5gncdn5ca25n262slvs46h9grzym43z1wpwdpal4wwv";
  };

  gohtml = buildFromGitHub {
    owner = "yosssi";
    repo = "gohtml";
    rev = "ccf383eafddde21dfe37c6191343813822b30e6b";
    date = "2015-09-23";
    sha256 = "1ccniz4r354r2y4m2dz7ic9nywzi6jffnh44dy6icyqi64v9ydw7";
    propagatedBuildInputs = [
      net
    ];
  };

  groupcache = buildFromGitHub {
    date = "2016-05-15";
    rev = "02826c3e79038b59d737d3b1c0a1d937f71a4433";
    owner  = "golang";
    repo   = "groupcache";
    sha256 = "093p9jiid2c03d02g8fada7bl05244caddd7qjmjs0ggsrardc46";
    buildInputs = [ protobuf ];
  };

  grpc = buildFromGitHub {
    rev = "v1.0.0";
    owner = "grpc";
    repo = "grpc-go";
    sha256 = "1yzis0fs1wjglsc8mvblsbpdjpaak756hby2cbqp3504a9k7cyr9";
    goPackagePath = "google.golang.org/grpc";
    goPackageAliases = [ "github.com/grpc/grpc-go" ];
    propagatedBuildInputs = [ http2 net protobuf oauth2 glog ];
    excludedPackages = "\\(test\\|benchmark\\)";
  };

  gucumber = buildFromGitHub {
    date = "2016-07-14";
    rev = "71608e2f6e76fd4da5b09a376aeec7a5c0b5edbc";
    owner = "gucumber";
    repo = "gucumber";
    sha256 = "0ghz0x1zdm1ypp9ycw871r2rcklik84z7pqgs2i88sk2s4m4igar";
    buildInputs = [ testify ];
    propagatedBuildInputs = [ ansicolor ];
  };

  gx = buildFromGitHub {
    rev = "v0.8.0";
    owner = "whyrusleeping";
    repo = "gx";
    sha256 = "0cvgb25dc85sbpjhnq7549xgp3x6jwiwcs3psvlgvpfd84z7ylpa";
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
    rev = "v1.2.1";
    owner = "whyrusleeping";
    repo = "gx-go";
    sha256 = "1rqwr7hsa3ifrp33s5v3mwl9yjmlqs9iciidibjigmlffkzzxhv9";
    buildInputs = [
      urfave_cli
      fs
      gx
      stump
    ];
  };

  gziphandler = buildFromGitHub {
    date = "2016-04-19";
    rev = "63027b26b87e2ae2ce3810393d4b81021cfd3a35";
    owner = "NYTimes";
    repo = "gziphandler";
    sha256 = "0rqi2hxywqrnxi8q0g0d2qw5a5977jsgh3hmf5ln6yq8255y20vr";
  };

  hashstructure = buildFromGitHub {
    date = "2016-06-09";
    rev = "b098c52ef6beab8cd82bc4a32422cf54b890e8fa";
    owner  = "mitchellh";
    repo   = "hashstructure";
    sha256 = "0zg0q20hzg92xxsfsf2vn1kq044j8l7dh82fm7w7iyv03nwq0cxc";
  };

  hcl = buildFromGitHub {
    date = "2016-07-11";
    rev = "d8c773c4cba11b11539e3d45f93daeaa5dcf1fa1";
    owner  = "hashicorp";
    repo   = "hcl";
    sha256 = "05ahv72a94vfr7cm9w5cqc43dmxha2l9vsx6bqj1xjwjg6jxksjf";
  };

  hil = buildFromGitHub {
    date = "2016-04-08";
    rev = "6215360e5247e7c4bdc317a5f95e3fa5f084a33";
    owner  = "hashicorp";
    repo   = "hil";
    sha256 = "6b3ab530f6980279edb5a1994226adefc377b70aa3e993b5d29c7d498d5cdbd4";
    propagatedBuildInputs = [
      mapstructure
      reflectwalk
    ];
    meta.autoUpdate = false;
  };

  http2 = buildFromGitHub rec {
    rev = "aa7658c0e9902e929a9ed0996ef949e59fc0f3ab";
    owner = "bradfitz";
    repo = "http2";
    sha256 = "10x76xl5b6z2w0mbq7lnx7sl3cbdsp6gc1n3bis9lc0ilclzml65";
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
    owner = "spf13";
    repo = "hugo";
    rev = "v0.16";
    sha256 = "1jf8mwpzggridb3dip0dd1hzbzn0kkajfi5jy9vh3naakxzk11w7";
    buildInputs = [
      ace
      afero
      amber
      blackfriday
      cast
      cobra
      cssmin
      emoji
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
      yaml-v2
    ];
  };

  inf = buildFromGitHub {
    rev = "v0.9.0";
    owner  = "go-inf";
    repo   = "inf";
    sha256 = "0wqf867vifpfa81a1vhazjgfjjhiykqpnkblaxxj6ppyxlzrs3cp";
    goPackagePath = "gopkg.in/inf.v0";
    goPackageAliases = [ "github.com/go-inf/inf" ];
  };

  inflect = buildFromGitHub {
    owner = "bep";
    repo = "inflect";
    rev = "b896c45f5af983b1f416bdf3bb89c4f1f0926f69";
    date = "2016-04-08";
    sha256 = "13mjcnh6g7ml0gw24rbkfdjmkznjk4hcwfbxcbj5ydyfl0acq8wn";
  };

  internal = buildFromGitHub {
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

  ini = buildFromGitHub {
    rev = "v1.18.0";
    owner  = "go-ini";
    repo   = "ini";
    sha256 = "01h10a9vrdyflwwhcawc22wavd0amhgjjmfz0588m1n1r9ra028b";
  };

  iter = buildFromGitHub {
    rev = "454541ec3da2a73fc34fd049b19ee5777bf19345";
    owner  = "bradfitz";
    repo   = "iter";
    sha256 = "0sv6rwr05v219j5vbwamfvpp1dcavci0nwr3a2fgxx98pjw7hgry";
    date = "2014-01-23";
  };

  ipfs = buildFromGitHub {
    date = "2016-07-14";
    rev = "6912f47a446e61f6a4168fc859b0d9ade501a2ca";
    owner = "ipfs";
    repo = "go-ipfs";
    sha256 = "1166ed6d199056157bc11a5560abe3aa3bb717884ddb59f6adc084e1f727f963";
    gxSha256 = "0aq97liijy8xp2g4k8s92jcwazsybwr7idk1x14n2kj33vrlr0rf";

    subPackages = [
      "cmd/ipfs"
    ];
  };

  json-filter = buildFromGitHub {
    owner = "whyrusleeping";
    repo = "json-filter";
    rev = "ff25329a9528f01c5175414f16cc0a6a162a5b8b";
    date = "2016-06-15";
    sha256 = "0y1d6yi09ac0xlf63qrzxsi7dqf10wha3na633qzqjnpjcga97ck";
  };

  jwalterweatherman = buildFromGitHub {
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
    owner = "dgrijalva";
    repo = "jwt-go";
    rev = "v3.0.0";
    sha256 = "0gmxycray168ppybd3g9ic9dvkvlnl1y7rn00gcycsv23phszprz";
  };

  kingpin-v2 = buildFromGitHub {
    rev = "v2.2.0";
    owner = "alecthomas";
    repo = "kingpin";
    goPackagePath = "gopkg.in/alecthomas/kingpin.v2";
    sha256 = "1cx9zvqk7g62ndwig8450jrjdk00hkzl8jml6m253h7vwfn4qavw";
    propagatedBuildInputs = [
      template
      units
    ];
  };

  ldap = buildFromGitHub {
    rev = "v2.4.0";
    owner  = "go-ldap";
    repo   = "ldap";
    sha256 = "1m84am25w01ndb3d2yd0fza8c7gk717c0zvzwkrsb99bi4ivzhka";
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
      urfave_cli
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

  lldb = buildFromGitHub {
    rev = "v1.0.2";
    owner  = "cznic";
    repo   = "lldb";
    sha256 = "01fj61n4gk96g53g29vqfjzrciz9ivn06zcf454frslarnj1g8mg";
    buildInputs = [
      fileutil
      mathutil
      sortutil
      zappy
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
    ];
  };

  log15-v2 = buildFromGitHub {
    rev = "v2.11";
    owner  = "inconshreveable";
    repo   = "log15";
    sha256 = "1krlgq3m0q40y8bgaf9rk7zv0xxx5z92rq8babz1f3apbdrn00nq";
    goPackagePath = "gopkg.in/inconshreveable/log15.v2";
    propagatedBuildInputs = [
      go-colorable
    ];
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
    rev = "lxd-2.0.3";
    owner  = "lxc";
    repo   = "lxd";
    sha256 = "0mizbgv3a982c6h53577drmhv3p7g98fw18p5jmfx4pakbpnj9rh";
    excludedPackages = "test"; # Don't build the binary called test which causes conflicts
    buildInputs = [
      crypto
      gettext
      gocapability
      golang-petname
      go-lxc-v2
      go-sqlite3
      go-systemd
      log15-v2
      pkgs.lxc
      mux
      pborman_uuid
      pongo2-v3
      protobuf
      tablewriter
      tomb-v2
      yaml-v2
      websocket
    ];
  };

  mathutil = buildFromGitHub {
    date = "2016-06-13";
    rev = "78ad7f262603437f0ecfebc835d80094f89c8f54";
    owner = "cznic";
    repo = "mathutil";
    sha256 = "1m3nfvymw912bii4cim0vwcgs1k0fmbmcms6h38aqxh0gkxgd8mq";
    buildInputs = [ bigfft ];
  };

  mapstructure = buildFromGitHub {
    date = "2016-07-12";
    rev = "21a35fb16463dfb7c8eee579c65d995d95e64d1e";
    owner  = "mitchellh";
    repo   = "mapstructure";
    sha256 = "1pxkrnfpba4wnwlrzpx4sydd6cf6ziv600f9zzqx1v7l44p46zsh";
  };

  maxminddb-golang = buildFromGitHub {
    date = "2016-07-09";
    rev = "eccd8d633e8f832af840a3f371f010a521e98b3b";
    owner  = "oschwald";
    repo   = "maxminddb-golang";
    sha256 = "13hyix938q3arxxnbb4ybg2z5jn13021wnizkq250yp1yqp2lnfc";
    propagatedBuildInputs = [
      sys
    ];
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
    date = "2016-06-21";
    rev = "b2053e314b4a87e5f0d2d47aeafd3e03be13da90";
    owner = "hashicorp";
    repo = "memberlist";
    sha256 = "1hkjda75h8zbmq9zy49fdjxgkibs8jwkwif60dlpigcjvwq2307c";
    propagatedBuildInputs = [
      dns
      ugorji_go
      armon_go-metrics
      go-multierror
    ];
  };

  mgo = buildFromGitHub {
    rev = "r2016.02.04";
    owner = "go-mgo";
    repo = "mgo";
    sha256 = "0q968aml9p5x49x70ay7myfg6ibggckir3gam5n6qydj6rviqpy7";
    goPackagePath = "gopkg.in/mgo.v2";
    goPackageAliases = [ "github.com/go-mgo/mgo" ];
    buildInputs = [ pkgs.cyrus-sasl tomb-v2 ];
  };

  missinggo = buildFromGitHub {
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
    inherit (missinggo) rev owner repo sha256 date;
    subPackages = [
      "."
    ];
    propagatedBuildInputs = [
      iter
    ];
    meta.autoUpdate = false;
  };

  mmap-go = buildFromGitHub {
    owner = "edsrzf";
    repo = "mmap-go";
    rev = "935e0e8a636ca4ba70b713f3e38a19e1b77739e8";
    sha256 = "1a9s99gwziamlw2yn7i86wh675ag2bqbp5aa13vf8kl2rfc2p6ma";
    date = "2016-05-12";
  };

  mmark = buildFromGitHub {
    owner = "miekg";
    repo = "mmark";
    rev = "v1.3.4";
    sha256 = "0mpnn6894j6cwvxq29vh3k06jg46swy58ff60i9vjqn942cklkvv";
    buildInputs = [
      toml
    ];
  };

  mongo-tools = buildFromGitHub {
    rev = "r3.3.9";
    owner  = "mongodb";
    repo   = "mongo-tools";
    sha256 = "08s9j5djgw5sj616fcdrhng5hk34ycck2cnn67syj9xdf7p7bqz4";
    buildInputs = [ crypto mgo go-flags gopass openssl tomb-v2 ];

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
    rev = "772320464101e904cd51198160eb4d489be9cc49";
    owner  = "jawher";
    repo   = "mow.cli";
    sha256 = "1dwy7pwh3mig3xj1x8bcd8cm6ilv2581vah9rwi992agx3b8318s";
    date = "2016-02-21";
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
    meta.autoUpdate = false;
  };

  mysql = buildFromGitHub {
    rev = "3654d25ec346ee8ce71a68431025458d52a38ac0";
    owner  = "go-sql-driver";
    repo   = "mysql";
    sha256 = "17kw9n01zks3l76ybrdzib2x9bc1r6rsnnmyl8blw1w216bwd7bz";
    date = "2016-06-02";
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
    rev = "e73bad418fd727ed3a02830b1af1ad0283a1de6c";
    owner  = "vishvananda";
    repo   = "netlink";
    sha256 = "1scc4scd40163x1gzfkgy6a2cpz7jip3fn08zn8cz5kxix0ckk07";
    date = "2016-06-29";
    propagatedBuildInputs = [
      netns
    ];
  };

  netns = buildFromGitHub {
    rev = "8ba1072b58e0c2a240eb5f6120165c7776c3e7b8";
    owner  = "vishvananda";
    repo   = "netns";
    sha256 = "05r4qri45ngm40kp9qdbyqrs15gx7swjj27bmc7i04wg9yd65j95";
    date = "2016-04-30";
  };

  nitro = buildFromGitHub {
    owner = "spf13";
    repo = "nitro";
    rev = "24d7ef30a12da0bdc5e2eb370a79c659ddccf0e8";
    date = "2013-10-03";
    sha256 = "1dbnfac79lxc1pr1j1n3956i292ck4yjrhr8nsd2wp2jccab5zdz";
  };

  nomad = buildFromGitHub {
    rev = "v0.4.0";
    owner = "hashicorp";
    repo = "nomad";
    sha256 = "0e8e87a85140c80e950dd1c5c53566999a4d480c95ad5301d011e03e3455f459";

    buildInputs = [
      gziphandler
      circbuf
      armon_go-metrics
      go-spew
      go-humanize
      go-dockerclient
      cronexpr
      consul-api
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
      raft
      raft-boltdb
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
    ];

    subPackages = [
      "."
    ];
  };

  objx = buildFromGitHub {
    date = "2015-09-28";
    rev = "1a9d0bb9f541897e62256577b352fdbc1fb4fd94";
    owner  = "stretchr";
    repo   = "objx";
    sha256 = "0ycjvfbvsq6pmlbq2v7670w1k25nydnz4scx0qgiv0f4llxnr0y9";
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

  perks = buildFromGitHub rec {
    date = "2014-07-16";
    owner  = "bmizerany";
    repo   = "perks";
    rev = "d9a9656a3a4b1c2864fdb44db2ef8619772d92aa";
    sha256 = "1p5aay4x3q255vrdqv2jcl45acg61j3bz6xgljvqdhw798cyf6a3";
  };

  beorn7_perks = buildFromGitHub rec {
    date = "2016-02-29";
    owner  = "beorn7";
    repo   = "perks";
    rev = "3ac7bf7a47d159a033b107610db8a1b6575507a4";
    sha256 = "1swhv3v8vxgigldpgzzbqxmzdwpvjdii11a3xql677mfbvgv7mpq";
  };

  pflag = buildFromGitHub {
    owner = "spf13";
    repo = "pflag";
    rev = "367864438f1b1a3c7db4da06a2f55b144e6784e0";
    date = "2016-06-10";
    sha256 = "18g0sv7wzl6j1p1j055hlaacz54lp57063d4gy8pbi70phys1qfy";
  };

  pkcs7 = buildFromGitHub {
    owner = "fullsailor";
    repo = "pkcs7";
    rev = "9ab43480afa35dcb6df2c5b80e5e158f421c03c7";
    date = "2016-06-05";
    sha256 = "1l58fj2f4cc2gn38r16n2yl38p3r0l5na2sjx8a9w17kvv91jqr3";
  };

  pkg = buildFromGitHub rec {
    date = "2016-06-23";
    owner  = "coreos";
    repo   = "pkg";
    rev = "a48e304ff9331be6d5df352b6b47bd1395ab5dd7";
    sha256 = "1rscgsik3n6kh51h3axdqwyjbsz6vqjx5p1s4c9v9vs41m679y3k";
    buildInputs = [
      crypto
      yaml-v1
    ];
    propagatedBuildInputs = [
      go-systemd_journal
    ];
  };

  pongo2-v3 = buildFromGitHub {
    rev = "v3.0";
    owner  = "flosch";
    repo   = "pongo2";
    sha256 = "1qjcj7hcjskjqp03fw4lvn1cwy78dck4jcd0rcrgdchis1b84isk";
    goPackagePath = "gopkg.in/flosch/pongo2.v3";
  };

  pq = buildFromGitHub {
    rev = "4dd446efc17690bc53e154025146f73203b18309";
    owner  = "lib";
    repo   = "pq";
    sha256 = "1ac8xj310sdbj77wbbhmkpnlkqc6zsb92r3sji49hf206hi4zww1";
    date = "2016-06-23";
  };

  prometheus_client_golang = buildFromGitHub {
    rev = "28be15864ef9ba05d74fa6fd13b928fd250e8f01";
    owner = "prometheus";
    repo = "client_golang";
    sha256 = "0agpgq85nz0c657zp67152j4qyni7z2k0prnah6h9gdy3gy23f8g";
    propagatedBuildInputs = [
      goautoneg
      net
      protobuf
      prometheus_client_model
      prometheus_common_for_client
      prometheus_procfs
      beorn7_perks
    ];
    date = "2016-07-12";
  };

  prometheus_client_model = buildFromGitHub {
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
    date = "2016-06-23";
    rev = "4402f4e5ea79ec15f3c574773b6a5198fbea215f";
    owner = "prometheus";
    repo = "common";
    sha256 = "12vzhysll9xph9ffcm478bg4czpqi4km48jm26s5lhfh6qwkl592";
    buildInputs = [ net prometheus_client_model httprouter logrus protobuf ];
    propagatedBuildInputs = [
      golang_protobuf_extensions
      prometheus_client_golang
    ];
  };

  prometheus_common_for_client = buildFromGitHub {
    inherit (prometheus_common) date rev owner repo sha256;
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

  prometheus_procfs = buildFromGitHub {
    rev = "abf152e5f3e97f2fafac028d2cc06c1feb87ffa5";
    date = "2016-04-11";
    owner  = "prometheus";
    repo   = "procfs";
    sha256 = "08536i8yaip8lv4zas4xa59igs4ybvnb2wrmil8rzk3a2hl9zck8";
  };

  properties = buildFromGitHub {
    owner = "magiconair";
    repo = "properties";
    rev = "v1.7.0";
    sha256 = "00s9b7fmzhg3j55hs48s3pvzslfj54k1h9vicj782gg79pgid785";
  };

  gogo_protobuf = buildFromGitHub {
    owner = "gogo";
    repo = "protobuf";
    rev = "v0.2";
    sha256 = "1254hnrphry1w2yzna1c2kj2liwwpvdkgnjggcwd5z8flkhpfb7i";
    excludedPackages = "test";
  };

  purell = buildFromGitHub {
    owner = "PuerkitoBio";
    repo = "purell";
    rev = "1d5d1cfad45d42ec5f81fa8ef23de09cebc6dcc3";
    date = "2016-06-07";
    sha256 = "0f6x59470ck9rzjf0lfcnbzadk8awv8dpdindryplm2my7z6d74w";
    propagatedBuildInputs = [
      urlesc
    ];
  };

  qart = buildFromGitHub {
    rev = "0.1";
    owner  = "vitrun";
    repo   = "qart";
    sha256 = "02n7f1j42jp8f4nvg83nswfy6yy0mz2axaygr6kdqwj11n44rdim";
  };

  ql = buildFromGitHub {
    rev = "v1.0.5";
    owner  = "cznic";
    repo   = "ql";
    sha256 = "1f7cr7s65n4xj3ns3h16ak66zqdm78djh97018jvzji6rdaq7pjv";
    propagatedBuildInputs = [
      go4
      b
      exp
      lldb
      strutil
    ];
  };

  rabbit-hole = buildFromGitHub {
    rev = "88550829bcdcf614361c73459c903578eb44074e";
    owner  = "michaelklishin";
    repo   = "rabbit-hole";
    sha256 = "1g6yz793g97mqnm07dsfvbkzl3va81hv5fhlx550rpsdciprc2zb";
    date = "2016-07-06";
  };

  raft = buildFromGitHub {
    date = "2016-07-07";
    rev = "5f14b7233050fc857f722c9cc282360a1f6219b5";
    owner  = "hashicorp";
    repo   = "raft";
    sha256 = "0ql6zaazgn6fcl3p8w69md132vqxpg3jw1mdsrz4wlbzxay9fx41";
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

  reflectwalk = buildFromGitHub {
    date = "2015-05-27";
    rev = "eecf4c70c626c7cfbb95c90195bc34d386c74ac6";
    owner  = "mitchellh";
    repo   = "reflectwalk";
    sha256 = "0zpapfp4vx9zr3zlw2405clgix7jzhhdphmsyhar4yhhs04fb3qz";
  };

  roaring = buildFromGitHub {
    rev = "v0.2.5";
    owner  = "RoaringBitmap";
    repo   = "roaring";
    sha256 = "1kc85xpk5p0fviywck9ci3i8nzsng34gx29i2j3322ax1nyj93ap";
  };

  runc = buildFromGitHub {
    date = "2016-07-10";
    rev = "4eb8c2fb1dcb10fa3bf9bd7031f3a25a8ce2fef6";
    owner = "opencontainers";
    repo = "runc";
    sha256 = "a1c86a1093cb598357570239407fc99c9eba4b88e07c4feb4120405f16a65c5d";
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
    owner = "shurcooL";
    repo = "sanitized_anchor_name";
    rev = "10ef21a441db47d8b13ebcc5fd2310f636973c77";
    date = "2015-10-27";
    sha256 = "0pmkdx914ir0a1inrjaa68r1c27cga1dr8gwx333c8vffiy08kkw";
  };

  scada-client = buildFromGitHub {
    date = "2016-06-01";
    rev = "6e896784f66f82cdc6f17e00052db91699dc277d";
    owner  = "hashicorp";
    repo   = "scada-client";
    sha256 = "1by4kyd2hrrrghwj7snh9p8fdlqka24q9yr6nyja2acs2zpjgh7a";
    buildInputs = [ armon_go-metrics net-rpc-msgpackrpc yamux ];
  };

  semver = buildFromGitHub {
    rev = "v3.3.0";
    owner = "blang";
    repo = "semver";
    sha256 = "0vz3bzkclpgy7n55z6vx3yxzl0mgxbcwfa262kyi2bnvfgz1r10r";
  };

  serf = buildFromGitHub {
    rev = "v0.7.0";
    owner  = "hashicorp";
    repo   = "serf";
    sha256 = "1qzphmv2kci14v5xis08by1bhl09a3yhjy0glyh1wk0s96mx2d1b";

    buildInputs = [
      net circbuf armon_go-metrics ugorji_go go-syslog logutils mdns memberlist
      dns mitchellh_cli mapstructure columnize
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

  sftp = buildFromGitHub {
    owner = "pkg";
    repo = "sftp";
    rev = "57fcf4a640a942eb05181f929601f8f4409eda3e";
    date = "2016-06-22";
    sha256 = "19xf7xk5y2r21g5rddrvwlrlrn5bdsm6hd5cnwpqnlwk9faklh2a";
    propagatedBuildInputs = [
      crypto
      errors
      fs
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
    date = "2016-06-06";
    rev = "f936fb050dc6b5fe4a96b485a6f069e8bdc59aeb";
    owner = "spacemonkeygo";
    repo = "spacelog";
    sha256 = "008npp1bdza55wqyv157xd1512xbpar6hmqhhs3bi5xh7xlwpswj";
    buildInputs = [ flagfile ];
  };

  speakeasy = buildFromGitHub {
    date = "2016-05-20";
    rev = "e1439544d8ecd0f3e9373a636d447668096a8f81";
    owner = "bgentry";
    repo = "speakeasy";
    sha256 = "1aks9mz0xrgxb9fvpf9pac104zwamzv2j53bdirgxsjn12904cqm";
  };

  stathat = buildFromGitHub {
    date = "2016-07-15";
    rev = "74669b9f388d9d788c97399a0824adbfee78400e";
    owner = "stathat";
    repo = "go";
    sha256 = "19aki04z76qzgdr8l3zlz904mkalspfa46cja2fdjy70sfvfjdp1";
  };

  structs = buildFromGitHub {
    date = "2016-07-01";
    rev = "be738c8546f55b34e60125afa50ed73a9a9c460e";
    owner  = "fatih";
    repo   = "structs";
    sha256 = "0mwrz3sn32pg23ajf9w275c2il1gddhw2k6frryar60l0nk5i7g8";
  };

  stump = buildFromGitHub {
    date = "2016-06-11";
    rev = "206f8f13aae1697a6fc1f4a55799faf955971fc5";
    owner = "whyrusleeping";
    repo = "stump";
    sha256 = "0qmchkr29rzscc148aw2vb2qf5dma2dka0ys96cx5fxa4p516d3i";
  };

  strutil = buildFromGitHub {
    date = "2015-04-30";
    rev = "1eb03e3cc9d345307a45ec82bd3016cde4bd4464";
    owner = "cznic";
    repo = "strutil";
    sha256 = "0ipn9zaihxpzs965v3s8c9gm4rc4ckkihhjppchr3hqn2vxwgfj1";
  };

  suture = buildFromGitHub {
    rev = "v2.0.0";
    owner  = "thejerf";
    repo   = "suture";
    sha256 = "0w7v4dp9pjndrrbqkpsl8xlnjs5gv8398gyyvhlb8x5h39v217vp";
  };

  swift = buildFromGitHub {
    rev = "b964f2ca856aac39885e258ad25aec08d5f64ee6";
    owner  = "ncw";
    repo   = "swift";
    sha256 = "1dxhb26pa8j0rzn3w5jdfs56dzf2qv6k28jf5kn4d403y2rvfv99";
    date = "2016-06-17";
  };

  sync = buildFromGitHub {
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
    rev = "v0.14.0";
    owner = "syncthing";
    repo = "syncthing";
    sha256 = "1gyq63b5dk68zj3q5xmd3jn15m873igdb3xmk6sl439avrcgi8qr";
    buildFlags = [ "-tags noupgrade" ];
    buildInputs = [
      go-lz4 du luhn xdr snappy ratelimit osext
      goleveldb suture qart crypto net text rcrowley_go-metrics
      go-nat-pmp glob gateway ql groupcache pq gogo_protobuf
      geoip2-golang
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
    rev = "ff71fe7a7d5279df4b964b31f7ee4adf117277f6";
    date = "2015-07-17";
    owner  = "jeromer";
    repo   = "syslogparser";
    sha256 = "1x1nq7kyvmfl019d3rlwx9nqlqwvc87376mq3xcfb7f5vxlmz9y5";
  };

  tablewriter = buildFromGitHub {
    rev = "daf2955e742cf123959884fdff4685aa79b63135";
    date = "2016-06-21";
    owner  = "olekukonko";
    repo   = "tablewriter";
    sha256 = "096014asbb9d27wyyrg81n922icf7p0r0wr2cipg6ymqrfa2d32f";
    propagatedBuildInputs = [
      go-runewidth
    ];
  };

  tagflag = buildFromGitHub {
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

  tar-utils = buildFromGitHub {
    rev = "beab27159606f5a7c978268dd1c3b12a0f1de8a7";
    date = "2016-03-22";
    owner  = "whyrusleeping";
    repo   = "tar-utils";
    sha256 = "0p0cmk30b22bgfv4m29nnk2359frzzgin2djhysrqznw3wjpn3nz";
  };

  template = buildFromGitHub {
    rev = "a0175ee3bccc567396460bf5acd36800cb10c49c";
    owner = "alecthomas";
    repo = "template";
    sha256 = "10albmv2bdrrgzzqh1rlr88zr2vvrabvzv59m15wazwx39mqzd7p";
    date = "2016-04-05";
  };

  testify = buildFromGitHub {
    rev = "v1.1.3";
    owner = "stretchr";
    repo = "testify";
    sha256 = "12r2v07zq22bk322hn8dn6nv1fg04wb5pz7j7bhgpq8ji2sassdp";
    propagatedBuildInputs = [ objx go-difflib go-spew ];
  };

  tokenbucket = buildFromGitHub {
    rev = "c5a927568de7aad8a58127d80bcd36ca4e71e454";
    date = "2013-12-01";
    owner = "ChimeraCoder";
    repo = "tokenbucket";
    sha256 = "11zasaakzh4fzzmmiyfq5mjqm5md5bmznbhynvpggmhkqfbc28gz";
  };

  tomb-v2 = buildFromGitHub {
    date = "2014-06-26";
    rev = "14b3d72120e8d10ea6e6b7f87f7175734b1faab8";
    owner = "go-tomb";
    repo = "tomb";
    sha256 = "1ixpcahm1j5s9rv52al1k8047hsv7axxqvxcpdpa0lr70b33n45f";
    goPackagePath = "gopkg.in/tomb.v2";
    goPackageAliases = [ "github.com/go-tomb/tomb" ];
  };

  toml = buildFromGitHub {
    owner = "BurntSushi";
    repo = "toml";
    rev = "v0.2.0";
    sha256 = "1sqhi5rx27scpcygdzipbhx4l6x4mjjxkbh5hg00wzqhfwhy4mxw";
  };

  units = buildFromGitHub {
    rev = "2efee857e7cfd4f3d0138cc3cbb1b4966962b93a";
    owner = "alecthomas";
    repo = "units";
    sha256 = "1jj055kgx6mfx5zw263ci70axk3z5006db74dqhcilxwk1a2ga23";
    date = "2015-10-22";
  };

  urlesc = buildFromGitHub {
    owner = "PuerkitoBio";
    repo = "urlesc";
    rev = "5fa9ff0392746aeae1c4b37fcc42c65afa7a9587";
    sate = "2015-02-08";
    sha256 = "00cil3qsy9agswkaagihvmmg67zklgk899h09p49wp7bxgj45rnk";
    date = "2015-02-08";
  };

  utp = buildFromGitHub {
    rev = "2d2a5d62549da0b2d2a3c23b7823ee6930ca8e07";
    owner  = "anacrolix";
    repo   = "utp";
    sha256 = "0c2gyr43hyiar2yjsms1v8f50pahxyh50narnq3xdx07xwwvd5nj";
    date = "2016-07-13";
    propagatedBuildInputs = [
      envpprof
      missinggo
      sync
    ];
  };

  pborman_uuid = buildFromGitHub {
    rev = "v1.0";
    owner = "pborman";
    repo = "uuid";
    sha256 = "1yk7vxrhsyk5izazdqywzfwb7iq6b5lwwdp0yc4rl4spqx30s0f9";
  };

  vault = buildFromGitHub rec {
    rev = "v0.6.0";
    owner = "hashicorp";
    repo = "vault";
    sha256 = "0fpiwbzfirw0s9zvvyc40nzjm8hh5mjxfs0wf7m0lclr8ij8dk26";

    buildInputs = [
      azure-sdk-for-go
      armon_go-metrics
      go-radix
      govalidator
      aws-sdk-go
      speakeasy
      candiedyaml
      etcd-client
      go-mssqldb
      duo_api_golang
      structs
      pkcs7
      yaml
      ini
      ldap
      mysql
      gocql
      protobuf
      snappy
      go-github
      go-querystring
      hailocab_go-hostpool
      consul-api
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
      #ugorji_go
      crypto
      net
      oauth2
      sys
      appengine
      asn1-ber
      inf
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
      go-rootcerts
      mapstructure
    ];
  };

  viper = buildFromGitHub {
    owner = "spf13";
    repo = "viper";
    rev = "c1ccc378a054ea8d4e38d8c67f6938d4760b53dd";
    date = "2016-06-06";
    sha256 = "1zhvyh8zq7c9j65l2jc2gaxmyvygfvxfjqn0hi5a938x7csydx90";
    buildInputs = [
      crypt
      pflag
    ];
    propagatedBuildInputs = [
      cast
      fsnotify
      hcl
      jwalterweatherman
      mapstructure
      properties
      toml
      yaml-v2
    ];
    patches = [
      (fetchTritonPatch {
        file = "viper/viper-2016-06-remove-etcd-support.patch";
        rev = "89c1dace6882bef6b3f05e5e6da3e9166665ef57";
        sha256 = "3cd7132e57b325168adf3f547f5123f744864ba8630ca653b8ee1e928e0e1ac9";
      })
    ];
  };

  vultr = buildFromGitHub {
    rev = "v1.8";
    owner  = "JamesClonk";
    repo   = "vultr";
    sha256 = "1m8y850kkz0y4wlq4amkqx5ayfw5j5d5x9i37a3xnzjxlcsini78";
    propagatedBuildInputs = [
      mow-cli
      tokenbucket
      ratelimit
    ];
  };

  websocket = buildFromGitHub {
    rev = "v1.0.0";
    owner  = "gorilla";
    repo   = "websocket";
    sha256 = "11sggyd6plhcd4bdi8as0bx70bipda8li1rdf0y2n5iwnar3qflq";
  };

  wmi = buildFromGitHub {
    rev = "f3e2bae1e0cb5aef83e319133eabfee30013a4a5";
    owner = "StackExchange";
    repo = "wmi";
    sha256 = "1paiis0l4adsq68v5p4mw7g7vv39j06fawbaph1d3cglzhkvsk7q";
    date = "2015-05-20";
  };

  yaml = buildFromGitHub {
    rev = "aa0c862057666179de291b67d9f093d12b5a8473";
    date = "2016-06-03";
    owner = "ghodss";
    repo = "yaml";
    sha256 = "0vayx9m09flqlkwx8jy4cih01d8637cvnm1x3yxfvzamlb5kdm9p";
    propagatedBuildInputs = [ candiedyaml ];
  };

  yaml-v2 = buildFromGitHub {
    rev = "e4d366fc3c7938e2958e662b4258c7a89e1f0e3e";
    date = "2016-07-15";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "13dkg0x8ydrcc62w7j5sh6iq2wr79rqb31ks4saq5sllphr2xn7r";
    goPackagePath = "gopkg.in/yaml.v2";
  };

  yaml-v1 = buildFromGitHub {
    rev = "9f9df34309c04878acc86042b16630b0f696e1de";
    date = "2014-09-24";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "128xs9pdz042hxl28fi2gdrz5ny0h34xzkxk5rxi9mb5mq46w8ys";
    goPackagePath = "gopkg.in/yaml.v1";
  };

  yamux = buildFromGitHub {
    date = "2016-06-09";
    rev = "badf81fca035b8ebac61b5ab83330b72541056f4";
    owner  = "hashicorp";
    repo   = "yamux";
    sha256 = "063capa74w4q6sj2bm9gs75vri3cxa06pzgzly17rl5grzilsw3y";
  };

  xdr = buildFromGitHub {
    rev = "v2.0.0";
    owner  = "calmh";
    repo   = "xdr";
    sha256 = "017k3y66fy2azbv9iymxsixpyda9czz8v3mhpn17750vlg842dsp";
  };

  xstrings = buildFromGitHub {
    rev = "3959339b333561bf62a38b424fd41517c2c90f40";
    date = "2015-11-30";
    owner  = "huandu";
    repo   = "xstrings";
    sha256 = "16l1cqpqsgipa4c6q55n8vlnpg9kbylkx1ix8hsszdikj25mcig1";
  };

  zappy = buildFromGitHub {
    date = "2016-03-05";
    rev = "4f5e6ef19fd692f1ef9b01206de4f1161a314e9a";
    owner = "cznic";
    repo = "zappy";
    sha256 = "1kinbjs95hv16kn4cgm3vb1yzv09ina7br5m3ygh803qzxp7i5jz";
  };
}; in self

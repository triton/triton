{ }:

# https://docs.saltstack.com/en/latest/topics/releases/index.html
# https://saltstack.com/product-support-lifecycle/

{
  "2016.3" = {
    version = "2016.3.6";
    sha256 = "4cc45f48255b7e46631807b071674552872c322ab77f398c9beefbf14d6a212f";
  };
  "2016.11" = {
    version = "2016.11.6";
    sha256 = "9031af68d31d0416fe3161526ef122a763afc6182bd63fe48b6c4d0a16a0703a";
  };
  "2017.7" = {
    version = "2017.7.0rc1";
    sha256 = "efc4cbb5f66132fcedb4b4297248b9982a0f606f5853ba0386eabdadb596d565";
  };
  head = {
    fetchzipversion = 2;
    version = "2017-02-17";
    rev = "deba6d26554720953409d2280e366621f40f5162";
    sha256 = "bcfd9417a3a37909c4835dc401d57d6eb3c90b89e30526f4e76bf8d7df177afd";
  };
}

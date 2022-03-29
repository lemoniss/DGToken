const dgToken = artifacts.require("DGToken");

module.exports = function (deployer) {
  deployer.deploy(dgToken, "DG Token", "DGT", 1000000000, 18);
}

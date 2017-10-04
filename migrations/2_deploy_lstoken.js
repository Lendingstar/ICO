const LSToken = artifacts.require("./LSToken.sol")

module.exports = function(deployer) {
    deployer.deploy(LSToken);
};

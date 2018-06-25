var Migrations = artifacts.require("./Migrations.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};


module.exports = (deployer) => {
    deployer.deploy(Migrations)
        .then(() => Migrations.deployed())
        .then(registry => new Promise(resolve => setTimeout(() => resolve(registry), 60000)))
        .catch(e => console.log(`Deployer failed. ${e}`));
};
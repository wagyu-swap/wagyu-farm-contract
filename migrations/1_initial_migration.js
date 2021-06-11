const WagyuToken = artifacts.require('WagyuToken');

module.exports = function(deployer) {
  deployer.deploy(WagyuToken).then(() => {
    console.log('Wagyu Token is deployed.');
  });

};

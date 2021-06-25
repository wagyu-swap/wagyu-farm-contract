const WagyuToken = artifacts.require('WagyuToken');
const WVLX = artifacts.require('WVLX');
const VUSDT = artifacts.require('VUSDT');
const VETHER = artifacts.require('VETHER');

module.exports = function(deployer) {
  // deployer.deploy(WagyuToken).then(() => {
  //   console.log('Wagyu Token is deployed.');
  // });
  // deployer.deploy(WVLX).then(() => {
  //   console.log('WVLX Token is deployed.');
  // });
  deployer.deploy(VUSDT).then(() => {
    console.log('VUSDT is deployed.');
  });
  // deployer.deploy(VETHER).then(() => {
  //   console.log('VETHER is deployed.');
  // });
};

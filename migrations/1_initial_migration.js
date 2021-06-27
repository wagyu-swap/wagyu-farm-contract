const WagyuToken = artifacts.require('WagyuToken');
const WVLX = artifacts.require('WVLX');
const VUSDT = artifacts.require('VUSDT');
const VETHER = artifacts.require('VETHER');
const SauceBar = artifacts.require('SauceBar');
const MasterChef = artifacts.require('MasterChef');

const wagyuAddress = '0xb0922F3D63A55517468b6Eb4383f2CaD3Abf856D';
const sauceAddress = '0xBbF7618e93666d2FBD112ab0dd18656a070B26E5';
const devAddress = '0x96D95da6a07954BB494ED587f38756c4f99De472';
const startBlock = 470000;

module.exports = function(deployer) {
  // deployer.deploy(WagyuToken).then(() => {
  //   console.log('Wagyu Token is deployed.');
  // });
  // deployer.deploy(WVLX).then(() => {
  //   console.log('WVLX Token is deployed.');
  // });
  // deployer.deploy(VETHER).then(() => {
  //   console.log('VETHER is deployed.');
  // });
  // deployer.deploy(SauceBar, wagyuAddress).then(() => {
  //   console.log('SauceBar is deployed.');
  // });
  deployer.deploy(MasterChef, wagyuAddress, sauceAddress, devAddress, startBlock).then(() => {
    console.log('MasterChef is deployed.');
  });

};

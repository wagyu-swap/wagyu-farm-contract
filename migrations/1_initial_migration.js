const Wagyu = artifacts.require('Wagyu');
const WVLX = artifacts.require('WVLX');
const VUSDT = artifacts.require('VUSDT');
const VETHER = artifacts.require('VETHER');
const SauceBar = artifacts.require('SauceBar');
const MasterChef = artifacts.require('MasterChef');
const Multicall = artifacts.require('Multicall');

const wagyuAddress = '0x4b7De91a0F231B4F1Ea3d32a55a833962e83097c';
const sauceAddress = '0xcf6BEA98695AbA5E0C5A3BAfF6A2A5d2563f56b8';
const devAddress = '0x96D95da6a07954BB494ED587f38756c4f99De472';
const startBlock = 488600;

module.exports = function(deployer) {
  // deployer.deploy(WVLX).then(() => {
  //   console.log('WVLX Token is deployed.');
  // });
  // deployer.deploy(VETHER).then(() => {
  //   console.log('VETHER is deployed.');
  // });
  // deployer.deploy(VUSDT).then(() => {
  //   console.log('VUSDT is deployed.');
  // });
  // deployer.deploy(Wagyu).then(() => {
  //   console.log('Wagyu is deployed.');
  // });
  // deployer.deploy(SauceBar, wagyuAddress).then(() => {
  //   console.log('SauceBar is deployed.');
  // });
  deployer.deploy(MasterChef, wagyuAddress, sauceAddress, devAddress, startBlock).then(() => {
    console.log('MasterChef is deployed.');
  });
  // deployer.deploy(Multicall).then(() => {
  //   console.log('Multicall is deployed.');
  // });
};

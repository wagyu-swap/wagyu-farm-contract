const Wagyu = artifacts.require('Wagyu');
const WVLX = artifacts.require('WVLX');
const VUSDT = artifacts.require('VUSDT');
const VBNB = artifacts.require('VBNB');
const VETHER = artifacts.require('VETHER');
const SauceBar = artifacts.require('SauceBar');
const MasterChef = artifacts.require('MasterChef');
const Multicall = artifacts.require('Multicall');

const wagyuAddress = '0x297170abcFC7AceA729ce128E1326bE125a7F982';
const sauceAddress = '0x831Be9Bd6d849b4fC3E23a3875205B5eFC903e12';
const devAddress = '0x96D95da6a07954BB494ED587f38756c4f99De472';
const startBlock = 517750;

module.exports = function(deployer) {
  // deployer.deploy(Multicall).then(() => {
  //   console.log('Multicall is deployed.');
  // });
  // deployer.deploy(WVLX).then(() => {
  //   console.log('WVLX Token is deployed.');
  // });
  // deployer.deploy(VETHER).then(() => {
  //   console.log('VETHER is deployed.');
  // });

  // deployer.deploy(VUSDT).then(() => {
  //   console.log('VUSDT is deployed.');
  // });

  // deployer.deploy(VBNB).then(() => {
  //   console.log('VBNB is deployed.');
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
};

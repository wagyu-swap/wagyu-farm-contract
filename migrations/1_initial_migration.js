const Wagyu = artifacts.require('Wagyu');
const WVLX = artifacts.require('WVLX');
const VUSDT = artifacts.require('VUSDT');
const VBNB = artifacts.require('VBNB');
const VETHER = artifacts.require('VETHER');
const SauceBar = artifacts.require('SauceBar');
const MasterChef = artifacts.require('MasterChef');
const Multicall = artifacts.require('Multicall');
const WagyuVault = artifacts.require('WagyuVault');
const VaultOwner = artifacts.require('VaultOwner');
const VlxStaking = artifacts.require('VlxStaking');
const SousChefFactory = artifacts.require('SousChefFactory');

const wagyuAddress = '0x297170abcFC7AceA729ce128E1326bE125a7F982';
const sauceAddress = '0x9f1E48f5aa7a0356008A7860788616Defa1a91f9';
const teamAddress = '0x96D95da6a07954BB494ED587f38756c4f99De472';
const masterChefAddress = '0x331ed46B7D69b4B0d52ccbb8B688C76cA86F6F5C';
const wagyuVaultAddress = '0x34b1370C8Fc76C15eb646ca9503C739d2489158C';
const wvlxAddress = '0x8153DCbdAF8740B6e101C99659613D39Dd697E34';
const startBlock = 517800;

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
  deployer.deploy(Wagyu).then(() => {
    console.log('Wagyu is deployed.');
  });
  // deployer.deploy(SauceBar, wagyuAddress).then(() => {
  //   console.log('SauceBar is deployed.');
  // });
  // deployer.deploy(MasterChef, wagyuAddress, sauceAddress, teamAddress, startBlock).then(() => {
  //   console.log('MasterChef is deployed.');
  // });

  // deployer.deploy(WagyuVault, wagyuAddress, sauceAddress, masterChefAddress, teamAddress, teamAddress).then(() => {
  //   console.log('WagyuVault is deployed.');
  // });

  // deployer.deploy(VaultOwner, wagyuVaultAddress).then(() => {
  //   console.log('VaultOwner is deployed.');
  // });

  // start block: 689000
  // end block: 1207400 (60 days, Average block time is 10s)
  // deployer.deploy(VlxStaking, wvlxAddress, wagyuAddress, '42000000000000000', 689000, 1207400, teamAddress, wvlxAddress).then(() => {
  //   console.log('VlxStaking is deployed.');
  // });

  // deployer.deploy(SousChefFactory).then(() => {
  //   console.log('SousChefFactory is deployed.');
  // });
};

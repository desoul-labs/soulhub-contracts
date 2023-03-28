import { ethers, run } from 'hardhat';
import {
  type SoulHubUpgradeable,
  SoulHubUpgradeable__factory,
  type TransparentUpgradeableProxy,
  type UpgradeableBeacon,
  type ERC5727SBTUpgradeable,
} from '../typechain';

async function verifyContract(address: string, constructorArguments: any[]): Promise<void> {
  await new Promise((resolve) => setTimeout(resolve, 10000));
  await run('verify:verify', {
    address,
    constructorArguments,
  }).catch((error) => {
    console.info(error);
  });
}

async function deploySbt(): Promise<ERC5727SBTUpgradeable> {
  const sbtContract = await ethers.getContractFactory('ERC5727SBTUpgradeable');

  const sbt = await sbtContract.deploy();
  await sbt.deployed();
  console.log('SBT contract deployed to:', sbt.address);

  await verifyContract(sbt.address, []);
  return sbt;
}

async function deployBeacon(implementation: string): Promise<UpgradeableBeacon> {
  const beaconContract = await ethers.getContractFactory('UpgradeableBeacon');
  const beacon = await beaconContract.deploy(implementation);

  await beacon.deployed();
  console.log('Beacon contract deployed to:', beacon.address);

  await verifyContract(beacon.address, [implementation]);
  return beacon;
}

async function deploySoulHub(): Promise<SoulHubUpgradeable> {
  const soulHubContract = await ethers.getContractFactory('SoulHubUpgradeable');
  const soulHub = await soulHubContract.deploy();

  await soulHub.deployed();
  console.log('SoulHub contract deployed to:', soulHub.address);

  await verifyContract(soulHub.address, []);
  return soulHub;
}

async function deployTransparentProxy(
  impl: string,
  admin: string,
  data: string,
): Promise<TransparentUpgradeableProxy> {
  const transparentProxyContract = await ethers.getContractFactory('TransparentUpgradeableProxy');
  const transparentProxy = await transparentProxyContract.deploy(impl, admin, data);

  await transparentProxy.deployed();
  console.log('TransparentUpgradeableProxy contract deployed to:', transparentProxy.address);

  await verifyContract(transparentProxy.address, [impl, admin, data]);
  return transparentProxy;
}

async function main(): Promise<void> {
  const [deployer] = await ethers.getSigners();
  console.log('Deploying contracts with the account:', deployer.address);
  console.log('Network:', (await ethers.provider.getNetwork()).name);

  const sbtImpl = await deploySbt();
  const beacon = await deployBeacon(sbtImpl.address);

  const soulHubImpl = await deploySoulHub();
  const initData = SoulHubUpgradeable__factory.createInterface().encodeFunctionData(
    '__SoulHub_init',
    [beacon.address],
  );
  const soulHubProxy = await deployTransparentProxy(
    soulHubImpl.address,
    deployer.address,
    initData,
  );
  console.log('SoulHub proxy address:', soulHubProxy.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

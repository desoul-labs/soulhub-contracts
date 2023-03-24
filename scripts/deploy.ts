import { ethers, run } from 'hardhat';
import { ERC5727RegistryUpgradeable__factory } from '../typechain';
import type {
  BeaconProxy,
  ERC5727ExampleUpgradeable,
  ERC5727RegistryUpgradeable,
  TransparentUpgradeableProxy,
  UpgradeableBeacon,
} from '../typechain';

async function sleep(ms: number): Promise<void> {
  await new Promise((resolve) => setTimeout(resolve, ms));
}

async function deploySbt(): Promise<ERC5727ExampleUpgradeable> {
  const sbtContract = await ethers.getContractFactory('ERC5727ExampleUpgradeable');

  const sbt = await sbtContract.deploy();
  await sbt.deployed();
  console.log('SBT contract deployed to:', sbt.address);

  await sleep(10000);
  await run('verify:verify', {
    address: sbt.address,
    constructorArguments: [],
  }).catch((error) => {
    console.info(error);
  });

  return sbt;
}

async function deployBeacon(implementation: string): Promise<UpgradeableBeacon> {
  const beaconContract = await ethers.getContractFactory('UpgradeableBeacon');
  const beacon = await beaconContract.deploy(implementation);

  await beacon.deployed();
  console.log('Beacon contract deployed to:', beacon.address);

  await sleep(10000);
  await run('verify:verify', {
    address: beacon.address,
    constructorArguments: [implementation],
  }).catch((error) => {
    console.info(error);
  });

  return beacon;
}

async function deployBeaconProxy(beacon: string, initCode: string): Promise<BeaconProxy> {
  const proxyContract = await ethers.getContractFactory('BeaconProxy');
  const proxy = await proxyContract.deploy(beacon, initCode);

  await proxy.deployed();
  console.log('BeaconProxy contract deployed to:', proxy.address);

  await sleep(10000);
  await run('verify:verify', {
    address: proxy.address,
    constructorArguments: [beacon, initCode],
  }).catch((error) => {
    console.info(error);
  });

  return proxy;
}

async function deployTransparentProxy(
  registry: string,
  admin: string,
  data: string,
): Promise<TransparentUpgradeableProxy> {
  const transparentProxyContract = await ethers.getContractFactory('TransparentUpgradeableProxy');
  const transparentProxy = await transparentProxyContract.deploy(registry, admin, data);

  await transparentProxy.deployed();
  console.log('TransparentUpgradeableProxy contract deployed to:', transparentProxy.address);

  await sleep(10000);
  await run('verify:verify', {
    address: transparentProxy.address,
    constructorArguments: [registry, admin, data],
  }).catch((error) => {
    console.info(error);
  });

  return transparentProxy;
}

async function deployRegistry(): Promise<ERC5727RegistryUpgradeable> {
  const registryContract = await ethers.getContractFactory('ERC5727RegistryUpgradeable');
  const registry = await registryContract.deploy();

  await registry.deployed();
  console.log('Registry contract deployed to:', registry.address);

  await sleep(10000);
  await run('verify:verify', {
    address: registry.address,
    constructorArguments: [],
  }).catch((error) => {
    console.info(error);
  });

  return registry;
}

async function main(): Promise<void> {
  const [deployer] = await ethers.getSigners();
  console.log('Deploying contracts with the account:', deployer.address);
  console.log('Network:', (await ethers.provider.getNetwork()).name);

  const sbt = await deploySbt();
  const beacon = await deployBeacon(sbt.address);
  const callData = sbt.interface.encodeFunctionData('__ERC5727Example_init', [
    'SoulHub SBT',
    'SBT',
    deployer.address,
    [deployer.address],
    'https://api.soularis.dev/',
    'v1',
  ]);
  const beaconProxy = await deployBeaconProxy(beacon.address, callData);

  const registry = await deployRegistry();
  const initData = registry.interface.encodeFunctionData('__ERC5727Registry_init', [
    'SoulHub Registry',
    '/',
    'https://api.soularis.dev/',
  ]);

  const registryProxy = await deployTransparentProxy(registry.address, deployer.address, initData);
  const registryProxyContract = ERC5727RegistryUpgradeable__factory.connect(
    registryProxy.address,
    deployer,
  );
  await registryProxyContract.register(beaconProxy.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

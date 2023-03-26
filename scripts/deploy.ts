import { ethers, run } from 'hardhat'
import {
  type SoulHubUpgradeable,
  SoulHubUpgradeable__factory,
  type TransparentUpgradeableProxy,
  type UpgradeableBeacon,
  type ERC5727SBTUpgradeable,
} from '../typechain'

async function sleep(ms: number): Promise<void> {
  await new Promise((resolve) => setTimeout(resolve, ms));
}

async function deploySbt(): Promise<ERC5727SBTUpgradeable> {
  const sbtContract = await ethers.getContractFactory('ERC5727SBTUpgradeable')

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

async function deploySoulHub(beacon: string): Promise<SoulHubUpgradeable> {
  const soulHubContract = await ethers.getContractFactory('SoulHubUpgradeable')
  const soulHub = await soulHubContract.deploy()

  await soulHub.deployed()
  console.log('SoulHub contract deployed to:', soulHub.address)

  await sleep(10000);
  await run('verify:verify', {
    address: soulHub.address,
    constructorArguments: [],
  }).catch((error) => {
    console.info(error);
  });

  return soulHub
}

async function deployTransparentProxy(
  impl: string,
  admin: string,
  data: string,
): Promise<TransparentUpgradeableProxy> {
  const transparentProxyContract = await ethers.getContractFactory('TransparentUpgradeableProxy')
  const transparentProxy = await transparentProxyContract.deploy(impl, admin, data)

  await transparentProxy.deployed();
  console.log('TransparentUpgradeableProxy contract deployed to:', transparentProxy.address);

  await sleep(10000);
  await run('verify:verify', {
    address: transparentProxy.address,
    constructorArguments: [impl, admin, data],
  }).catch((error) => {
    console.info(error);
  });

  return transparentProxy;
}

async function main(): Promise<void> {
  const [hubAdmin, orgAdmin] = await ethers.getSigners()
  console.log('Deploying contracts with the account:', hubAdmin.address)
  console.log('Network:', (await ethers.provider.getNetwork()).name)

  const sbtImpl = await deploySbt()
  const beacon = await deployBeacon(sbtImpl.address)

  const soulHubImpl = await deploySoulHub(beacon.address)
  const initData = SoulHubUpgradeable__factory.createInterface().encodeFunctionData(
    '__SoulHub_init',
    [beacon.address],
  )
  const soulHubProxy = await deployTransparentProxy(soulHubImpl.address, hubAdmin.address, initData)
  const soulHub = SoulHubUpgradeable__factory.connect(soulHubProxy.address, orgAdmin)

  const organization = await soulHub.callStatic.createOrganization('Desoul')
  console.log('New organization:', organization)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

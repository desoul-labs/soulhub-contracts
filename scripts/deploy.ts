import { ethers, run } from 'hardhat'
import { ERC5727ExampleUpgradeable__factory } from '../typechain'
import type {
  BeaconProxy,
  MinimalProxyFactory,
  ERC5727ExampleUpgradeable,
  UpgradeableBeacon,
} from '../typechain'

async function sleep(ms: number): Promise<void> {
  await new Promise((resolve) => setTimeout(resolve, ms))
}

async function deploySbt(): Promise<ERC5727ExampleUpgradeable> {
  const sbtContract = await ethers.getContractFactory('ERC5727ExampleUpgradeable')

  const sbt = await sbtContract.deploy()
  await sbt.deployed()
  console.log('SBT contract deployed to:', sbt.address)

  await sleep(10000)
  await run('verify:verify', {
    address: sbt.address,
    constructorArguments: [],
  }).catch((error) => {
    console.info(error)
  })

  return sbt
}

async function deployBeacon(implementation: string): Promise<UpgradeableBeacon> {
  const beaconContract = await ethers.getContractFactory('UpgradeableBeacon')
  const beacon = await beaconContract.deploy(implementation)

  await beacon.deployed()
  console.log('Beacon contract deployed to:', beacon.address)

  await sleep(10000)
  await run('verify:verify', {
    address: beacon.address,
    constructorArguments: [implementation],
  }).catch((error) => {
    console.info(error)
  })

  return beacon
}

async function deployBeaconProxy(beacon: string, initCode: string): Promise<BeaconProxy> {
  const proxyContract = await ethers.getContractFactory('BeaconProxy')
  const proxy = await proxyContract.deploy(beacon, initCode)

  await proxy.deployed()
  console.log('BeaconProxy contract deployed to:', proxy.address)

  await sleep(10000)
  await run('verify:verify', {
    address: proxy.address,
    constructorArguments: [beacon, initCode],
  }).catch((error) => {
    console.info(error)
  })

  return proxy
}

async function deployMinimalProxy(): Promise<MinimalProxyFactory> {
  const minimalProxyFactoryContract = await ethers.getContractFactory('MinimalProxyFactory')
  const minimalProxyFactory = await minimalProxyFactoryContract.deploy(
    '0x0000000000000000000000000000000000000000',
  )

  await minimalProxyFactory.deployed()
  console.log('MinimalProxyFactory contract deployed to:', minimalProxyFactory.address)

  await sleep(10000)
  await run('verify:verify', {
    address: minimalProxyFactory.address,
    constructorArguments: ['0x0000000000000000000000000000000000000000'],
  }).catch((error) => {
    console.info(error)
  })

  return minimalProxyFactory
}

async function main(): Promise<void> {
  const [deployer] = await ethers.getSigners()
  console.log('Deploying contracts with the account:', deployer.address)
  console.log('Network:', (await ethers.provider.getNetwork()).name)

  const sbt = await deploySbt()
  const beacon = await deployBeacon(sbt.address)
  const beaconProxy = await deployBeaconProxy(beacon.address, '0x')

  const minimalProxy = await deployMinimalProxy()
  const salt = ethers.utils.formatBytes32String(Math.random().toString().slice(2, 10))
  const tx = await minimalProxy.deployProxyByImplementation(beaconProxy.address, '0x', salt)
  const receipt = await tx.wait()
  const proxyAddress: string = receipt.events?.[0].args?.[1]
  console.log('Proxy contract deployed to:', proxyAddress)

  const sbtProxy = ERC5727ExampleUpgradeable__factory.connect(
    '0xaB5405c03DF0f52dfC3D75975C6c30E64B9046Cd',
    deployer,
  )
  await sbtProxy.__ERC5727Example_init(
    'SoulHub SBT',
    'SBT',
    '0xC5a0058Fa5f5bDEA7BE0A29F0428a0a5e6788438',
    ['0xC5a0058Fa5f5bDEA7BE0A29F0428a0a5e6788438'],
    'https://api.soulhub.dev/sbt/',
    'v1',
  )
  await sbtProxy['issue(address,uint256,uint256,uint8,address,bytes)'](
    deployer.address,
    1,
    1,
    1,
    deployer.address,
    '0x',
  )
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})

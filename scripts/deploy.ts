import { ethers, run } from 'hardhat'

async function sleep(ms: number): Promise<void> {
  return await new Promise((resolve) => setTimeout(resolve, ms))
}

async function main(): Promise<void> {
  const ERC5727 = await ethers.getContractFactory('ERC5727Example')
  const erc5727 = await ERC5727.deploy(
    'Soularis SBT',
    'SBT',
    '0xC5a0058Fa5f5bDEA7BE0A29F0428a0a5e6788438',
    ['0xC5a0058Fa5f5bDEA7BE0A29F0428a0a5e6788438'],
    'https://api.soularis.dev/sbt/',
    '0x0000000000000000000000000000000000000000',
    'v1',
  )
  await erc5727.deployed()
  console.log('ERC5727Example contract deployed to:', erc5727.address)
  await sleep(10000)
  await run('verify:verify', {
    address: '0xAd86DD4c87B8Ba6101CEcf635aF757C026C9f453',
    constructorArguments: [
      'Soularis SBT',
      'SBT',
      '0xC5a0058Fa5f5bDEA7BE0A29F0428a0a5e6788438',
      ['0xC5a0058Fa5f5bDEA7BE0A29F0428a0a5e6788438'],
      'https://api.soularis.dev/sbt/',
      '0x0000000000000000000000000000000000000000',
      'v1',
    ],
  }).catch((error) => {
    console.info(error)
  })
  // const erc5727Factory = await ethers.getContractFactory('ERC5727ExampleUpgradeable')
  // const erc5727 = await erc5727Factory.deploy()
  // await erc5727.deployed()
  // await sleep(10000)
  // console.log('ERC5727Example contract deployed to:', erc5727.address)
  // // await tenderly.verify({
  // //   name: 'ERC5727Example',
  // //   address: erc5727.address,
  // // })
  // await run('verify:verify', {
  //   address: erc5727.address,
  //   constructorArguments: [],
  // }).catch((error) => {
  //   console.info(error)
  // })

  // const registryFactory = await ethers.getContractFactory('ERC5727RegistryExample')
  // const registry = await registryFactory.deploy(
  //   'RegistryExample',
  //   'REG',
  //   '/soularis/example',
  //   'https://soularis-demo.s3.ap-northeast-1.amazonaws.com/registry/',
  // )
  // await registry.deployed()
  // console.log('ERC5727RegistryExample contract deployed to:', registry.address)
  // // await tenderly.verify({
  // //   name: 'ERC5727RegistryExample',
  // //   address: registry.address,
  // // })
  // await sleep(10000)
  // await run('verify:verify', {
  //   address: registry.address,
  //   constructorArguments: [
  //     'RegistryExample',
  //     'REG',
  //     '/soularis/example',
  //     'https://soularis-demo.s3.ap-northeast-1.amazonaws.com/registry/',
  //   ],
  // }).catch((error) => {
  //   console.info(error)
  // })

  // const minimalProxyDeployerFactory = await ethers.getContractFactory('MinimalProxyDeployer')
  // const minimalProxyDeployer = await minimalProxyDeployerFactory.deploy(
  //   '0x0000000000000000000000000000000000000000',
  // )
  // await minimalProxyDeployer.deployed()
  // console.log('MinimalProxyFactory contract deployed to:', minimalProxyDeployer.address)
  // // await tenderly.verify({
  // //   name: 'MinimalProxyFactory',
  // //   address: minimalProxyDeployer.address,
  // // })
  // await sleep(10000)
  // await run('verify:verify', {
  //   address: minimalProxyDeployer.address,
  //   constructorArguments: ['0x0000000000000000000000000000000000000000'],
  // }).catch((error) => {
  //   console.info(error)
  // })

  // const souldropFactory = await ethers.getContractFactory('Souldrop')
  // const souldrop = await souldropFactory.deploy()
  // await souldrop.deployed()
  // console.log('Souldrop contract deployed to:', souldrop.address)
  // // await tenderly.verify({
  // //   name: 'Souldrop',
  // //   address: souldrop.address,
  // // })
  // await sleep(10000)
  // await run('verify:verify', {
  //   address: souldrop.address,
  //   constructorArguments: [],
  // }).catch((error) => {
  //   console.info(error)
  // })
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})

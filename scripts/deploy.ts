import { ethers, tenderly } from 'hardhat'

async function main(): Promise<void> {
  const erc5727Factory = await ethers.getContractFactory('ERC5727ExampleUpgradeable')
  const erc5727 = await erc5727Factory.deploy()
  await erc5727.deployed()
  console.log('ERC5727Example contract deployed to:', erc5727.address)
  await tenderly.verify({
    name: 'ERC5727Example',
    address: erc5727.address,
  })

  const registryFactory = await ethers.getContractFactory('ERC5727RegistryExample')
  const registry = await registryFactory.deploy(
    'RegistryExample',
    'REG',
    '/soularis/example',
    'https://soularis-demo.s3.ap-northeast-1.amazonaws.com/registry/',
  )
  await registry.deployed()
  console.log('ERC5727RegistryExample contract deployed to:', registry.address)
  await tenderly.verify({
    name: 'ERC5727RegistryExample',
    address: registry.address,
  })

  const minimalProxyDeployerFactory = await ethers.getContractFactory('MinimalProxyDeployer')
  const minimalProxyDeployer = await minimalProxyDeployerFactory.deploy(
    '0x0000000000000000000000000000000000000000',
  )
  await minimalProxyDeployer.deployed()
  console.log('MinimalProxyFactory contract deployed to:', minimalProxyDeployer.address)
  await tenderly.verify({
    name: 'MinimalProxyFactory',
    address: minimalProxyDeployer.address,
  })

  const souldropFactory = await ethers.getContractFactory('Souldrop')
  const souldrop = await souldropFactory.deploy()
  await souldrop.deployed()
  console.log('Souldrop contract deployed to:', souldrop.address)
  await tenderly.verify({
    name: 'Souldrop',
    address: souldrop.address,
  })
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})

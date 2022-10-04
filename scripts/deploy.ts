import { ethers, tenderly } from 'hardhat'

async function main(): Promise<void> {
  const erc5727Factory = await ethers.getContractFactory('ERC5727Example')
  const erc5727 = await erc5727Factory.deploy(
    'ERC5727Example',
    'ERC',
    ['0xf786867559B705f0D3B3ec7Dc1459A6f6023D975'],
    'https://soularis-demo.s3.ap-northeast-1.amazonaws.com/erc5727/',
  )
  await erc5727.deployed()
  console.log('ERC5727Example contract deployed to:', erc5727.address)
  await tenderly.verify({
    name: 'ERC5727Example',
    address: erc5727.address,
  })

  const registryFactory = await ethers.getContractFactory('ERC5727RegistryExample')
  const registry = await registryFactory.deploy(
    'MyRegistry',
    '/soularis/test',
    'https://soularis-demo.s3.ap-northeast-1.amazonaws.com/registry/',
  )
  await registry.deployed()
  console.log('ERC5727RegistryExample contract deployed to:', registry.address)
  await tenderly.verify({
    name: 'ERC5727RegistryExample',
    address: registry.address,
  })

  const cardFactory = await ethers.getContractFactory('SoulmateCard')
  const card = await cardFactory.deploy(
    'SoulmateCard',
    'CARD',
    'https://soularis-demo.s3.ap-northeast-1.amazonaws.com/card/',
  )
  await card.deployed()
  console.log('Card contract deployed to:', card.address)
  await tenderly.verify({
    name: 'SoulmateCard',
    address: card.address,
  })
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})

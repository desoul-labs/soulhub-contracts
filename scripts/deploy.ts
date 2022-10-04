import { ethers, tenderly } from 'hardhat'

async function main(): Promise<void> {
  const perkFactory = await ethers.getContractFactory('Perk')
  const perkContract = await perkFactory.deploy(
    'SoularisPerk',
    'PERK',
    ['0xf786867559B705f0D3B3ec7Dc1459A6f6023D975'],
    'https://soularis-demo.s3.ap-northeast-1.amazonaws.com/perk/',
  )
  await perkContract.deployed()
  console.log('Perk contract deployed to:', perkContract.address)
  await tenderly.verify({
    name: 'Perk',
    address: perkContract.address,
  })

  const cardFactory = await ethers.getContractFactory('SoulmateCard')
  const cardContract = await cardFactory.deploy(
    'SoulmateCard',
    'CARD',
    'https://soularis-demo.s3.ap-northeast-1.amazonaws.com/card/',
  )
  await cardContract.deployed()
  console.log('Card contract deployed to:', cardContract.address)
  await tenderly.verify({
    name: 'SoulmateCard',
    address: cardContract.address,
  })
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})

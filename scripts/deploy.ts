import { ethers } from 'hardhat'

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

  const cardFactory = await ethers.getContractFactory('SoulmateCard')
  const cardContract = await cardFactory.deploy(
    'SoulmateCard',
    'CARD',
    'https://soularis-demo.s3.ap-northeast-1.amazonaws.com/card/',
  )
  await cardContract.deployed()
  console.log('Card contract deployed to:', cardContract.address)

  const gatewayFactory = await ethers.getContractFactory('SimpleGateway')
  const gatewayContract = await gatewayFactory.deploy()
  await gatewayContract.deployed()
  console.log('SimpleGateway contract deployed to:', gatewayContract.address)

  const ticketFactory = await ethers.getContractFactory('Ticket')
  const ticketContract = await ticketFactory.deploy(
    'SoularisTicket',
    'STKT',
    'https://js6azx7pn9.execute-api.ap-northeast-1.amazonaws.com/assets/ticket/',
    'https://js6azx7pn9.execute-api.ap-northeast-1.amazonaws.com/badges/ticket/',
    gatewayContract.address,
  )
  await ticketContract.deployed()
  console.log('Ticket contract deployed to:', ticketContract.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})

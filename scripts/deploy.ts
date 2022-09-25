import { ethers } from 'hardhat'

async function main(): Promise<void> {
  const membershipFactory = await ethers.getContractFactory('MembershipCard')
  const membershipContract = await membershipFactory.deploy(
    'SoularisMember',
    'SMEM',
    'https://js6azx7pn9.execute-api.ap-northeast-1.amazonaws.com/assets/membership/',
    ['0xf786867559B705f0D3B3ec7Dc1459A6f6023D975'],
  )

  await membershipContract.deployed()

  console.log('MembershipCard contract deployed to:', membershipContract.address)

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

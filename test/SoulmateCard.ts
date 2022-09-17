import { expect } from 'chai'
import { ethers } from 'hardhat'

describe('SoulmateCard', function () {
  it('Test', async function () {
    const [owner] = await ethers.getSigners()

    const soulmateFactory = await ethers.getContractFactory('SoulmateCard')

    const soulmateContract = await soulmateFactory.deploy(
      'SoularisMember',
      'SMEM',
      'https://js6azx7pn9.execute-api.ap-northeast-1.amazonaws.com/assets/membership/',
    )

    await soulmateContract.deployed()

    await soulmateContract.mint(owner.address)

    expect(await soulmateContract['balanceOf(uint256)'](0)).equal(1)

    expect(await soulmateContract.ownerOf(0)).equal(owner.address)
  })
})

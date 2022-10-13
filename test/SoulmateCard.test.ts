import { expect } from 'chai'
import { ethers } from 'hardhat'

describe('SoulmateCard', function () {
  it('mint', async function () {
    const SoulmateCardFactory = await ethers.getContractFactory('SoulmateCard')
    const SoulmateCardContract = await SoulmateCardFactory.deploy(
      'Soularis',
      'SOUL',
      'https://soularis-demo.s3.ap-northeast-1.amazonaws.com/perk/',
    )
    await SoulmateCardContract.deployed()
    const [, soulmate1] = await ethers.getSigners()
    await SoulmateCardContract.mint(soulmate1.address, 1, 1)
    expect(await SoulmateCardContract.balanceOf(soulmate1.address)).to.equal(1)
  })
})

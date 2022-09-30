import { expect } from 'chai'
import { ethers } from 'hardhat'

beforeEach(async function () {
  this.ERC5727ExampleFactory = await ethers.getContractFactory('ERC5727Example')
  ;[this.owner, this.soul1, this.soul2, this.voter1, this.voter2] = await ethers.getSigners()
  this.ERC5727ExampleContract = await this.ERC5727ExampleFactory.deploy(
    'Soularis',
    'SOUL',
    [this.voter1.address, this.voter2.address],
    'https://soularis-demo.s3.ap-northeast-1.amazonaws.com/perk/',
  )
  await this.ERC5727ExampleContract.deployed()
})

describe('ERC5727Test', function () {
  describe('ERC5727Example', function () {
    it('Mint', async function () {
      expect(await this.ERC5727ExampleContract.owner()).equal(this.owner.address)

      await expect(
        this.ERC5727ExampleContract.connect(this.soul1).mint(
          this.soul1.address,
          1,
          1,
          1664539263,
          false,
        ),
      ).be.reverted

      await expect(this.ERC5727ExampleContract.revoke(1)).be.reverted
    })
  })
})

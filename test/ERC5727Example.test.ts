import { expect } from 'chai'
import { ethers } from 'hardhat'
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers'
import {
  type IERC5727,
  IERC5727__factory,
  type ERC5727Example,
  type ERC5727Example__factory,
} from '../typechain'
import { type SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'

interface Fixture {
  getCoreContract: (signer: SignerWithAddress) => IERC5727
  ERC5727ExampleContract: ERC5727Example
  admin: SignerWithAddress
  tokenOwner1: SignerWithAddress
  tokenOwner2: SignerWithAddress
  voter1: SignerWithAddress
  voter2: SignerWithAddress
  delegate1: SignerWithAddress
  delegate2: SignerWithAddress
}

describe('ERC5727Test', function () {
  async function deployTokenFixture(): Promise<Fixture> {
    const ERC5727ExampleFactory: ERC5727Example__factory = await ethers.getContractFactory(
      'ERC5727Example',
    )
    const [admin, tokenOwner1, tokenOwner2, voter1, voter2, delegate1, delegate2] =
      await ethers.getSigners()
    const ERC5727ExampleContract = await ERC5727ExampleFactory.deploy(
      'Soularis',
      'SOUL',
      admin.address,
      [voter1.address, voter2.address],
      'https://api.soularis.io/contracts/',
      '1',
    )
    const getCoreContract = (signer: SignerWithAddress): IERC5727 =>
      IERC5727__factory.connect(ERC5727ExampleContract.address, signer)
    await ERC5727ExampleContract.deployed()
    return {
      getCoreContract,
      ERC5727ExampleContract,
      admin,
      tokenOwner1,
      tokenOwner2,
      voter1,
      voter2,
      delegate1,
      delegate2,
    }
  }
  describe('ERC5727', function () {
    it('Only admin can issue', async function () {
      const { getCoreContract, admin, tokenOwner1, tokenOwner2 } = await loadFixture(
        deployTokenFixture,
      )
      const coreContract = getCoreContract(admin)
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        1,
        admin.address,
        [],
      )
      const coreContractOther = getCoreContract(tokenOwner2)
      await expect(
        coreContractOther['issue(address,uint256,uint256,uint8,address,bytes)'](
          tokenOwner1.address,
          1,
          1,
          1,
          admin.address,
          [],
        ),
      ).be.reverted
    })
  })
})

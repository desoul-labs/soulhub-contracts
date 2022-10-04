import { expect } from 'chai'
import { ethers } from 'hardhat'

describe('ERC5727Test', function () {
  beforeEach(async function () {
    const ERC5727ExampleFactory = await ethers.getContractFactory('ERC5727Example')
    ;[
      this.owner,
      this.tokenOwnerSoul1,
      this.tokenOwnerSoul2,
      this.voterSoul1,
      this.voterSoul2,
      this.delegateSoul1,
      this.delegateSoul2,
    ] = await ethers.getSigners()
    this.ERC5727ExampleContract = await ERC5727ExampleFactory.deploy(
      'Soularis',
      'SOUL',
      [this.voterSoul1.address, this.voterSoul2.address],
      'https://soularis-demo.s3.ap-northeast-1.amazonaws.com/perk/',
    )
    await this.ERC5727ExampleContract.deployed()
  })

  describe('ERC5727Example', function () {
    it('Only contract owner can mint with mint', async function () {
      expect(await this.ERC5727ExampleContract.owner()).equal(this.owner.address)

      await this.ERC5727ExampleContract.connect(this.owner).mint(
        this.tokenOwnerSoul1.address,
        1,
        1,
        2664539263,
        false,
      )

      await expect(
        this.ERC5727ExampleContract.connect(this.voterSoul1).mint(
          this.tokenOwnerSoul1.address,
          1,
          2,
          2664539263,
          false,
        ),
      ).be.reverted
    })

    it('Only contract owner can revoke with revoke', async function () {
      expect(await this.ERC5727ExampleContract.owner()).equal(this.owner.address)

      await this.ERC5727ExampleContract.connect(this.owner).mint(
        this.tokenOwnerSoul1.address,
        1,
        1,
        2664539263,
        false,
      )

      await this.ERC5727ExampleContract.connect(this.owner).revoke(0)

      await expect(this.ERC5727ExampleContract.connect(this.voterSoul1).revoke(0)).be.reverted
    })

    it('Balance of souls will increase when tokens are minted to them', async function () {
      await this.ERC5727ExampleContract.mintBatch(
        [
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul2.address,
        ],
        1,
        1,
        2664539263,
        false,
      )

      expect(await this.ERC5727ExampleContract.balanceOf(this.tokenOwnerSoul1.address)).equal(3)

      expect(await this.ERC5727ExampleContract.balanceOf(this.tokenOwnerSoul2.address)).equal(1)
    })

    it('Token will be invalid if it is revoked', async function () {
      expect(await this.ERC5727ExampleContract.owner()).equal(this.owner.address)

      await this.ERC5727ExampleContract.connect(this.owner).mint(
        this.tokenOwnerSoul1.address,
        1,
        1,
        2664539263,
        false,
      )

      await this.ERC5727ExampleContract.connect(this.owner).revoke(0)

      expect(await this.ERC5727ExampleContract.isValid(0)).equal(false)
    })

    it('Revert if a token not exist is revoked', async function () {
      await expect(this.ERC5727ExampleContract.revoke(100)).be.reverted
    })
  })

  describe('ERC5727', function () {
    it('The information of a token can be correctly queried', async function () {
      await this.ERC5727ExampleContract.mintBatch(
        [
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul2.address,
        ],
        1,
        1,
        2664539263,
        false,
      )

      expect(await this.ERC5727ExampleContract.slotOf(0)).equal(1)
      expect(await this.ERC5727ExampleContract.soulOf(0)).equal(this.tokenOwnerSoul1.address)
      expect(await this.ERC5727ExampleContract.issuerOf(0)).equal(this.owner.address)
      expect(await this.ERC5727ExampleContract.isValid(0)).equal(true)
    })

    it('The information of the contract is correct', async function () {
      expect(await this.ERC5727ExampleContract.name()).equal('Soularis')
      expect(await this.ERC5727ExampleContract.symbol()).equal('SOUL')
    })
  })

  describe('ERC5727Delegate', function () {
    it('Only contract owner can create or delete delegate request', async function () {
      await this.ERC5727ExampleContract.createDelegateRequest(this.tokenOwnerSoul1.address, 1, 1)
      await expect(
        this.ERC5727ExampleContract.connect(this.voterSoul1).createDelegateRequest(
          this.tokenOwnerSoul1.address,
          1,
          1,
        ),
      ).be.reverted
      await expect(this.ERC5727ExampleContract.connect(this.voterSoul1).removeDelegateRequest(0)).be
        .reverted
      await this.ERC5727ExampleContract.removeDelegateRequest(0)
    })

    it('Only contract owner or delegate can delegate', async function () {
      await this.ERC5727ExampleContract.createDelegateRequest(this.tokenOwnerSoul1.address, 1, 1)
      await this.ERC5727ExampleContract.mintDelegate(this.delegateSoul1.address, 0)
      await this.ERC5727ExampleContract.connect(this.delegateSoul1).mintDelegate(
        this.delegateSoul2.address,
        0,
      )
      await expect(
        this.ERC5727ExampleContract.connect(this.delegateSoul1).mintDelegate(
          this.delegateSoul2.address,
          0,
        ),
      ).be.reverted

      await this.ERC5727ExampleContract.revokeDelegate(this.delegateSoul1.address, 0)
      await this.ERC5727ExampleContract.connect(this.delegateSoul1).revokeDelegate(
        this.delegateSoul2.address,
        0,
      )
      await expect(
        this.ERC5727ExampleContract.connect(this.delegateSoul1).revokeDelegate(
          this.delegateSoul2.address,
          0,
        ),
      ).be.reverted
    })

    it('Only contract owner or delegate can mint or revoke', async function () {
      await this.ERC5727ExampleContract.createDelegateRequest(this.tokenOwnerSoul1.address, 1, 1)
      await this.ERC5727ExampleContract.mintDelegate(this.delegateSoul1.address, 0)
      await this.ERC5727ExampleContract.delegateMint(0)
      await this.ERC5727ExampleContract.delegateMint(0)
      await this.ERC5727ExampleContract.connect(this.delegateSoul1).delegateMint(0)
      await expect(this.ERC5727ExampleContract.connect(this.delegateSoul1).delegateMint(0)).be
        .reverted

      await this.ERC5727ExampleContract.revokeDelegate(this.delegateSoul1.address, 1)
      await this.ERC5727ExampleContract.delegateRevoke(0)
      await this.ERC5727ExampleContract.connect(this.delegateSoul1).delegateRevoke(1)
      await expect(this.ERC5727ExampleContract.connect(this.delegateSoul1).delegateRevoke(2)).be
        .reverted
    })
  })

  describe('ERC5727Enumerable', function () {
    it('EmittedCount, soulsCount, balance of a soul can be correctly queried', async function () {
      await this.ERC5727ExampleContract.mintBatch(
        [
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul2.address,
        ],
        1,
        1,
        2664539263,
        false,
      )
      expect(await this.ERC5727ExampleContract.emittedCount()).equal(4)
      expect(await this.ERC5727ExampleContract.soulsCount()).equal(2)
      expect(await this.ERC5727ExampleContract.balanceOf(this.tokenOwnerSoul1.address)).equal(3)
      expect(await this.ERC5727ExampleContract.balanceOf(this.tokenOwnerSoul2.address)).equal(1)
    })

    it('Can correctly query if a soul holds valid tokens', async function () {
      await this.ERC5727ExampleContract.mintBatch(
        [
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul2.address,
        ],
        1,
        1,
        2664539263,
        false,
      )
      await this.ERC5727ExampleContract.revoke(0)
      await this.ERC5727ExampleContract.revoke(3)
      expect(await this.ERC5727ExampleContract.hasValid(this.tokenOwnerSoul1.address)).equal(true)
      expect(await this.ERC5727ExampleContract.hasValid(this.tokenOwnerSoul2.address)).equal(false)
    })

    it('Can correctly query a token of a soul by index', async function () {
      await this.ERC5727ExampleContract.mintBatch(
        [
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul2.address,
        ],
        1,
        1,
        2664539263,
        false,
      )
      expect(
        await this.ERC5727ExampleContract.tokenOfSoulByIndex(this.tokenOwnerSoul1.address, 0),
      ).equal(0)
      expect(
        await this.ERC5727ExampleContract.tokenOfSoulByIndex(this.tokenOwnerSoul2.address, 0),
      ).equal(3)
    })

    it('Revert when index overflows', async function () {
      await this.ERC5727ExampleContract.mintBatch(
        [
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul2.address,
        ],
        1,
        1,
        2664539263,
        false,
      )
      await expect(this.ERC5727ExampleContract.tokenOfSoulByIndex(this.tokenOwnerSoul1.address, 3))
        .be.reverted
      await expect(this.ERC5727ExampleContract.tokenOfSoulByIndex(this.tokenOwnerSoul2.address, 1))
        .be.reverted
    })
  })

  describe('ERC5727Expirable', function () {
    it('Query expiry date of a token and revert if the date is not set', async function () {
      await this.ERC5727ExampleContract.mintBatch(
        [
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul2.address,
        ],
        1,
        1,
        2664539263,
        false,
      )
      expect(await this.ERC5727ExampleContract.expiryDate(0)).equal(2664539263)
      await this.ERC5727ExampleContract.createDelegateRequest(this.tokenOwnerSoul1.address, 1, 1)
      await this.ERC5727ExampleContract.delegateMint(0)
      await expect(this.ERC5727ExampleContract.expiryDate(4)).be.reverted
    })

    it('Query if a token is expired and revert if the date is not set', async function () {
      await this.ERC5727ExampleContract.mintBatch(
        [
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul2.address,
        ],
        1,
        1,
        2664539263,
        false,
      )
      expect(await this.ERC5727ExampleContract.isExpired(0)).equal(false)
      await this.ERC5727ExampleContract.createDelegateRequest(this.tokenOwnerSoul1.address, 1, 1)
      await this.ERC5727ExampleContract.delegateMint(0)
      await expect(this.ERC5727ExampleContract.isExpired(4)).be.reverted
    })

    it('Revert when setting wrong expiry date', async function () {
      await this.ERC5727ExampleContract.mintBatch(
        [
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul2.address,
        ],
        1,
        1,
        2664539263,
        false,
      )
      await expect(this.ERC5727ExampleContract.setExpiryDate(0, 100000)).be.reverted
      await expect(this.ERC5727ExampleContract.setExpiryDate(0, 2664539262)).be.reverted
    })
  })

  describe('ERC5727Governance', function () {
    it('Approve to mint a token and approve to revoke the token', async function () {
      await this.ERC5727ExampleContract.createApprovalRequest(1, 1)
      await this.ERC5727ExampleContract.connect(this.voterSoul1).approveMint(
        this.tokenOwnerSoul1.address,
        0,
      )
      await expect(this.ERC5727ExampleContract.soulOf(0)).be.reverted
      await this.ERC5727ExampleContract.connect(this.voterSoul2).approveMint(
        this.tokenOwnerSoul1.address,
        0,
      )
      expect(await this.ERC5727ExampleContract.soulOf(0)).equal(this.tokenOwnerSoul1.address)
      expect(await this.ERC5727ExampleContract.isValid(0)).equal(true)
      await this.ERC5727ExampleContract.connect(this.voterSoul1).approveRevoke(0)
      await this.ERC5727ExampleContract.connect(this.voterSoul2).approveRevoke(0)
      expect(await this.ERC5727ExampleContract.isValid(0)).equal(false)
    })

    it('Revert when approving an approved request', async function () {
      await this.ERC5727ExampleContract.createApprovalRequest(1, 1)
      await this.ERC5727ExampleContract.connect(this.voterSoul1).approveMint(
        this.tokenOwnerSoul1.address,
        0,
      )
      await expect(
        this.ERC5727ExampleContract.connect(this.voterSoul1).approveMint(
          this.tokenOwnerSoul1.address,
          0,
        ),
      ).be.reverted
      await this.ERC5727ExampleContract.connect(this.voterSoul1).approveRevoke(0)
      await expect(this.ERC5727ExampleContract.connect(this.voterSoul1).approveRevoke(0)).be
        .reverted
    })

    it('Revert when a soul other than the creator try to remove an approval request', async function () {
      await this.ERC5727ExampleContract.connect(this.voterSoul1).createApprovalRequest(1, 1)
      await expect(this.ERC5727ExampleContract.removeApprovalRequest(0)).be.reverted
    })

    it('Revert when trying to remove a non voter', async function () {
      await expect(this.ERC5727ExampleContract.removeVoter(this.delegateSoul1.address)).be.reverted
    })

    it('Revert when trying to add a current voter', async function () {
      await expect(this.ERC5727ExampleContract.addVoter(this.voterSoul1.address)).be.reverted
    })

    it('Only contract owner can add or remove voters', async function () {
      await expect(
        this.ERC5727ExampleContract.connect(this.voterSoul1).removeVoter(this.voterSoul1.address),
      ).be.reverted
      await this.ERC5727ExampleContract.removeVoter(this.voterSoul1.address)
      await expect(
        this.ERC5727ExampleContract.connect(this.voterSoul1).addVoter(this.voterSoul1.address),
      ).be.reverted
      await this.ERC5727ExampleContract.addVoter(this.voterSoul1.address)
    })
  })

  describe('ERC5727Shadow', function () {
    it('Only manager can shadow or reveal a token', async function () {
      await this.ERC5727ExampleContract.mintBatch(
        [
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul2.address,
        ],
        1,
        1,
        2664539263,
        false,
      )
      await expect(this.ERC5727ExampleContract.connect(this.tokenOwnerSoul2).shadow(0)).be.reverted
      await this.ERC5727ExampleContract.connect(this.tokenOwnerSoul2).shadow(3)
      await this.ERC5727ExampleContract.shadow(0)
      await expect(this.ERC5727ExampleContract.connect(this.tokenOwnerSoul1).reveal(3)).be.reverted
      await this.ERC5727ExampleContract.connect(this.tokenOwnerSoul1).reveal(0)
      await this.ERC5727ExampleContract.reveal(3)
    })

    it('Only manager can query the shadowed information of a shadowed token', async function () {
      await this.ERC5727ExampleContract.mintBatch(
        [
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul1.address,
          this.tokenOwnerSoul2.address,
        ],
        1,
        1,
        2664539263,
        true,
      )
      await expect(this.ERC5727ExampleContract.connect(this.tokenOwnerSoul2).soulOf(0)).be.reverted
      await this.ERC5727ExampleContract.connect(this.tokenOwnerSoul2).valueOf(3)
      await this.ERC5727ExampleContract.slotOf(3)
    })
  })

  // describe('ERC5727Model', function () {
  //   it('', async function (){

  //   })
  // })
})

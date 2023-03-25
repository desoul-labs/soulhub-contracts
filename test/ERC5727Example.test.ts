import { expect } from 'chai';
import { ethers } from 'hardhat';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import {
  type IERC5727,
  IERC5727__factory,
  type ERC5727Example,
  type ERC5727Example__factory,
} from '../typechain';
import { type SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

interface Fixture {
  getCoreContract: (signer: SignerWithAddress) => IERC5727;
  ERC5727ExampleContract: ERC5727Example;
  admin: SignerWithAddress;
  tokenOwner1: SignerWithAddress;
  tokenOwner2: SignerWithAddress;
  voter1: SignerWithAddress;
  voter2: SignerWithAddress;
  delegate1: SignerWithAddress;
  delegate2: SignerWithAddress;
}

describe('ERC5727Test', function () {
  async function deployTokenFixture(): Promise<Fixture> {
    const ERC5727ExampleFactory: ERC5727Example__factory = await ethers.getContractFactory(
      'ERC5727Example',
    );
    const [admin, tokenOwner1, tokenOwner2, voter1, voter2, delegate1, delegate2] =
      await ethers.getSigners();
    const ERC5727ExampleContract = await ERC5727ExampleFactory.deploy(
      'Soularis',
      'SOUL',
      admin.address,
      [voter1.address, voter2.address],
      'https://api.soularis.io/contracts/',
      '1',
    );
    const getCoreContract = (signer: SignerWithAddress): IERC5727 =>
      IERC5727__factory.connect(ERC5727ExampleContract.address, signer);
    await ERC5727ExampleContract.deployed();
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
    };
  }
  describe('ERC5727', function () {
    it('Only admin can issue', async function () {
      const { getCoreContract, admin, tokenOwner1, tokenOwner2 } = await loadFixture(
        deployTokenFixture,
      );
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        1,
        admin.address,
        [],
      );
      expect(await coreContract['balanceOf(address)'](tokenOwner1.address)).equal(1);
      expect(await coreContract.ownerOf(1)).equal(tokenOwner1.address);
      const coreContractOther = getCoreContract(tokenOwner2);
      await expect(
        coreContractOther['issue(address,uint256,uint256,uint8,address,bytes)'](
          tokenOwner1.address,
          1,
          1,
          1,
          admin.address,
          [],
        ),
      ).be.reverted;
    });
    it('Only issuer can issue', async function () {
      const { getCoreContract, admin, tokenOwner1, tokenOwner2 } = await loadFixture(
        deployTokenFixture,
      );
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        1,
        admin.address,
        [],
      );
      expect(await coreContract.issuerOf(1)).equal(admin.address);
      await coreContract['issue(uint256,uint256,bytes)'](1, 100, []);
      const coreContractOther = getCoreContract(tokenOwner2);
      await expect(coreContractOther['issue(uint256,uint256,bytes)'](1, 100, [])).be.reverted;
    });
    it('Address balance will increase after issue', async function () {
      const { getCoreContract, admin, tokenOwner1 } = await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      expect(await coreContract['balanceOf(address)'](tokenOwner1.address)).equal(0);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        1,
        admin.address,
        [],
      );
      expect(await coreContract.issuerOf(1)).equal(admin.address);
      expect(await coreContract['balanceOf(address)'](tokenOwner1.address)).equal(1);
    });
    it('Token balance will increase after issue', async function () {
      const { getCoreContract, admin, tokenOwner1 } = await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        1,
        admin.address,
        [],
      );
      expect(await coreContract.issuerOf(1)).equal(admin.address);
      expect(await coreContract['balanceOf(uint256)'](1)).equal(0);
      await coreContract['issue(uint256,uint256,bytes)'](1, 100, []);
      expect(await coreContract['balanceOf(uint256)'](1)).equal(100);
    });
    it('Revert when transfer sbt', async function () {
      const { getCoreContract, admin, tokenOwner1, tokenOwner2 } = await loadFixture(
        deployTokenFixture,
      );
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        1,
        admin.address,
        [],
      );
      expect(await coreContract.ownerOf(1)).equal(tokenOwner1.address);
      await expect(
        coreContract['transferFrom(address,address,uint256)'](
          tokenOwner1.address,
          tokenOwner2.address,
          1,
        ),
      ).be.reverted;
      await expect(
        coreContract['transferFrom(uint256,address,uint256)'](1, tokenOwner2.address, 100),
      ).be.reverted;
      expect(await coreContract.ownerOf(1)).equal(tokenOwner1.address);
    });
    it('Issue should set right burnAuth', async function () {
      const { getCoreContract, admin, tokenOwner1 } = await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        2,
        1,
        1,
        admin.address,
        [],
      );
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        3,
        1,
        2,
        admin.address,
        [],
      );
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        4,
        1,
        3,
        admin.address,
        [],
      );
      expect(await coreContract.burnAuth(1)).equal(0);
      expect(await coreContract.burnAuth(2)).equal(1);
      expect(await coreContract.burnAuth(3)).equal(2);
      expect(await coreContract.burnAuth(4)).equal(3);
    });
    it('Only burner can revoke', async function () {
      const { getCoreContract, ERC5727ExampleContract, admin, tokenOwner1 } = await loadFixture(
        deployTokenFixture,
      );
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        10,
        1,
        0,
        admin.address,
        [],
      );
      const burnRoleFor1 = ethers.utils.hexZeroPad(ethers.utils.hexlify(2 ^ 10), 32);
      expect(
        await ERC5727ExampleContract.connect(admin).hasRole(burnRoleFor1, admin.address),
      ).equal(true);
      expect(
        await ERC5727ExampleContract.connect(admin).hasRole(burnRoleFor1, tokenOwner1.address),
      ).equal(false);
      const coreContractOwner1 = getCoreContract(tokenOwner1);
      await expect(coreContractOwner1['revoke(uint256,bytes)'](10, [])).be.reverted;
      await coreContract['revoke(uint256,bytes)'](10, []);
    });
    it('Revoke will decrease address token balance', async function () {
      const { getCoreContract, admin, tokenOwner1 } = await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        10,
        1,
        0,
        admin.address,
        [],
      );
      expect(await coreContract['balanceOf(address)'](tokenOwner1.address)).equal(1);
      await coreContract['revoke(uint256,bytes)'](10, []);
      expect(await coreContract['balanceOf(address)'](tokenOwner1.address)).equal(0);
    });
    it('Revoke amount will decrease token balance', async function () {
      const { getCoreContract, admin, tokenOwner1 } = await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        10,
        1,
        0,
        admin.address,
        [],
      );
      await coreContract['issue(uint256,uint256,bytes)'](10, 100, []);
      expect(await coreContract['balanceOf(uint256)'](10)).equal(100);
      await coreContract['revoke(uint256,uint256,bytes)'](10, 50, []);
      expect(await coreContract['balanceOf(uint256)'](10)).equal(50);
    });
    it('Only burner can revoke amount', async function () {
      const { getCoreContract, ERC5727ExampleContract, admin, tokenOwner1 } = await loadFixture(
        deployTokenFixture,
      );
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        10,
        1,
        0,
        admin.address,
        [],
      );
      await coreContract['issue(uint256,uint256,bytes)'](10, 100, []);
      const burnRoleFor1 = ethers.utils.hexZeroPad(ethers.utils.hexlify(2 ^ 10), 32);
      expect(
        await ERC5727ExampleContract.connect(admin).hasRole(burnRoleFor1, admin.address),
      ).equal(true);
      expect(
        await ERC5727ExampleContract.connect(admin).hasRole(burnRoleFor1, tokenOwner1.address),
      ).equal(false);
      const coreContractOwner1 = getCoreContract(tokenOwner1);
      expect(await coreContract['balanceOf(uint256)'](10)).equal(100);
      await expect(coreContractOwner1['revoke(uint256,uint256,bytes)'](10, 50, [])).be.reverted;
      await coreContract['revoke(uint256,uint256,bytes)'](10, 50, []);
      expect(await coreContract['balanceOf(uint256)'](10)).equal(50);
    });
  });
});

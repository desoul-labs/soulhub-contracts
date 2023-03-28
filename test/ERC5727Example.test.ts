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
import { MerkleTree } from 'merkletreejs';

interface Fixture {
  getCoreContract: (signer: SignerWithAddress) => IERC5727;
  ERC5727ExampleContract: ERC5727Example;
  admin: SignerWithAddress;
  tokenOwner1: SignerWithAddress;
  tokenOwner2: SignerWithAddress;
  voter1: SignerWithAddress;
  voter2: SignerWithAddress;
  operator1: SignerWithAddress;
  operator2: SignerWithAddress;
}
interface Leaf {
  address: string;
  tokenId: number;
  amount: number;
  slot: number;
  BurnAuth: number;
  verifier: string;
  data: string | [];
}
interface MerkleTreeStore {
  root: string;
  storedJSON: any;
}

describe('ERC5727Test', function () {
  async function deployTokenFixture(): Promise<Fixture> {
    const ERC5727ExampleFactory: ERC5727Example__factory = await ethers.getContractFactory(
      'ERC5727Example',
    );
    const [admin, tokenOwner1, tokenOwner2, voter1, voter2, operator1, operator2] =
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
      operator1,
      operator2,
    };
  }
  describe('ERC5727Core', function () {
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
    it('Revert if a token not exist is revoked', async function () {
      const { getCoreContract, admin } = await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      await expect(coreContract['revoke(uint256,bytes)'](100, [])).be.reverted;
      await expect(coreContract['revoke(uint256,uint256,bytes)'](100, 0, [])).be.reverted;
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
  describe('ERC5727Delegate', function () {
    it('Only admin can delegate', async function () {
      const {
        getCoreContract,
        ERC5727ExampleContract,
        admin,
        tokenOwner1,
        tokenOwner2,
        operator1,
      } = await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      await expect(ERC5727ExampleContract.connect(tokenOwner2).delegate(operator1.address, 1)).be
        .reverted;
      await ERC5727ExampleContract.connect(admin).delegate(operator1.address, 1);
    });
    it('Delegate should give operator the permission to issue tokens in a slot', async function () {
      const { getCoreContract, ERC5727ExampleContract, admin, tokenOwner1, operator1 } =
        await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      await ERC5727ExampleContract.connect(admin).delegate(operator1.address, 1);
      expect(await ERC5727ExampleContract.isOperatorFor(operator1.address, 1)).equal(true);
    });
    it('Delegate revert if operator already has delegation', async function () {
      const { getCoreContract, ERC5727ExampleContract, admin, tokenOwner1, operator1 } =
        await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      await ERC5727ExampleContract.connect(admin).delegate(operator1.address, 1);
      await expect(ERC5727ExampleContract.connect(admin).delegate(operator1.address, 1)).be
        .reverted;
    });
    it('Delegate revert when slot is a invalid slot', async function () {
      const { ERC5727ExampleContract, admin, operator1 } = await loadFixture(deployTokenFixture);
      await expect(ERC5727ExampleContract.connect(admin).delegate(operator1.address, 0)).be
        .reverted;
    });
    it('Delegate revert when operator address is the zero address', async function () {
      const { ERC5727ExampleContract, admin } = await loadFixture(deployTokenFixture);
      await expect(ERC5727ExampleContract.connect(admin).delegate(ethers.constants.AddressZero, 1))
        .be.reverted;
    });
    it('Only admin can undelegate', async function () {
      const {
        getCoreContract,
        ERC5727ExampleContract,
        admin,
        tokenOwner1,
        tokenOwner2,
        operator1,
      } = await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      await ERC5727ExampleContract.connect(admin).delegate(operator1.address, 1);
      await expect(ERC5727ExampleContract.connect(tokenOwner2).undelegate(operator1.address, 1)).be
        .reverted;
      await ERC5727ExampleContract.connect(admin).undelegate(operator1.address, 1);
    });
    it('Undelegate revert when slot is a invalid slot', async function () {
      const { ERC5727ExampleContract, admin, operator1 } = await loadFixture(deployTokenFixture);
      await expect(ERC5727ExampleContract.connect(admin).undelegate(operator1.address, 0)).be
        .reverted;
    });
    it('Undelegate revert when operator address is the zero address', async function () {
      const { getCoreContract, ERC5727ExampleContract, admin, tokenOwner1, operator1 } =
        await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      await ERC5727ExampleContract.connect(admin).delegate(operator1.address, 1);
      await expect(
        ERC5727ExampleContract.connect(admin).undelegate(ethers.constants.AddressZero, 1),
      ).be.reverted;
    });
    it("Undelegate revert when operator don't have delegation", async function () {
      const { getCoreContract, ERC5727ExampleContract, admin, tokenOwner1, operator1 } =
        await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      await expect(ERC5727ExampleContract.connect(admin).undelegate(operator1.address, 1)).be
        .reverted;
    });
  });
  describe('ERC5727Claimable', function () {
    function createMerkleTree(addresses: Leaf[]): MerkleTreeStore {
      const leaf = addresses.map((addr) =>
        ethers.utils.solidityKeccak256(
          ['address', 'uint256', 'uint256', 'uint256', 'uint8', 'address', 'bytes'],
          [
            addr.address,
            addr.tokenId,
            addr.amount,
            addr.slot,
            addr.BurnAuth,
            addr.verifier,
            addr.data,
          ],
        ),
      );
      const merkletree = new MerkleTree(leaf, ethers.utils.keccak256, { sortPairs: true });
      const root: string = merkletree.getHexRoot();
      const storedJSON: any = {};
      for (let i = 0; i < addresses.length; i++) {
        storedJSON[addresses[i].address] = {
          leaf: leaf[i],
          proof: merkletree.getHexProof(leaf[i]),
        };
      }
      return {
        root,
        storedJSON,
      };
    }
    it('Only amdin can set claim event', async function () {
      const { ERC5727ExampleContract, admin, tokenOwner1, tokenOwner2, operator1 } =
        await loadFixture(deployTokenFixture);
      const { root } = createMerkleTree([
        {
          address: tokenOwner1.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          BurnAuth: 0,
          verifier: admin.address,
          data: [],
        },
        {
          address: tokenOwner2.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          BurnAuth: 0,
          verifier: admin.address,
          data: [],
        },
      ]);
      await ERC5727ExampleContract.connect(admin).setClaimEvent(admin.address, 1, root);
      await expect(
        ERC5727ExampleContract.connect(operator1).setClaimEvent(operator1.address, 1, root),
      ).be.reverted;
    });
    it('Should revert when slot already has a issuer', async function () {
      const { ERC5727ExampleContract, admin, tokenOwner1, tokenOwner2, operator1 } =
        await loadFixture(deployTokenFixture);
      const { root } = createMerkleTree([
        {
          address: tokenOwner1.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          BurnAuth: 0,
          verifier: admin.address,
          data: [],
        },
        {
          address: tokenOwner2.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          BurnAuth: 0,
          verifier: admin.address,
          data: [],
        },
      ]);
      await ERC5727ExampleContract.connect(admin).setClaimEvent(
        admin.address,
        1,
        ethers.constants.HashZero,
      );
      await expect(ERC5727ExampleContract.connect(admin).setClaimEvent(operator1.address, 1, root))
        .be.reverted;
    });
    it('Should revert when slot already has a merkelRoot', async function () {
      const { ERC5727ExampleContract, admin, tokenOwner1, tokenOwner2, operator1 } =
        await loadFixture(deployTokenFixture);
      const { root } = createMerkleTree([
        {
          address: tokenOwner1.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          BurnAuth: 0,
          verifier: admin.address,
          data: [],
        },
        {
          address: tokenOwner2.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          BurnAuth: 0,
          verifier: admin.address,
          data: [],
        },
      ]);
      await ERC5727ExampleContract.connect(admin).setClaimEvent(
        ethers.constants.AddressZero,
        1,
        root,
      );
      await expect(ERC5727ExampleContract.connect(admin).setClaimEvent(operator1.address, 1, root))
        .be.reverted;
    });
    it('Can claim if address is in the merkletree', async function () {
      const { ERC5727ExampleContract, admin, tokenOwner1, tokenOwner2 } = await loadFixture(
        deployTokenFixture,
      );
      const { root, storedJSON } = createMerkleTree([
        {
          address: tokenOwner1.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          BurnAuth: 0,
          verifier: admin.address,
          data: [],
        },
        {
          address: tokenOwner2.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          BurnAuth: 0,
          verifier: admin.address,
          data: [],
        },
      ]);
      await ERC5727ExampleContract.connect(admin).setClaimEvent(admin.address, 1, root);
      await ERC5727ExampleContract.connect(tokenOwner1).claim(
        tokenOwner1.address,
        1,
        1,
        1,
        0,
        admin.address,
        [],
        storedJSON[tokenOwner1.address].proof,
      );
      await ERC5727ExampleContract.connect(tokenOwner2).claim(
        tokenOwner2.address,
        1,
        1,
        1,
        0,
        admin.address,
        [],
        storedJSON[tokenOwner2.address].proof,
      );
    });
    it('Slot balance and address balance will increase after claim', async function () {
      const { ERC5727ExampleContract, admin, tokenOwner1, tokenOwner2 } = await loadFixture(
        deployTokenFixture,
      );
      const { root, storedJSON } = createMerkleTree([
        {
          address: tokenOwner1.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          BurnAuth: 0,
          verifier: admin.address,
          data: [],
        },
        {
          address: tokenOwner2.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          BurnAuth: 0,
          verifier: admin.address,
          data: [],
        },
      ]);
      await ERC5727ExampleContract.connect(admin).setClaimEvent(admin.address, 1, root);
      await ERC5727ExampleContract.connect(tokenOwner1).claim(
        tokenOwner1.address,
        1,
        1,
        1,
        0,
        admin.address,
        [],
        storedJSON[tokenOwner1.address].proof,
      );
      expect(await ERC5727ExampleContract['balanceOf(uint256)'](1)).equal(1);
      expect(await ERC5727ExampleContract['balanceOf(address)'](tokenOwner1.address)).equal(1);
    });
    it('Revert if claimer', async function () {
      const { ERC5727ExampleContract, admin, tokenOwner1, tokenOwner2 } = await loadFixture(
        deployTokenFixture,
      );
      const { root, storedJSON } = createMerkleTree([
        {
          address: tokenOwner1.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          BurnAuth: 0,
          verifier: admin.address,
          data: [],
        },
        {
          address: tokenOwner2.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          BurnAuth: 0,
          verifier: admin.address,
          data: [],
        },
      ]);
      await ERC5727ExampleContract.connect(admin).setClaimEvent(admin.address, 1, root);
      await ERC5727ExampleContract.connect(tokenOwner1).claim(
        tokenOwner1.address,
        1,
        1,
        1,
        0,
        admin.address,
        [],
        storedJSON[tokenOwner1.address].proof,
      );
      expect(await ERC5727ExampleContract['balanceOf(uint256)'](1)).equal(1);
      expect(await ERC5727ExampleContract['balanceOf(address)'](tokenOwner1.address)).equal(1);
    });
  });
  describe('ERC5727Expirable', function () {
    it('Only issuer can set expiration', async function () {
      const { getCoreContract, ERC5727ExampleContract, admin, tokenOwner1, operator1 } =
        await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      const time = Math.floor(Date.now() / 1000);
      await expect(ERC5727ExampleContract.connect(operator1).setExpiration(1, time + 1000, true)).be
        .reverted;
      await ERC5727ExampleContract.connect(admin).setExpiration(1, time + 1000, true);
    });
    it('Set expiration will revert if expiration time is invaild', async function () {
      const { getCoreContract, ERC5727ExampleContract, admin, tokenOwner1 } = await loadFixture(
        deployTokenFixture,
      );
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      const time = Math.floor(Date.now() / 1000);
      console.log(time);
      await expect(
        ERC5727ExampleContract.connect(admin).setExpiration(1, 0, true),
      ).to.be.revertedWithCustomError(ERC5727ExampleContract, 'NullValue');
      await expect(ERC5727ExampleContract.connect(admin).setExpiration(1, time - 1000, true)).be
        .reverted;
    });
    it('Set expiration will revert if token id is invaild', async function () {
      const { ERC5727ExampleContract, admin } = await loadFixture(deployTokenFixture);
      const time = Math.floor(Date.now() / 1000);
      await expect(ERC5727ExampleContract.connect(admin).setExpiration(1, time + 1000, true)).be
        .reverted;
    });
    it('Set expiration will revert if token already has a expiration', async function () {
      const { getCoreContract, ERC5727ExampleContract, admin, tokenOwner1 } = await loadFixture(
        deployTokenFixture,
      );
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      const time = Math.floor(Date.now() / 1000);
      await ERC5727ExampleContract.connect(admin).setExpiration(1, time + 1000, true);
      await expect(ERC5727ExampleContract.connect(admin).setExpiration(1, time + 1000, true)).be
        .reverted;
    });
    it('Set expiration should set right expiration time', async function () {
      const { getCoreContract, ERC5727ExampleContract, admin, tokenOwner1 } = await loadFixture(
        deployTokenFixture,
      );
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      const time = Math.floor(Date.now() / 1000);
      await ERC5727ExampleContract.connect(admin).setExpiration(1, time + 1000, true);
      expect(await ERC5727ExampleContract.expiresAt(1)).equal(time + 1000);
    });
    it('ExpiresAt will revert if token id is invaild', async function () {
      const { ERC5727ExampleContract } = await loadFixture(deployTokenFixture);
      await expect(ERC5727ExampleContract.expiresAt(1)).be.revertedWithCustomError(
        ERC5727ExampleContract,
        'NotFound',
      );
    });
    it('ExpiresAt will revert if token has no expiration', async function () {
      const { getCoreContract, ERC5727ExampleContract, admin, tokenOwner1 } = await loadFixture(
        deployTokenFixture,
      );
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      await expect(ERC5727ExampleContract.expiresAt(1)).be.revertedWithCustomError(
        ERC5727ExampleContract,
        'NoExpiration',
      );
    });
    it('Renew will revert if token is not renewable', async function () {
      const { getCoreContract, ERC5727ExampleContract, admin, tokenOwner1 } = await loadFixture(
        deployTokenFixture,
      );
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      const time = Math.floor(Date.now() / 1000);
      await ERC5727ExampleContract.connect(admin).setExpiration(1, time + 1000, false);
      await expect(
        ERC5727ExampleContract.connect(admin).renewSubscription(1, 1000),
      ).be.revertedWithCustomError(ERC5727ExampleContract, 'NotRenewable');
    });
    it('Renew will revert if duration is invaild', async function () {
      const { getCoreContract, ERC5727ExampleContract, admin, tokenOwner1 } = await loadFixture(
        deployTokenFixture,
      );
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      const time = Math.floor(Date.now() / 1000);
      await ERC5727ExampleContract.connect(admin).setExpiration(1, time + 1000, true);
      await expect(ERC5727ExampleContract.connect(admin).renewSubscription(1, 0)).be.reverted;
    });
    it('Only issuer or owner can renew', async function () {
      const { getCoreContract, ERC5727ExampleContract, admin, tokenOwner1, operator1 } =
        await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      const time = Math.floor(Date.now() / 1000);
      await ERC5727ExampleContract.connect(admin).setExpiration(1, time + 1000, true);
      await expect(ERC5727ExampleContract.connect(operator1).renewSubscription(1, 1000)).be
        .reverted;
      await ERC5727ExampleContract.connect(admin).renewSubscription(1, 1000);
      await ERC5727ExampleContract.connect(tokenOwner1).renewSubscription(1, 1000);
    });
    it('Renew will increase expiration time', async function () {
      const { getCoreContract, ERC5727ExampleContract, admin, tokenOwner1 } = await loadFixture(
        deployTokenFixture,
      );
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      const time = Math.floor(Date.now() / 1000);
      await ERC5727ExampleContract.connect(admin).setExpiration(1, time + 1000, true);
      expect(await ERC5727ExampleContract.expiresAt(1)).equal(time + 1000);
      await ERC5727ExampleContract.connect(tokenOwner1).renewSubscription(1, 1000);
      expect(await ERC5727ExampleContract.expiresAt(1)).equal(time + 2000);
    });
    it('Cancel Subscription will revert if token is not renewable', async function () {
      const { getCoreContract, ERC5727ExampleContract, admin, tokenOwner1 } = await loadFixture(
        deployTokenFixture,
      );
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      const time = Math.floor(Date.now() / 1000);
      await ERC5727ExampleContract.connect(admin).setExpiration(1, time + 1000, false);
      await expect(
        ERC5727ExampleContract.connect(admin).cancelSubscription(1),
      ).be.revertedWithCustomError(ERC5727ExampleContract, 'NotRenewable');
    });
    it('Cancel Subscription will revert if token is invaild', async function () {
      const { getCoreContract, ERC5727ExampleContract, admin, tokenOwner1 } = await loadFixture(
        deployTokenFixture,
      );
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      const time = Math.floor(Date.now() / 1000);
      await ERC5727ExampleContract.connect(admin).setExpiration(1, time + 1000, false);
      await expect(
        ERC5727ExampleContract.connect(admin).cancelSubscription(1),
      ).be.revertedWithCustomError(ERC5727ExampleContract, 'NotRenewable');
    });
  });
  describe('ERC5727Enumerable', function () {});
});

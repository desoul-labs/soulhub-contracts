import { expect } from 'chai';
import { ethers } from 'hardhat';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { anyValue } from '@nomicfoundation/hardhat-chai-matchers/withArgs';
import {
  type IERC5727,
  type ERC5727Example,
  type ERC5727Example__factory,
  type IERC5727Recovery,
  type IERC5727Enumerable,
  type ERC5727Governance,
  IERC5727__factory,
  IERC5727Recovery__factory,
  IERC5727Enumerable__factory,
  ERC5727Governance__factory,
} from '../typechain';
import { type SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { MerkleTree } from 'merkletreejs';

interface Fixture {
  getCoreContract: (signer: SignerWithAddress) => IERC5727;
  getRecoveryContract: (signer: SignerWithAddress) => IERC5727Recovery;
  getEnumerableContract: (signer: SignerWithAddress) => IERC5727Enumerable;
  getGovernanceContract: (signer: SignerWithAddress) => ERC5727Governance;
  ERC5727ExampleContract: ERC5727Example;
  admin: SignerWithAddress;
  tokenOwner1: SignerWithAddress;
  tokenOwner2: SignerWithAddress;
  voter1: SignerWithAddress;
  voter2: SignerWithAddress;
  operator1: SignerWithAddress;
  operator2: SignerWithAddress;
}
interface ClaimData {
  to: string;
  tokenId: number;
  amount: number;
  slot: number;
  burnAuth: number;
  verifier: string;
  data: string | [];
}
interface MerkleTreeStore {
  root: string;
  proofs: Record<string, string[]>;
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
      'https://api.soularis.io/contracts/',
      '1',
    );
    const getCoreContract = (signer: SignerWithAddress): IERC5727 =>
      IERC5727__factory.connect(ERC5727ExampleContract.address, signer);
    const getRecoveryContract = (signer: SignerWithAddress): IERC5727Recovery =>
      IERC5727Recovery__factory.connect(ERC5727ExampleContract.address, signer);
    const getEnumerableContract = (signer: SignerWithAddress): IERC5727Enumerable =>
      IERC5727Enumerable__factory.connect(ERC5727ExampleContract.address, signer);
    const getGovernanceContract = (signer: SignerWithAddress): ERC5727Governance =>
      ERC5727Governance__factory.connect(ERC5727ExampleContract.address, signer);
    await ERC5727ExampleContract.deployed();
    return {
      getCoreContract,
      getRecoveryContract,
      getEnumerableContract,
      getGovernanceContract,
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
    it('only admin can issue', async function () {
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

    it('only issuer can issue', async function () {
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

    it('should increase account balance after issue', async function () {
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

    it('should increase token balance after issue', async function () {
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

    it('should revert on transfer', async function () {
      const { getCoreContract, admin, tokenOwner1, tokenOwner2, ERC5727ExampleContract } =
        await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      const coreContractOwner1 = getCoreContract(tokenOwner1);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        1,
        admin.address,
        [],
      );
      await coreContract['issue(uint256,uint256,bytes)'](1, 100, []);
      expect(await coreContract.ownerOf(1)).equal(tokenOwner1.address);
      expect(await coreContract['balanceOf(uint256)'](1)).equal(100);
      await expect(
        coreContractOwner1['transferFrom(address,address,uint256)'](
          tokenOwner1.address,
          tokenOwner2.address,
          1,
        ),
      ).be.revertedWithCustomError(ERC5727ExampleContract, 'Soulbound');

      expect(await coreContract.ownerOf(1)).equal(tokenOwner1.address);
    });

    it('should revert on transfer value', async function () {
      const { getCoreContract, admin, tokenOwner1, tokenOwner2, ERC5727ExampleContract } =
        await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      const coreContractOwner1 = getCoreContract(tokenOwner1);
      const coreContractOwner2 = getCoreContract(tokenOwner2);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        1,
        admin.address,
        [],
      );
      await coreContract['issue(uint256,uint256,bytes)'](1, 100, []);
      expect(await coreContract.ownerOf(1)).equal(tokenOwner1.address);
      expect(await coreContract['balanceOf(uint256)'](1)).equal(100);
      await coreContractOwner1['approve(uint256,address,uint256)'](1, tokenOwner2.address, 100);
      await expect(
        coreContractOwner2['transferFrom(uint256,address,uint256)'](1, tokenOwner2.address, 50),
      ).revertedWithCustomError(ERC5727ExampleContract, 'Soulbound');
      await expect(
        coreContractOwner1['transferFrom(uint256,address,uint256)'](1, tokenOwner2.address, 50),
      ).revertedWithCustomError(ERC5727ExampleContract, 'Soulbound');
      expect(await coreContract['balanceOf(uint256)'](1)).equal(100);
      expect(await coreContract.ownerOf(1)).equal(tokenOwner1.address);
    });

    it('should revert on approve if unauthorized', async function () {
      const { getCoreContract, admin, tokenOwner1, tokenOwner2, operator1 } = await loadFixture(
        deployTokenFixture,
      );
      const coreContract = getCoreContract(admin);
      const coreContractOwner1 = getCoreContract(tokenOwner1);
      const coreContractOwner2 = getCoreContract(tokenOwner2);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        1,
        admin.address,
        [],
      );
      await coreContract['issue(uint256,uint256,bytes)'](1, 100, []);
      await expect(
        coreContractOwner2['approve(uint256,address,uint256)'](1, operator1.address, 100),
      ).reverted;
      await coreContractOwner1['approve(uint256,address,uint256)'](1, operator1.address, 100);
    });

    it('should set burnAuth correctly', async function () {
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

    it('only burner can revoke', async function () {
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
      expect(await ERC5727ExampleContract.connect(admin).owner()).equal(admin.address);
      expect(await ERC5727ExampleContract.connect(admin).hasBurnRole(tokenOwner1.address, 1)).equal(
        false,
      );
      const coreContractOwner1 = getCoreContract(tokenOwner1);
      await expect(coreContractOwner1['revoke(uint256,bytes)'](10, [])).be.reverted;
      await coreContract['revoke(uint256,bytes)'](10, []);
    });

    it('should revert on revoke if token does not exist', async function () {
      const { getCoreContract, admin } = await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      await expect(coreContract['revoke(uint256,bytes)'](100, [])).be.reverted;
      await expect(coreContract['revoke(uint256,uint256,bytes)'](100, 0, [])).be.reverted;
    });

    it('should set revoked if token is revoked', async function () {
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
      await coreContract['revoke(uint256,bytes)'](10, []);
      expect(await coreContract.isRevoked(10)).equal(true);
    });

    it('should decrease token balance if amount is revoked', async function () {
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

    it('only burner can revoke amount', async function () {
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
      expect(await ERC5727ExampleContract.hasBurnRole(admin.address, 10)).equal(true);
      expect(await ERC5727ExampleContract.hasBurnRole(tokenOwner1.address, 10)).equal(false);
      const coreContractOwner1 = getCoreContract(tokenOwner1);
      expect(await coreContract['balanceOf(uint256)'](10)).equal(100);
      await expect(coreContractOwner1['revoke(uint256,uint256,bytes)'](10, 50, [])).be.reverted;
      await coreContract['revoke(uint256,uint256,bytes)'](10, 50, []);
      expect(await coreContract['balanceOf(uint256)'](10)).equal(50);
    });
    it('query verifier of token', async function () {
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
      expect(await coreContract.verifierOf(10)).equal(admin.address);
    });
    it('should revert on query verifier of token if token id is invaild', async function () {
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
      await expect(coreContract.verifierOf(1)).be.reverted;
    });
    it('query if token is locked', async function () {
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
      expect(await coreContract.locked(10)).equal(true);
    });
    it('should revert on query if token is locked if token id is invaild', async function () {
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
      expect(await coreContract.locked(10)).equal(true);
      await expect(coreContract.locked(1)).be.reverted;
    });
  });

  describe('ERC5727Delegate', function () {
    it('only admin can delegate', async function () {
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

    it('should grant operator the permission to issue tokens in a slot', async function () {
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
      expect(await ERC5727ExampleContract.isOperatorFor(operator1.address, 2)).equal(false);
      expect(await ERC5727ExampleContract.hasMintRole(operator1.address, 1)).equal(true);
      await ERC5727ExampleContract.connect(operator1)[
        'issue(address,uint256,uint256,uint8,address,bytes)'
      ](tokenOwner1.address, 2, 1, 0, admin.address, []);
      expect(await ERC5727ExampleContract.ownerOf(2)).equal(tokenOwner1.address);
    });

    it('should revert if operator is already delegated', async function () {
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

    it('should revert on delegate if slot is invalid', async function () {
      const { ERC5727ExampleContract, admin, operator1 } = await loadFixture(deployTokenFixture);
      await expect(ERC5727ExampleContract.connect(admin).delegate(operator1.address, 0)).be
        .reverted;
    });

    it('should revert on delegate if operator is invalid', async function () {
      const { ERC5727ExampleContract, admin } = await loadFixture(deployTokenFixture);
      await expect(ERC5727ExampleContract.connect(admin).delegate(ethers.constants.AddressZero, 1))
        .be.reverted;
    });

    it('only admin can undelegate', async function () {
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

    it('should revert on undelegate if slot is invalid', async function () {
      const { ERC5727ExampleContract, admin, operator1 } = await loadFixture(deployTokenFixture);
      await expect(ERC5727ExampleContract.connect(admin).undelegate(operator1.address, 0)).be
        .reverted;
    });

    it('should revert on undelegate if operator is invalid', async function () {
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

    it('should revert on undelegate if operator is not delegated', async function () {
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
    function createMerkleTree(data: ClaimData[]): MerkleTreeStore {
      const leafNodes = data.map((d) =>
        ethers.utils.solidityKeccak256(
          ['address', 'uint256', 'uint256', 'uint256', 'uint8', 'address', 'bytes'],
          Object.values(d),
        ),
      );
      const merkletree = new MerkleTree(leafNodes, ethers.utils.keccak256, { sortPairs: true });
      const root: string = merkletree.getHexRoot();
      const proofs: Record<string, string[]> = {};
      for (let i = 0; i < data.length; i++) {
        proofs[data[i].to] = merkletree.getHexProof(leafNodes[i]);
      }
      return {
        root,
        proofs,
      };
    }

    it('only admin can set claim events', async function () {
      const { ERC5727ExampleContract, admin, tokenOwner1, tokenOwner2, operator1 } =
        await loadFixture(deployTokenFixture);
      const { root } = createMerkleTree([
        {
          to: tokenOwner1.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          burnAuth: 0,
          verifier: admin.address,
          data: [],
        },
        {
          to: tokenOwner2.address,
          tokenId: 2,
          amount: 1,
          slot: 1,
          burnAuth: 0,
          verifier: admin.address,
          data: [],
        },
      ]);
      await ERC5727ExampleContract.connect(admin).setClaimEvent(admin.address, 1, root);
      await expect(
        ERC5727ExampleContract.connect(operator1).setClaimEvent(operator1.address, 1, root),
      ).be.reverted;
    });

    it('should revert if claim event is already set for a slot', async function () {
      const { ERC5727ExampleContract, admin, tokenOwner1, tokenOwner2, operator1 } =
        await loadFixture(deployTokenFixture);
      const { root } = createMerkleTree([
        {
          to: tokenOwner1.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          burnAuth: 0,
          verifier: admin.address,
          data: [],
        },
        {
          to: tokenOwner2.address,
          tokenId: 2,
          amount: 1,
          slot: 1,
          burnAuth: 0,
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

    it('should claim if account is eligible', async function () {
      const { ERC5727ExampleContract, admin, tokenOwner1, tokenOwner2 } = await loadFixture(
        deployTokenFixture,
      );
      const { root, proofs } = createMerkleTree([
        {
          to: tokenOwner1.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          burnAuth: 0,
          verifier: admin.address,
          data: [],
        },
        {
          to: tokenOwner2.address,
          tokenId: 2,
          amount: 1,
          slot: 1,
          burnAuth: 0,
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
        proofs[tokenOwner1.address],
      );
      await ERC5727ExampleContract.connect(tokenOwner2).claim(
        tokenOwner2.address,
        2,
        1,
        1,
        0,
        admin.address,
        [],
        proofs[tokenOwner2.address],
      );
    });

    it('should increase balances after claim', async function () {
      const { ERC5727ExampleContract, admin, tokenOwner1, tokenOwner2 } = await loadFixture(
        deployTokenFixture,
      );
      const { root, proofs } = createMerkleTree([
        {
          to: tokenOwner1.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          burnAuth: 0,
          verifier: admin.address,
          data: [],
        },
        {
          to: tokenOwner2.address,
          tokenId: 2,
          amount: 1,
          slot: 1,
          burnAuth: 0,
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
        proofs[tokenOwner1.address],
      );
      await ERC5727ExampleContract.connect(tokenOwner2).claim(
        tokenOwner2.address,
        2,
        1,
        1,
        0,
        admin.address,
        [],
        proofs[tokenOwner2.address],
      );
      expect(await ERC5727ExampleContract['balanceOf(uint256)'](1)).equal(1);
      expect(await ERC5727ExampleContract['balanceOf(address)'](tokenOwner1.address)).equal(1);
      expect(await ERC5727ExampleContract['balanceOf(uint256)'](2)).equal(1);
      expect(await ERC5727ExampleContract['balanceOf(address)'](tokenOwner2.address)).equal(1);
    });

    it('revert if claimer already claimed', async function () {
      const { ERC5727ExampleContract, admin, tokenOwner1, tokenOwner2 } = await loadFixture(
        deployTokenFixture,
      );
      const { root, proofs } = createMerkleTree([
        {
          to: tokenOwner1.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          burnAuth: 0,
          verifier: admin.address,
          data: [],
        },
        {
          to: tokenOwner2.address,
          tokenId: 2,
          amount: 1,
          slot: 1,
          burnAuth: 0,
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
        proofs[tokenOwner1.address],
      );
      expect(await ERC5727ExampleContract['balanceOf(uint256)'](1)).equal(1);
      expect(await ERC5727ExampleContract['balanceOf(address)'](tokenOwner1.address)).equal(1);
      await expect(
        ERC5727ExampleContract.connect(tokenOwner1).claim(
          tokenOwner1.address,
          1,
          1,
          1,
          0,
          admin.address,
          [],
          proofs[tokenOwner1.address],
        ),
      ).be.reverted;
    });
    it('query if a slot is claimed', async function () {
      const { ERC5727ExampleContract, admin, tokenOwner1, tokenOwner2 } = await loadFixture(
        deployTokenFixture,
      );
      const { root, proofs } = createMerkleTree([
        {
          to: tokenOwner1.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          burnAuth: 0,
          verifier: admin.address,
          data: [],
        },
        {
          to: tokenOwner2.address,
          tokenId: 2,
          amount: 1,
          slot: 1,
          burnAuth: 0,
          verifier: admin.address,
          data: [],
        },
      ]);
      await ERC5727ExampleContract.connect(admin).setClaimEvent(admin.address, 1, root);
      expect(await ERC5727ExampleContract.connect(admin).isClaimed(tokenOwner1.address, 1)).equal(
        false,
      );
      await ERC5727ExampleContract.connect(tokenOwner1).claim(
        tokenOwner1.address,
        1,
        1,
        1,
        0,
        admin.address,
        [],
        proofs[tokenOwner1.address],
      );
      expect(await ERC5727ExampleContract.connect(admin).isClaimed(tokenOwner1.address, 1)).equal(
        true,
      );
    });
    it('revert if claimer is not eligible', async function () {
      const { ERC5727ExampleContract, admin, tokenOwner1, tokenOwner2, operator1 } =
        await loadFixture(deployTokenFixture);
      const { root, proofs } = createMerkleTree([
        {
          to: tokenOwner1.address,
          tokenId: 1,
          amount: 1,
          slot: 1,
          burnAuth: 0,
          verifier: admin.address,
          data: [],
        },
        {
          to: tokenOwner2.address,
          tokenId: 2,
          amount: 1,
          slot: 1,
          burnAuth: 0,
          verifier: admin.address,
          data: [],
        },
      ]);
      await ERC5727ExampleContract.connect(admin).setClaimEvent(admin.address, 1, root);
      await expect(
        ERC5727ExampleContract.connect(operator1).claim(
          tokenOwner1.address,
          1,
          1,
          1,
          0,
          admin.address,
          [],
          proofs[tokenOwner1.address],
        ),
      ).be.reverted;
    });
  });

  describe('ERC5727Expirable', function () {
    it('only issuer can set expiration', async function () {
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

    it('should revert on setExpiration if expiration time is invalid', async function () {
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
      await expect(
        ERC5727ExampleContract.connect(admin).setExpiration(1, 0, true),
      ).to.be.revertedWithCustomError(ERC5727ExampleContract, 'NullValue');
      await expect(ERC5727ExampleContract.connect(admin).setExpiration(1, time - 1000, true)).be
        .reverted;
    });

    it('should revert on setExpiration if token id is invalid', async function () {
      const { ERC5727ExampleContract, admin } = await loadFixture(deployTokenFixture);
      const time = Math.floor(Date.now() / 1000);
      await expect(ERC5727ExampleContract.connect(admin).setExpiration(1, time + 1000, true)).be
        .reverted;
    });

    it('should revert on setExpiration if expiration is already set for a token', async function () {
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

    it('should set expiration time correctly', async function () {
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

    it('should revert on expireAt if token id is invalid', async function () {
      const { ERC5727ExampleContract } = await loadFixture(deployTokenFixture);
      await expect(ERC5727ExampleContract.expiresAt(1)).be.revertedWithCustomError(
        ERC5727ExampleContract,
        'NotFound',
      );
    });

    it('should revert on expireAt if expiration is not set for a token', async function () {
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

    it('should revert on renewSubscription if token is not renewable', async function () {
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

    it('should revert on renewSubscription if duration is invalid', async function () {
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

    it('only issuer or owner can renew subscription', async function () {
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

    it('should increase expiration time after subscription is renewed', async function () {
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

    it('should revert on cancelSubscription if token is not renewable', async function () {
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

    it('should revert on cancelSubscription if token does not exist', async function () {
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
    it('only manager can cancel subscription', async function () {
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
      expect(await ERC5727ExampleContract.isRenewable(1)).equal(true);
      await expect(ERC5727ExampleContract.connect(operator1).cancelSubscription(1)).be.reverted;
      await ERC5727ExampleContract.connect(admin).cancelSubscription(1);
    });
    it('cancel subscription should clear expiration', async function () {
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
      expect(await ERC5727ExampleContract.isRenewable(1)).equal(true);
      await expect(ERC5727ExampleContract.connect(operator1).cancelSubscription(1)).be.reverted;
      await ERC5727ExampleContract.connect(admin).cancelSubscription(1);
    });
    it('query if token is renewable', async function () {
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
      expect(await ERC5727ExampleContract.isRenewable(1)).equal(true);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        2,
        1,
        0,
        admin.address,
        [],
      );
      await ERC5727ExampleContract.connect(admin).setExpiration(2, time + 1000, false);
      expect(await ERC5727ExampleContract.isRenewable(2)).equal(false);
    });
    it('should revert on query if token is renewable if token does not exist', async function () {
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
      await expect(ERC5727ExampleContract.isRenewable(0)).be.reverted;
    });
  });

  describe('ERC5727Enumerable', function () {
    it('query slot count of owner', async function () {
      const { getCoreContract, admin, tokenOwner1, getEnumerableContract } = await loadFixture(
        deployTokenFixture,
      );
      const coreContract = getCoreContract(admin);
      const enumerableContract = getEnumerableContract(admin);
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
        2,
        0,
        admin.address,
        [],
      );
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        3,
        3,
        0,
        admin.address,
        [],
      );
      expect(await enumerableContract.slotCountOfOwner(tokenOwner1.address)).equal(3);
    });
    it('query slot of owner by index', async function () {
      const { getCoreContract, admin, tokenOwner1, getEnumerableContract } = await loadFixture(
        deployTokenFixture,
      );
      const coreContract = getCoreContract(admin);
      const enumerableContract = getEnumerableContract(admin);
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
        2,
        0,
        admin.address,
        [],
      );
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        3,
        3,
        0,
        admin.address,
        [],
      );
      expect(await enumerableContract.slotOfOwnerByIndex(tokenOwner1.address, 0)).equal(1);
      expect(await enumerableContract.slotOfOwnerByIndex(tokenOwner1.address, 1)).equal(2);
      expect(await enumerableContract.slotOfOwnerByIndex(tokenOwner1.address, 2)).equal(3);
    });
    it('query owner balance in slot', async function () {
      const { getCoreContract, admin, tokenOwner1, getEnumerableContract } = await loadFixture(
        deployTokenFixture,
      );
      const coreContract = getCoreContract(admin);
      const enumerableContract = getEnumerableContract(admin);
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
        0,
        admin.address,
        [],
      );
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        3,
        1,
        0,
        admin.address,
        [],
      );
      expect(await enumerableContract.ownerBalanceInSlot(tokenOwner1.address, 1)).equal(3);
    });
    it('should revert on query slot of owner by index if index out of bounds', async function () {
      const { getCoreContract, admin, tokenOwner1, getEnumerableContract, ERC5727ExampleContract } =
        await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      const enumerableContract = getEnumerableContract(admin);
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
        2,
        0,
        admin.address,
        [],
      );
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        3,
        3,
        0,
        admin.address,
        [],
      );
      expect(await enumerableContract.slotOfOwnerByIndex(tokenOwner1.address, 0)).equal(1);
      expect(await enumerableContract.slotOfOwnerByIndex(tokenOwner1.address, 1)).equal(2);
      expect(await enumerableContract.slotOfOwnerByIndex(tokenOwner1.address, 2)).equal(3);
      await expect(
        enumerableContract.slotOfOwnerByIndex(tokenOwner1.address, 3),
      ).be.revertedWithCustomError(ERC5727ExampleContract, 'IndexOutOfBounds');
    });
    it('should revert on query slot count if owner is invaild', async function () {
      const { getCoreContract, admin, tokenOwner1, getEnumerableContract, ERC5727ExampleContract } =
        await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      const enumerableContract = getEnumerableContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      await expect(
        enumerableContract.slotCountOfOwner(ethers.constants.AddressZero),
      ).be.revertedWithCustomError(ERC5727ExampleContract, 'NullValue');
    });
    it('should revert on query owner balance in slot if owner is invaild', async function () {
      const { getCoreContract, admin, tokenOwner1, getEnumerableContract, ERC5727ExampleContract } =
        await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      const enumerableContract = getEnumerableContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      await expect(
        enumerableContract.ownerBalanceInSlot(ethers.constants.AddressZero, 1),
      ).be.revertedWithCustomError(ERC5727ExampleContract, 'NullValue');
    });
    it('should revert on query owner balance in slot if slot is invaild', async function () {
      const { getCoreContract, admin, tokenOwner1, getEnumerableContract, ERC5727ExampleContract } =
        await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      const enumerableContract = getEnumerableContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      await expect(
        enumerableContract.ownerBalanceInSlot(tokenOwner1.address, 3),
      ).be.revertedWithCustomError(ERC5727ExampleContract, 'NotFound');
    });
    it('should revert on query slot of owner by index if owner is invaild', async function () {
      const { getCoreContract, admin, tokenOwner1, getEnumerableContract, ERC5727ExampleContract } =
        await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      const enumerableContract = getEnumerableContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        0,
        admin.address,
        [],
      );
      await expect(
        enumerableContract.slotOfOwnerByIndex(ethers.constants.AddressZero, 1),
      ).be.revertedWithCustomError(ERC5727ExampleContract, 'NullValue');
    });
  });
  describe('ERC5727Governance', function () {
    it('admin should has voter role', async function () {
      const { getGovernanceContract, admin } = await loadFixture(deployTokenFixture);
      const governanceContract = getGovernanceContract(admin);
      expect(await governanceContract.isVoter(admin.address)).equal(true);
    });
    it('only admin can add voter', async function () {
      const { getGovernanceContract, admin, voter1, operator1 } = await loadFixture(
        deployTokenFixture,
      );
      const governanceContract = getGovernanceContract(admin);
      const governanceContractOperator = getGovernanceContract(operator1);
      await expect(governanceContractOperator.addVoter(voter1.address)).be.reverted;
      await governanceContract.addVoter(voter1.address);
    });
    it('only admin can remove voter', async function () {
      const { getGovernanceContract, admin, voter1, operator1 } = await loadFixture(
        deployTokenFixture,
      );
      const governanceContract = getGovernanceContract(admin);
      const governanceContractOperator = getGovernanceContract(operator1);
      await governanceContract.addVoter(voter1.address);
      await expect(governanceContractOperator.removeVoter(voter1.address)).be.reverted;
      await governanceContract.removeVoter(voter1.address);
    });
    it('add voter should set voter role correctly', async function () {
      const { getGovernanceContract, admin, voter1 } = await loadFixture(deployTokenFixture);
      const governanceContract = getGovernanceContract(admin);
      await governanceContract.addVoter(voter1.address);
      expect(await governanceContract.isVoter(voter1.address)).equal(true);
    });
    it('remove voter should remove voter role correctly', async function () {
      const { getGovernanceContract, admin, voter1 } = await loadFixture(deployTokenFixture);
      const governanceContract = getGovernanceContract(admin);
      await governanceContract.addVoter(voter1.address);
      await governanceContract.removeVoter(voter1.address);
      expect(await governanceContract.isVoter(voter1.address)).equal(false);
    });
    it('query voter count should return correct count', async function () {
      const { getGovernanceContract, admin, voter1 } = await loadFixture(deployTokenFixture);
      const governanceContract = getGovernanceContract(admin);
      expect(await governanceContract.voterCount()).equal(1);
      await governanceContract.addVoter(voter1.address);
      expect(await governanceContract.voterCount()).equal(2);
    });
    it('query voter by index should return correct voter', async function () {
      const { getGovernanceContract, admin, voter1 } = await loadFixture(deployTokenFixture);
      const governanceContract = getGovernanceContract(admin);
      expect(await governanceContract.voterByIndex(0)).equal(admin.address);
      await governanceContract.addVoter(voter1.address);
      expect(await governanceContract.voterByIndex(1)).equal(voter1.address);
    });
    it('should revert query voter by index if index out of bounds', async function () {
      const { getGovernanceContract, admin, voter1 } = await loadFixture(deployTokenFixture);
      const governanceContract = getGovernanceContract(admin);
      expect(await governanceContract.voterByIndex(0)).equal(admin.address);
      await governanceContract.addVoter(voter1.address);
      expect(await governanceContract.voterByIndex(1)).equal(voter1.address);
      await expect(governanceContract.voterByIndex(2)).be.reverted;
    });
    it('should revert on add voter if voter is already a voter', async function () {
      const { getGovernanceContract, admin, voter1 } = await loadFixture(deployTokenFixture);
      const governanceContract = getGovernanceContract(admin);
      expect(await governanceContract.voterByIndex(0)).equal(admin.address);
      await governanceContract.addVoter(voter1.address);
      await expect(governanceContract.addVoter(voter1.address)).be.reverted;
    });
    it('query approval uri should return correct uri', async function () {
      const { getGovernanceContract, admin, tokenOwner1, ERC5727ExampleContract } =
        await loadFixture(deployTokenFixture);
      const governanceContract = getGovernanceContract(admin);
      await governanceContract.requestApproval(tokenOwner1.address, 1, 1, 1, 0, admin.address, []);
      const contractAddress: string = ERC5727ExampleContract.address.toLowerCase();
      expect(await governanceContract.approvalURI(0)).equal(
        `https://api.soularis.io/contracts/${contractAddress}/approvals/0`,
      );
    });
    it('should revert on query approval uri if approval does not exist', async function () {
      const { getGovernanceContract, admin } = await loadFixture(deployTokenFixture);
      const governanceContract = getGovernanceContract(admin);
      await expect(governanceContract.approvalURI(0)).be.reverted;
    });
    it('only voter can issue approval', async function () {
      const { getGovernanceContract, admin, tokenOwner1, voter1, operator1 } = await loadFixture(
        deployTokenFixture,
      );
      const governanceContract = getGovernanceContract(admin);
      const governanceContractVoter = getGovernanceContract(voter1);
      const governanceContractOperator = getGovernanceContract(operator1);
      await governanceContract.addVoter(voter1.address);
      await governanceContract.requestApproval(tokenOwner1.address, 1, 1, 1, 0, admin.address, []);
      await governanceContractVoter.requestApproval(
        tokenOwner1.address,
        1,
        1,
        1,
        0,
        admin.address,
        [],
      );
      await expect(
        governanceContractOperator.requestApproval(
          tokenOwner1.address,
          1,
          1,
          1,
          0,
          admin.address,
          [],
        ),
      ).be.reverted;
    });
    it('should revert on issue approval if recipient is invaild', async function () {
      const { getGovernanceContract, admin, voter1 } = await loadFixture(deployTokenFixture);
      const governanceContract = getGovernanceContract(admin);
      await governanceContract.addVoter(voter1.address);
      await expect(
        governanceContract.requestApproval(
          ethers.constants.AddressZero,
          1,
          1,
          1,
          0,
          admin.address,
          [],
        ),
      ).be.reverted;
    });
    it('should revert on issue approval if slot or token id is invaild', async function () {
      const { getGovernanceContract, tokenOwner1, admin, voter1 } = await loadFixture(
        deployTokenFixture,
      );
      const governanceContract = getGovernanceContract(admin);
      await governanceContract.addVoter(voter1.address);
      await expect(
        governanceContract.requestApproval(tokenOwner1.address, 0, 1, 1, 0, admin.address, []),
      ).be.reverted;
      await expect(
        governanceContract.requestApproval(tokenOwner1.address, 1, 1, 0, 0, admin.address, []),
      ).be.reverted;
      await expect(
        governanceContract.requestApproval(tokenOwner1.address, 0, 1, 0, 0, admin.address, []),
      ).be.reverted;
    });
    it('should revert on remove approval if approval is not pending', async function () {
      const { getGovernanceContract, tokenOwner1, admin, voter1, voter2 } = await loadFixture(
        deployTokenFixture,
      );
      const governanceContract = getGovernanceContract(admin);
      const governanceContractVoter1 = getGovernanceContract(voter1);
      await governanceContract.addVoter(voter1.address);
      await governanceContract.addVoter(voter2.address);
      await governanceContract.requestApproval(tokenOwner1.address, 1, 1, 1, 0, admin.address, []);
      await governanceContract.voteApproval(0, true, []);
      await governanceContractVoter1.voteApproval(0, true, []);
      await expect(governanceContract.removeApprovalRequest(0)).be.reverted;
    });
    it('issue approval should emit event correctly', async function () {
      const { getGovernanceContract, tokenOwner1, admin, voter1 } = await loadFixture(
        deployTokenFixture,
      );
      const governanceContract = getGovernanceContract(admin);
      await governanceContract.addVoter(voter1.address);
      await expect(
        governanceContract.requestApproval(tokenOwner1.address, 1, 1, 1, 0, admin.address, []),
      )
        .to.emit(governanceContract, 'ApprovalUpdate')
        .withArgs(anyValue, admin.address, 0);
    });
    it('query approval should return correct approval', async function () {
      const { getGovernanceContract, tokenOwner1, admin, voter1 } = await loadFixture(
        deployTokenFixture,
      );
      const governanceContract = getGovernanceContract(admin);
      await governanceContract.addVoter(voter1.address);
      await governanceContract.requestApproval(tokenOwner1.address, 1, 1, 1, 0, admin.address, []);
      await governanceContract.getApproval(0);
    });
    it('should revert on query approval if approval does not exist', async function () {
      const { getGovernanceContract, admin } = await loadFixture(deployTokenFixture);
      const governanceContract = getGovernanceContract(admin);
      await expect(governanceContract.getApproval(0)).be.reverted;
    });
    it('only voter can vote for approval', async function () {
      const { getGovernanceContract, admin, tokenOwner1, voter1, operator1 } = await loadFixture(
        deployTokenFixture,
      );
      const governanceContract = getGovernanceContract(admin);
      const governanceContractVoter = getGovernanceContract(voter1);
      const governanceContractOperator = getGovernanceContract(operator1);
      await governanceContract.requestApproval(tokenOwner1.address, 1, 1, 1, 0, admin.address, []);
      await governanceContract.addVoter(voter1.address);
      await governanceContractVoter.voteApproval(0, true, []);
      await governanceContract.voteApproval(0, true, []);
      await expect(governanceContractOperator.voteApproval(0, true, [])).be.reverted;
    });
    it('only creator can remove approval', async function () {
      const { getGovernanceContract, admin, tokenOwner1, voter1, operator1 } = await loadFixture(
        deployTokenFixture,
      );
      const governanceContract = getGovernanceContract(admin);
      const governanceContractVoter = getGovernanceContract(voter1);
      const governanceContractOperator = getGovernanceContract(operator1);
      await governanceContract.requestApproval(tokenOwner1.address, 1, 1, 1, 0, admin.address, []);
      await governanceContract.addVoter(voter1.address);
      await expect(governanceContractVoter.removeApprovalRequest(0)).be.reverted;
      await expect(governanceContractOperator.removeApprovalRequest(0)).be.reverted;
      await governanceContract.removeApprovalRequest(0);
    });
    it('should revert on remove approval if approval id is invaild', async function () {
      const { getGovernanceContract, admin } = await loadFixture(deployTokenFixture);
      const governanceContract = getGovernanceContract(admin);
      await expect(governanceContract.removeApprovalRequest(0)).be.reverted;
    });
    it('remove approval should emit event correctly', async function () {
      const { getGovernanceContract, tokenOwner1, admin } = await loadFixture(deployTokenFixture);
      const governanceContract = getGovernanceContract(admin);
      await governanceContract.requestApproval(tokenOwner1.address, 1, 1, 1, 0, admin.address, []);
      await expect(governanceContract.removeApprovalRequest(0))
        .to.emit(governanceContract, 'ApprovalUpdate')
        .withArgs(0, ethers.constants.AddressZero, 3);
    });
    it('vote approval should issue token correctly if approval is approved', async function () {
      const { getGovernanceContract, admin, tokenOwner1, getCoreContract, voter1, voter2 } =
        await loadFixture(deployTokenFixture);
      const governanceContract = getGovernanceContract(admin);
      const governanceContractVoter1 = getGovernanceContract(voter1);
      const coreContract = getCoreContract(admin);
      await governanceContract.requestApproval(tokenOwner1.address, 1, 1, 1, 0, admin.address, []);
      await governanceContract.addVoter(voter1.address);
      await governanceContract.addVoter(voter2.address);
      await governanceContractVoter1.voteApproval(0, true, []);
      await expect(governanceContract.voteApproval(0, true, []))
        .to.emit(governanceContract, 'ApprovalUpdate')
        .withArgs(0, admin.address, 1);
      expect(await coreContract['balanceOf(address)'](tokenOwner1.address)).to.equal(1);
      expect(await coreContract['balanceOf(uint256)'](1)).to.equal(1);
    });
    it('vote approval should reject approval if approval is rejected', async function () {
      const { getGovernanceContract, admin, tokenOwner1, voter1, voter2 } = await loadFixture(
        deployTokenFixture,
      );
      const governanceContract = getGovernanceContract(admin);
      const governanceContractVoter1 = getGovernanceContract(voter1);
      await governanceContract.requestApproval(tokenOwner1.address, 1, 1, 1, 0, admin.address, []);
      await governanceContract.addVoter(voter1.address);
      await governanceContract.addVoter(voter2.address);
      await governanceContractVoter1.voteApproval(0, false, []);
      await expect(governanceContract.voteApproval(0, false, []))
        .to.emit(governanceContract, 'ApprovalUpdate')
        .withArgs(0, admin.address, 2);
    });
  });
  describe('ERC5727Example', function () {
    it('supports interface', async function () {
      const { ERC5727ExampleContract } = await loadFixture(deployTokenFixture);
      // recovery
      expect(await ERC5727ExampleContract.supportsInterface('0x379f4e66')).equal(true);
      // claimable
      expect(await ERC5727ExampleContract.supportsInterface('0xf84dc77f')).equal(true);
      // enumerable
      expect(await ERC5727ExampleContract.supportsInterface('0x217d8ec4')).equal(true);
      // delegate
      expect(await ERC5727ExampleContract.supportsInterface('0x2e9d93de')).equal(true);
      // governance
      expect(await ERC5727ExampleContract.supportsInterface('0xa01c94b5')).equal(true);
      // expirable
      expect(await ERC5727ExampleContract.supportsInterface('0x806f015a')).equal(true);
      // ERC3225
      expect(await ERC5727ExampleContract.supportsInterface('0xd5358140')).equal(true);
      // ERC165
      expect(await ERC5727ExampleContract.supportsInterface('0x01ffc9a7')).equal(true);
      // ERC5727
      expect(await ERC5727ExampleContract.supportsInterface('0x7125bdf9')).equal(true);
      // ERC3225
      expect(await ERC5727ExampleContract.supportsInterface('0xd5358140')).equal(true);
      // Metadata
      expect(await ERC5727ExampleContract.supportsInterface('0x00000000')).equal(true);
    });
    it('should return false on query invaild interface', async function () {
      const { ERC5727ExampleContract } = await loadFixture(deployTokenFixture);
      expect(await ERC5727ExampleContract.supportsInterface('0xd0d0d9d9')).equal(false);
    });
  });
  describe('ERC5727Recovery', function () {
    it('can recover tokens if signature is valid', async function () {
      const {
        getCoreContract,
        getRecoveryContract,
        admin,
        tokenOwner1,
        operator1,
        ERC5727ExampleContract,
      } = await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      const recoveryContract = getRecoveryContract(operator1);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        1,
        admin.address,
        [],
      );
      const verifyingContract = ERC5727ExampleContract.address.toLocaleLowerCase();
      const chainId = (await ethers.provider.getNetwork()).chainId;
      const domain = {
        name: 'Soularis',
        version: '1',
        chainId,
        verifyingContract,
      };
      const types = {
        Recovery: [
          { name: 'from', type: 'address' },
          { name: 'recipient', type: 'address' },
        ],
      };
      const signature = await tokenOwner1._signTypedData(domain, types, {
        from: tokenOwner1.address,
        recipient: operator1.address,
      });
      await recoveryContract.recover(tokenOwner1.address, signature);
    });
    it('can recover tokens if signature is valid', async function () {
      const {
        getCoreContract,
        getRecoveryContract,
        admin,
        tokenOwner1,
        operator1,
        ERC5727ExampleContract,
      } = await loadFixture(deployTokenFixture);
      const coreContract = getCoreContract(admin);
      const recoveryContract = getRecoveryContract(operator1);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        1,
        1,
        1,
        admin.address,
        [],
      );
      const verifyingContract = ERC5727ExampleContract.address.toLocaleLowerCase();
      const chainId = (await ethers.provider.getNetwork()).chainId;
      const domain = {
        name: 'Soularis',
        version: '1',
        chainId,
        verifyingContract,
      };
      const types = {
        Recovery: [
          { name: 'from', type: 'address' },
          { name: 'recipient', type: 'address' },
        ],
      };
      const signature = await tokenOwner1._signTypedData(domain, types, {
        from: tokenOwner1.address,
        recipient: operator1.address,
      });
      await recoveryContract.recover(tokenOwner1.address, signature);
      expect(await coreContract['balanceOf(address)'](operator1.address)).equal(1);
      expect(await coreContract['balanceOf(address)'](tokenOwner1.address)).equal(0);
    });
  });
});

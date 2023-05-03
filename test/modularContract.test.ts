import { expect } from 'chai';
import { ethers } from 'hardhat';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { type SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import {
  type DiamondInit__factory,
  type Diamond,
  type ERC5727UpgradeableDS,
  type ERC5727ClaimableUpgradeableDS,
  ERC5727UpgradeableDS__factory,
  ERC5727ClaimableUpgradeableDS__factory,
} from '../typechain';
import { FacetCutAction, getSelectors, remove } from './utils';
import { MerkleTree } from 'merkletreejs';
interface Fixture {
  getCoreContract: (signer: SignerWithAddress) => ERC5727UpgradeableDS;
  getClaimableContract: (signer: SignerWithAddress) => ERC5727ClaimableUpgradeableDS;
  diamond: Diamond;
  admin: SignerWithAddress;
  tokenOwner1: SignerWithAddress;
  tokenOwner2: SignerWithAddress;
  voter1: SignerWithAddress;
  voter2: SignerWithAddress;
  operator1: SignerWithAddress;
  operator2: SignerWithAddress;
}

interface FacetCuts {
  facetAddress: string;
  action: number;
  functionSelectors: string[];
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

describe('ERC5727Modularized', function () {
  async function deployDiamondFixture(): Promise<Fixture> {
    const [admin, tokenOwner1, tokenOwner2, voter1, voter2, operator1, operator2] =
      await ethers.getSigners();
    const diamondInitFactory: DiamondInit__factory = await ethers.getContractFactory('DiamondInit');
    const diamondInit = await diamondInitFactory.deploy();
    console.log(diamondInit.address);
    const FacetNames = [
      'DiamondCutFacet',
      'DiamondLoupeFacet',
      'ERC5727UpgradeableDS',
      'ERC5727ClaimableUpgradeableDS',
    ];
    // The `facetCuts` variable is the FacetCut[] that contains the functions to add during diamond deployment
    const facetCuts: FacetCuts[] = [];
    for (const FacetName of FacetNames) {
      const Facet = await ethers.getContractFactory(FacetName);
      const facet = await Facet.deploy();
      await facet.deployed();
      console.log(`${FacetName} deployed: ${facet.address}`);
      if (facetCuts.length === 0) {
        facetCuts.push({
          facetAddress: facet.address,
          action: FacetCutAction.Add,
          functionSelectors: getSelectors(facet),
        });
      } else {
        facetCuts.push({
          facetAddress: facet.address,
          action: FacetCutAction.Add,
          functionSelectors: remove(
            getSelectors(facet),
            facetCuts[facetCuts.length - 1].functionSelectors,
          ),
        });
      }
    }
    // Creating a function call
    // This call gets executed during deployment and can also be executed in upgrades
    // It is executed with delegatecall on the DiamondInit address.
    const functionCall = diamondInit.interface.encodeFunctionData('init');

    // Setting arguments that will be used in the diamond constructor
    const diamondArgs = {
      owner: admin.address,
      init: diamondInit.address,
      initCalldata: functionCall,
    };
    // deploy Diamond
    const Diamond = await ethers.getContractFactory('Diamond');
    console.log(Diamond);
    const diamond = await Diamond.deploy(facetCuts, diamondArgs);
    await diamond.deployed();
    console.log('Diamond deployed: ', diamond.address);
    const getCoreContract = (signer: SignerWithAddress): ERC5727UpgradeableDS =>
      ERC5727UpgradeableDS__factory.connect(diamond.address, signer);
    const getClaimableContract = (signer: SignerWithAddress): ERC5727ClaimableUpgradeableDS =>
      ERC5727ClaimableUpgradeableDS__factory.connect(diamond.address, signer);
    const coreContract = getCoreContract(admin);
    await coreContract.ERC5727_init('soulhub', 'SOUL', admin.address, '1');
    return {
      getCoreContract,
      getClaimableContract,
      diamond,
      admin,
      tokenOwner1,
      tokenOwner2,
      voter1,
      voter2,
      operator1,
      operator2,
    };
  }
  describe('Core', function () {
    it('Should set right owner', async function () {
      const { getCoreContract, admin } = await loadFixture(deployDiamondFixture);
      const coreContract = getCoreContract(admin);
      expect(await coreContract.owner()).to.equal(admin.address);
    });
    it('only admin can issue', async function () {
      const { getCoreContract, admin, tokenOwner1, tokenOwner2 } = await loadFixture(
        deployDiamondFixture,
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
        deployDiamondFixture,
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
      const { getCoreContract, admin, tokenOwner1 } = await loadFixture(deployDiamondFixture);
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
      const { getCoreContract, admin, tokenOwner1 } = await loadFixture(deployDiamondFixture);
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
      const { getCoreContract, admin, tokenOwner1, tokenOwner2 } = await loadFixture(
        deployDiamondFixture,
      );
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
      ).be.revertedWithCustomError(coreContract, 'Soulbound');

      expect(await coreContract.ownerOf(1)).equal(tokenOwner1.address);
    });

    it('should revert on transfer value', async function () {
      const { getCoreContract, admin, tokenOwner1, tokenOwner2 } = await loadFixture(
        deployDiamondFixture,
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
      expect(await coreContract.ownerOf(1)).equal(tokenOwner1.address);
      expect(await coreContract['balanceOf(uint256)'](1)).equal(100);
      await coreContractOwner1['approve(uint256,address,uint256)'](1, tokenOwner2.address, 100);
      await expect(
        coreContractOwner2['transferFrom(uint256,address,uint256)'](1, tokenOwner2.address, 50),
      ).revertedWithCustomError(coreContract, 'Soulbound');
      await expect(
        coreContractOwner1['transferFrom(uint256,address,uint256)'](1, tokenOwner2.address, 50),
      ).revertedWithCustomError(coreContract, 'Soulbound');
      expect(await coreContract['balanceOf(uint256)'](1)).equal(100);
      expect(await coreContract.ownerOf(1)).equal(tokenOwner1.address);
    });

    it('should revert on approve if unauthorized', async function () {
      const { getCoreContract, admin, tokenOwner1, tokenOwner2, operator1 } = await loadFixture(
        deployDiamondFixture,
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
      const { getCoreContract, admin, tokenOwner1 } = await loadFixture(deployDiamondFixture);
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
      const { getCoreContract, admin, tokenOwner1 } = await loadFixture(deployDiamondFixture);
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        10,
        1,
        0,
        admin.address,
        [],
      );
      expect(await coreContract.owner()).equal(admin.address);
      expect(await coreContract.hasBurnRole(tokenOwner1.address, 1)).equal(false);
      const coreContractOwner1 = getCoreContract(tokenOwner1);
      await expect(coreContractOwner1['revoke(uint256,bytes)'](10, [])).be.reverted;
      await coreContract['revoke(uint256,bytes)'](10, []);
    });

    it('should revert on revoke if token does not exist', async function () {
      const { getCoreContract, admin } = await loadFixture(deployDiamondFixture);
      const coreContract = getCoreContract(admin);
      await expect(coreContract['revoke(uint256,bytes)'](100, [])).be.reverted;
      await expect(coreContract['revoke(uint256,uint256,bytes)'](100, 0, [])).be.reverted;
    });

    it('should decrease account balance if token is revoked', async function () {
      const { getCoreContract, admin, tokenOwner1 } = await loadFixture(deployDiamondFixture);
      const coreContract = getCoreContract(admin);
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        10,
        1,
        0,
        admin.address,
        [],
      );
      await coreContract['issue(address,uint256,uint256,uint8,address,bytes)'](
        tokenOwner1.address,
        11,
        1,
        0,
        admin.address,
        [],
      );
      expect(await coreContract['balanceOf(address)'](tokenOwner1.address)).equal(2);
      expect(await coreContract.slotOf(10)).be.equal(1);
      await coreContract['revoke(uint256,bytes)'](10, []);
      expect(await coreContract.slotOf(10)).be.equal(0);
      expect(await coreContract['balanceOf(address)'](tokenOwner1.address)).equal(1);
    });

    it('should decrease token balance if amount is revoked', async function () {
      const { getCoreContract, admin, tokenOwner1 } = await loadFixture(deployDiamondFixture);
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
      const { getCoreContract, admin, tokenOwner1 } = await loadFixture(deployDiamondFixture);
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
      const coreContractOwner1 = getCoreContract(tokenOwner1);
      expect(await coreContract['balanceOf(uint256)'](10)).equal(100);
      await expect(coreContractOwner1['revoke(uint256,uint256,bytes)'](10, 50, [])).be.reverted;
      await coreContract['revoke(uint256,uint256,bytes)'](10, 50, []);
      expect(await coreContract['balanceOf(uint256)'](10)).equal(50);
    });
    it('query verifier of token', async function () {
      const { getCoreContract, admin, tokenOwner1 } = await loadFixture(deployDiamondFixture);
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
      const { getCoreContract, admin, tokenOwner1 } = await loadFixture(deployDiamondFixture);
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
      const { getCoreContract, admin, tokenOwner1 } = await loadFixture(deployDiamondFixture);
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
      const { getCoreContract, admin, tokenOwner1 } = await loadFixture(deployDiamondFixture);
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
  describe('Claimable', function () {
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
      const { getClaimableContract, admin, tokenOwner1, tokenOwner2, operator1 } =
        await loadFixture(deployDiamondFixture);
      const claimableContract = getClaimableContract(admin);
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
      await claimableContract.connect(admin).setClaimEvent(admin.address, 1, root);
      await expect(claimableContract.connect(operator1).setClaimEvent(operator1.address, 1, root))
        .be.reverted;
    });

    it('should revert if claim event is already set for a slot', async function () {
      const { getClaimableContract, admin, tokenOwner1, tokenOwner2, operator1 } =
        await loadFixture(deployDiamondFixture);
      const claimableContract = getClaimableContract(admin);
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
      await claimableContract.connect(admin).setClaimEvent(ethers.constants.AddressZero, 1, root);
      await expect(claimableContract.connect(admin).setClaimEvent(operator1.address, 1, root)).be
        .reverted;
    });

    it('should claim if account is eligible', async function () {
      const { getClaimableContract, admin, tokenOwner1, tokenOwner2 } = await loadFixture(
        deployDiamondFixture,
      );
      const claimableContract = getClaimableContract(admin);
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
      await claimableContract.connect(admin).setClaimEvent(admin.address, 1, root);
      await claimableContract
        .connect(tokenOwner1)
        .claim(tokenOwner1.address, 1, 1, 1, 0, admin.address, [], proofs[tokenOwner1.address]);
      await claimableContract
        .connect(tokenOwner2)
        .claim(tokenOwner2.address, 2, 1, 1, 0, admin.address, [], proofs[tokenOwner2.address]);
    });

    it('should increase balances after claim', async function () {
      const { getClaimableContract, getCoreContract, admin, tokenOwner1, tokenOwner2 } =
        await loadFixture(deployDiamondFixture);
      const claimableContract = getClaimableContract(admin);
      const coreContract = getCoreContract(admin);
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
      await claimableContract.connect(admin).setClaimEvent(admin.address, 1, root);
      await claimableContract
        .connect(tokenOwner1)
        .claim(tokenOwner1.address, 1, 1, 1, 0, admin.address, [], proofs[tokenOwner1.address]);
      await claimableContract
        .connect(tokenOwner2)
        .claim(tokenOwner2.address, 2, 1, 1, 0, admin.address, [], proofs[tokenOwner2.address]);
      expect(await coreContract['balanceOf(uint256)'](1)).equal(1);
      expect(await coreContract['balanceOf(address)'](tokenOwner1.address)).equal(1);
      expect(await coreContract['balanceOf(uint256)'](2)).equal(1);
      expect(await coreContract['balanceOf(address)'](tokenOwner2.address)).equal(1);
    });

    it('revert if claimer already claimed', async function () {
      const { getClaimableContract, getCoreContract, admin, tokenOwner1, tokenOwner2 } =
        await loadFixture(deployDiamondFixture);
      const claimableContract = getClaimableContract(admin);
      const coreContract = getCoreContract(admin);
      const claimableContractOwner1 = getClaimableContract(tokenOwner1);
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
      await claimableContract.setClaimEvent(admin.address, 1, root);
      await claimableContract
        .connect(tokenOwner1)
        .claim(tokenOwner1.address, 1, 1, 1, 0, admin.address, [], proofs[tokenOwner1.address]);
      expect(await coreContract['balanceOf(uint256)'](1)).equal(1);
      expect(await coreContract['balanceOf(address)'](tokenOwner1.address)).equal(1);
      await expect(
        claimableContractOwner1.claim(
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
      const { getClaimableContract, admin, tokenOwner1, tokenOwner2 } = await loadFixture(
        deployDiamondFixture,
      );
      const claimableContract = getClaimableContract(admin);
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
      await claimableContract.setClaimEvent(admin.address, 1, root);
      expect(await claimableContract.isClaimed(tokenOwner1.address, 1)).equal(false);
      await claimableContract
        .connect(tokenOwner1)
        .claim(tokenOwner1.address, 1, 1, 1, 0, admin.address, [], proofs[tokenOwner1.address]);
      expect(await claimableContract.isClaimed(tokenOwner1.address, 1)).equal(true);
    });
    it('revert if claimer is not eligible', async function () {
      const { getClaimableContract, admin, tokenOwner1, tokenOwner2, operator1 } =
        await loadFixture(deployDiamondFixture);
      const claimableContract = getClaimableContract(admin);
      const claimableContractOperator1 = getClaimableContract(operator1);
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
      await claimableContract.setClaimEvent(admin.address, 1, root);
      await expect(
        claimableContractOperator1.claim(
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
});

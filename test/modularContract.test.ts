import { expect } from 'chai';
import { ethers } from 'hardhat';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { type SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { type DiamondInit__factory, type Diamond } from '../typechain';
import { FacetCutAction, getSelectors } from './utils';

interface Fixture {
  diamond: Diamond;
  admin: SignerWithAddress;
  tokenOwner1: SignerWithAddress;
  tokenOwner2: SignerWithAddress;
  voter1: SignerWithAddress;
  voter2: SignerWithAddress;
  operator1: SignerWithAddress;
  operator2: SignerWithAddress;
}

describe('ERC5727Modularized', function () {
  async function deployDiamondFixture(): Promise<Fixture> {
    const [admin, tokenOwner1, tokenOwner2, voter1, voter2, operator1, operator2] =
      await ethers.getSigners();
    const diamondInitFactory: DiamondInit__factory = await ethers.getContractFactory('DiamondInit');
    const diamondInit = await diamondInitFactory.deploy();
    console.log(diamondInit.address);
    const FacetNames = ['DiamondCutFacet', 'DiamondLoupeFacet', 'OwnershipFacet'];
    // The `facetCuts` variable is the FacetCut[] that contains the functions to add during diamond deployment
    const facetCuts = [];
    for (const FacetName of FacetNames) {
      const Facet = await ethers.getContractFactory(FacetName);
      const facet = await Facet.deploy();
      await facet.deployed();
      console.log(`${FacetName} deployed: ${facet.address}`);
      facetCuts.push({
        facetAddress: facet.address,
        action: FacetCutAction.Add,
        functionSelectors: getSelectors(facet),
      });
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
    const diamond = await Diamond.deploy(facetCuts, diamondArgs);
    return {
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
  it('Should deploy diamond', async function () {
    const { diamond } = await loadFixture(deployDiamondFixture);
    console.log(diamond.address);
    expect(1).to.equal(1);
  });
});

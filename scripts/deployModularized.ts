import { ethers } from 'hardhat';
import {
  type DiamondMultiInit__factory,
  type TransparentUpgradeableProxy,
  SoulHubUpgradeable__factory,
  type SoulHubUpgradeable,
} from '../typechain';
import { FacetCutAction, getSelectors, remove } from '../test/utils';

interface FacetCuts {
  facetAddress: string;
  action: number;
  functionSelectors: string[];
}

async function deployTransparentProxy(
  impl: string,
  admin: string,
  data: string,
): Promise<TransparentUpgradeableProxy> {
  const transparentProxyContract = await ethers.getContractFactory('TransparentUpgradeableProxy');
  const transparentProxy = await transparentProxyContract.deploy(impl, admin, data);
  await transparentProxy.deployed();
  console.log('TransparentUpgradeableProxy contract deployed to:', transparentProxy.address);
  return transparentProxy;
}

async function deploySoulHub(): Promise<SoulHubUpgradeable> {
  const soulHubContract = await ethers.getContractFactory('SoulHubUpgradeable');
  const soulHub = await soulHubContract.deploy();
  await soulHub.deployed();
  console.log('SoulHub contract deployed to:', soulHub.address);
  return soulHub;
}

async function deployFacets(): Promise<FacetCuts[]> {
  const FacetNames = [
    'DiamondCutFacet',
    'DiamondLoupeFacet',
    'ERC5727UpgradeableDS',
    'ERC5727ClaimableUpgradeableDS',
    'ERC5727GovernanceUpgradeableDS',
    'ERC5727RecoveryUpgradeableDS',
    'ERC5727ExpirableUpgradeableDS',
    'ERC5727EnumerableUpgradeableDS',
    'ERC5727DelegateUpgradeableDS',
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
  return facetCuts;
}
async function main(): Promise<void> {
  const [admin] = await ethers.getSigners();
  console.log('Deploying contracts with the account:', admin.address);
  console.log('Network:', (await ethers.provider.getNetwork()).name);
  const facetCuts = await deployFacets();
  const diamondMultiInitFactory: DiamondMultiInit__factory = await ethers.getContractFactory(
    'DiamondMultiInit',
  );
  const diamondMultiInit = await diamondMultiInitFactory.deploy();
  console.log('diamondInit deployed: ', diamondMultiInit.address);
  // const IERC5727 = ERC5727UpgradeableDS__factory.createInterface();
  // const IERC5727Governance = ERC5727GovernanceUpgradeableDS__factory.createInterface();
  // const ERC5727InitCall = IERC5727.encodeFunctionData('init', [
  //   'soulhub',
  //   'SOUL',
  //   admin.address,
  //   '1',
  // ]);
  // const ERC5727GovernanceInitCall = IERC5727Governance.encodeFunctionData('init', [admin.address]);
  // Creating a function call
  // This call gets executed during deployment and can also be executed in upgrades
  // It is executed with delegatecall on the DiamondInit address.
  // const abi = [
  //   'function multiInit(address[] calldata _addresses, bytes[] calldata _calldata) external',
  // ];
  // const diamondMultiInitInterface = new ethers.utils.Interface(abi);
  // const functionCall = diamondMultiInitInterface.encodeFunctionData('multiInit', [
  //   [facetCuts[2].facetAddress, facetCuts[4].facetAddress],
  //   [ERC5727InitCall, ERC5727GovernanceInitCall],
  // ]);
  const facetAddress = facetCuts.map((facet) => facet.facetAddress);
  const action = facetCuts.map((facet) => facet.action);
  const functionSelectors = facetCuts.map((facet) => facet.functionSelectors);
  const initData = SoulHubUpgradeable__factory.createInterface().encodeFunctionData(
    '__SoulHub_init',
    [facetCuts.length, facetAddress, action, functionSelectors, diamondMultiInit.address],
  );
  const soulHubImpl = await deploySoulHub();
  const soulHubProxy = await deployTransparentProxy(soulHubImpl.address, admin.address, initData);

  console.log('SoulHubProxy deployed: ', soulHubProxy.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

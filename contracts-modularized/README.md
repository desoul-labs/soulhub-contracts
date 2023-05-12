## Contract modularized

### Deploy

#### init contract

DiamondInit contract reusable accross upgrades, and can be used for multiple diamonds.

```js
const diamondMultiInitFactory: DiamondMultiInit__factory = await ethers.getContractFactory(
  'DiamondMultiInit',
);
const diamondMultiInit = await diamondMultiInitFactory.deploy();
console.log('diamondInit deployed: ', diamondMultiInit.address);
```

#### facets

```js
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
for (const FacetName of FacetNames) {
  const Facet = await ethers.getContractFactory(FacetName);
  const facet = await Facet.deploy();
  await facet.deployed();
  console.log(`${FacetName} deployed: ${facet.address}`);
}
```

#### diamond

Deploying Diamond requires two parameters: diamondArgs and facetCuts.

diamondArgs

```js
// Setting arguments that will be used in the diamond constructor
const diamondArgs = {
  owner: admin.address,
  init: diamondMultiInit.address,
  initCalldata: functionCall, // init function call
};
```

facetCuts

```js
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
      ), // Removing existing function signatures.
    });
  }
}
```

```js
const Diamond = await ethers.getContractFactory('Diamond');
const diamond = await Diamond.deploy(facetCuts, diamondArgs);
```

### Add or remove facet

```js
const diamondCutFacet = DiamondCutFacet__factory.connect(diamond.address, admin);
await diamondCutFacet.diamondCut(facetCuts, diamondArgs);
```

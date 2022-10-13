import { loadFixture } from '@nomicfoundation/hardhat-network-helpers'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { ethers } from 'hardhat'
import { expect } from 'chai'
import { ERC5727RegistrantExample, ERC5727RegistryExample } from '../typechain'

interface Fixture {
  registry: ERC5727RegistryExample
  registrant: ERC5727RegistrantExample
  owner: SignerWithAddress
  newOwner: SignerWithAddress
}

describe('ERC5727 Registration', function () {
  async function deployRegistryFixture(): Promise<Fixture> {
    const ERC5727RegistryFactory = await ethers.getContractFactory('ERC5727RegistryExample')
    const ERC5727RegistrantFactory = await ethers.getContractFactory('ERC5727RegistrantExample')
    const [owner, newOwner] = await ethers.getSigners()

    const registry = await ERC5727RegistryFactory.deploy(
      'Registry',
      'REG',
      '/soularis/test',
      'soularis.eth',
    )
    const registrant = await ERC5727RegistrantFactory.deploy('Registrant', 'REG')

    await registry.deployed()
    await registrant.deployed()

    return { registry, registrant, owner, newOwner }
  }

  it('Should register ERC5727 collection to the registry', async function () {
    const { registry, registrant, owner } = await loadFixture(deployRegistryFixture)

    await registrant.register(registry.address)

    expect(await registry.isRegistered(registrant.address)).to.equal(true)
    expect(await registry.addressOf(0)).to.equal(registrant.address)
    expect(await registry.ownerOf(0)).to.equal(owner.address)
    expect(await registry.tokenURI(0)).to.equal(await registrant.contractURI())
  })

  it('Should deregister ERC5727 collection from the registry', async function () {
    const { registry, registrant } = await loadFixture(deployRegistryFixture)

    await registrant.register(registry.address)

    await registrant.deregister(registry.address)

    expect(await registry.isRegistered(registrant.address)).to.equal(false)
    await expect(registry.addressOf(0)).be.reverted
    await expect(registry.ownerOf(0)).be.reverted
    await expect(registry.tokenURI(0)).be.reverted
  })

  it('Should transfer ownership', async function () {
    const { registry, registrant, owner, newOwner } = await loadFixture(deployRegistryFixture)

    await registrant.register(registry.address)

    expect(await registrant.owner()).to.equal(owner.address)
    expect(await registry.ownerOf(0)).to.equal(owner.address)

    await registrant.transferOwnership(newOwner.address)

    expect(await registrant.owner()).to.equal(newOwner.address)
    expect(await registry.addressOf(1)).to.equal(registrant.address)
    expect(await registry.ownerOf(1)).to.equal(newOwner.address)
  })
})

import { expect } from 'chai'
import { ethers } from 'hardhat'

describe('Souldrop', function () {
  it('mint', async function () {
    const erc5727Factory = await ethers.getContractFactory('ERC5727ExampleUpgradeable')
    const erc5727 = await erc5727Factory.deploy()
    await erc5727.deployed()
    const [owner] = await ethers.getSigners()
    await erc5727.__ERC5727Example_init(
      owner.address,
      'ERC5727Example',
      'ERC5727',
      [owner.address],
      '',
    )
    await erc5727.mint(owner.address, 210, 1, ethers.BigNumber.from(Number.MAX_SAFE_INTEGER - 1))
    expect(await erc5727.balanceOf(owner.address)).to.equal(1)
    expect(await erc5727.valueOf_(0)).to.equal(210)

    const souldropFactory = await ethers.getContractFactory('Souldrop')
    const souldrop = await souldropFactory.deploy()
    await souldrop.deployed()
    await souldrop.initialize(
      owner.address,
      10,
      'https://api.soularis.io/souldrop',
      erc5727.address,
      1,
    )

    expect(await souldrop.owner()).to.equal(owner.address)
    expect(await souldrop.balanceOf(owner.address)).to.equal(1)
  })
})

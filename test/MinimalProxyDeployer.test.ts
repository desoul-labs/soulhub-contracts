import { loadFixture } from '@nomicfoundation/hardhat-network-helpers'
import { ethers } from 'hardhat'
import { expect } from 'chai'
import { ERC5727ExampleUpgradeable, MinimalProxyDeployer } from '../typechain'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'

interface Fixture {
  erc5727: ERC5727ExampleUpgradeable
  minimalProxyDeployer: MinimalProxyDeployer
  owner: SignerWithAddress
}

describe('Deploy Minimal Proxy', function () {
  async function deployRegistryFixture(): Promise<Fixture> {
    const erc5727Factory = await ethers.getContractFactory('ERC5727ExampleUpgradeable')
    const erc5727 = await erc5727Factory.deploy()
    const minimalProxyDeployerFactory = await ethers.getContractFactory('MinimalProxyDeployer')
    const minimalProxyDeployer = await minimalProxyDeployerFactory.deploy(
      '0x0000000000000000000000000000000000000000',
    )
    const [owner] = await ethers.getSigners()

    await erc5727.deployed()
    await minimalProxyDeployer.deployed()

    return { erc5727, minimalProxyDeployer, owner }
  }

  it('Should deploy minimal proxy for ERC5727', async function () {
    const { erc5727, minimalProxyDeployer, owner } = await loadFixture(deployRegistryFixture)
    const data = erc5727.interface.encodeFunctionData('__ERC5727Example_init', [
      owner.address,
      'ERC5727Example',
      'ERC5727',
      ['0x0000000000000000000000000000000000000000'],
      'https://soularis-demo.s3.ap-northeast-1.amazonaws.com/erc5727/',
    ])

    const salt = ethers.utils.formatBytes32String(Math.random().toString().slice(2, 10))
    const addr = await minimalProxyDeployer.callStatic.deployProxyByImplementation(
      erc5727.address,
      data,
      salt,
    )
    const tx = await minimalProxyDeployer.deployProxyByImplementation(erc5727.address, data, salt)
    const receipt = await tx.wait()
    const proxyAddress: string = receipt.events?.[0].args?.[1]
    expect(proxyAddress).to.equal(addr)

    const proxy = new ethers.Contract(
      addr,
      erc5727.interface,
      ethers.provider.getSigner(0),
    ) as ERC5727ExampleUpgradeable

    expect(await proxy.name()).to.equal('ERC5727Example')
    // eslint-disable-next-line @typescript-eslint/no-unused-expressions
    expect(await erc5727.name()).to.be.empty
  })
})

import { ethers, run } from 'hardhat';
import { type MinimalForwarder } from '../typechain';

async function deployForwarder(): Promise<MinimalForwarder> {
  const forwarderContractFactroy = await ethers.getContractFactory('MinimalForwarder');
  const forwarderContract = await forwarderContractFactroy.deploy();
  await forwarderContract.deployed();
  await verifyContract(forwarderContract.address, []);
  return forwarderContract;
}

async function verifyContract(address: string, constructorArguments: any[]): Promise<void> {
  await new Promise((resolve) => setTimeout(resolve, 10000));
  await run('verify:verify', {
    address,
    constructorArguments,
  }).catch((error) => {
    console.info(error);
  });
}

async function main(): Promise<void> {
  const [deployer] = await ethers.getSigners();
  console.log('Deploying contracts with the account:', deployer.address);
  console.log('Network:', (await ethers.provider.getNetwork()).name);

  const forwarderContract = await deployForwarder();
  console.log('Forwarder deployed to:', forwarderContract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

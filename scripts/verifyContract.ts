import { run } from 'hardhat';

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
  //  await verifyContract('0x9BB350E01a0d7309dB5296b4f886D34de23768eD', [])
  //  await verifyContract('0x7D720274a09D0E825E2088c1B2F7e069054fcD7E', [])
  await verifyContract('0x7D720274a09D0E825E2088c1B2F7e069054fcD7E', []);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

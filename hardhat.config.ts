import '@nomicfoundation/hardhat-toolbox'
import '@nomiclabs/hardhat-solhint'
import '@typechain/hardhat'
import '@nomiclabs/hardhat-ethers'
import { HardhatUserConfig } from 'hardhat/types'
import { networks } from './constants/networks'
import * as tenderly from '@tenderly/hardhat-tenderly'
import 'solidity-coverage'
import '@primitivefi/hardhat-dodoc'

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.17',
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  // eslint-disable-next-line @typescript-eslint/strict-boolean-expressions
  ...(process.env.PRIVATE_KEY ? { networks } : { defaultNetwork: 'hardhat' }),
  typechain: {
    outDir: './typechain',
    target: 'ethers-v5',
  },
  tenderly: {
    project: 'soularis-protocol',
    username: 'phaneroz-labs',
    privateVerification: true,
    // deploymentsDir: "deployments"
  },
  gasReporter: {
    enabled: true,
    currency: 'USD',
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY ?? '',
      goerli: process.env.ETHERSCAN_API_KEY ?? '',
      sepolia: process.env.ETHERSCAN_API_KEY ?? '',
      polygon: process.env.POLYGONSCAN_API_KEY ?? '',
      mumbai: process.env.POLYGONSCAN_API_KEY ?? '',
      bsc: process.env.BSCSCAN_API_KEY ?? '',
      chapel: process.env.BSCSCAN_API_KEY ?? '',
      optimism: process.env.OPTIMISTICSCAN_API_KEY ?? '',
      optimismGoerli: process.env.OPTIMISTICSCAN_API_KEY ?? '',
    },
  },
  dodoc: {
    runOnCompile: false,
  },
}

tenderly.setup({ automaticVerifications: false })

export default config

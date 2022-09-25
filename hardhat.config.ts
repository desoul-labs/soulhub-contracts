import '@nomicfoundation/hardhat-toolbox'
import '@nomiclabs/hardhat-solhint'
import { HardhatUserConfig } from 'hardhat/types'
import { networks } from './constants/networks'
import * as tdly from '@tenderly/hardhat-tenderly'

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
  ...(process.env.NODE_ENV === 'development' ? { defaultNetwork: 'hardhat' } : { networks }),
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
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
}

tdly.setup()

export default config

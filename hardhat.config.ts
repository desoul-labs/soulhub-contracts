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

tenderly.setup({ automaticVerifications: false })

export default config

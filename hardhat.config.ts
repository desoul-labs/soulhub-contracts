import '@nomicfoundation/hardhat-toolbox'
import '@nomiclabs/hardhat-solhint'
import { HardhatUserConfig } from 'hardhat/types'
import { networks } from './constants/networks'

const config: HardhatUserConfig = {
  solidity: '0.8.16',
  ...(process.env.ENV === 'development' ? { defaultNetwork: 'hardhat' } : { networks: networks }),
  typechain: {
    outDir: './typechain',
    target: 'ethers-v5',
  },
}

export default config

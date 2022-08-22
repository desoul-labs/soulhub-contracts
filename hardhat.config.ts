import { HardhatUserConfig } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'
import '@nomiclabs/hardhat-solhint'

const config: HardhatUserConfig = {
  solidity: '0.8.16',
  networks: {
    goerli: {
      url: process.env.ALCHEMY_API_URL,
      accounts: [process.env.ADDRESS_PRIVATE_KEY!]
    }
  }
}

export default config

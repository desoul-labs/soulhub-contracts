import { NetworksUserConfig } from 'hardhat/types'

export const networks: NetworksUserConfig = {
  goerli: {
    url: 'https://rpc.ankr.com/eth_goerli',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  sepolia: {
    url: 'https://rpc.sepolia.org',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  mainnet: {
    url: 'https://rpc.ankr.com/eth',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  polygon: {
    url: 'https://rpc.ankr.com/polygon',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  mumbai: {
    url: 'https://rpc.ankr.com/polygon_mumbai',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  bsc: {
    url: 'https://rpc.ankr.com/bsc',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  chapel: {
    url: 'https://rpc.ankr.com/bsc_testnet_chapel',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  fantom: {
    url: 'https://rpc.ankr.com/fantom',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  'fantom-test': {
    url: 'https://rpc.ankr.com/fantom_testnet',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  avalanche: {
    url: 'https://rpc.ankr.com/avalanche',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  fuji: {
    url: 'https://rpc.ankr.com/avalanche_fuji',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  optimism: {
    url: 'https://rpc.ankr.com/optimism',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  optimismGoerli: {
    url: 'https://rpc.ankr.com/optimism_testnet',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  near: {
    url: 'https://rpc.ankr.com/near',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  gnosis: {
    url: 'https://rpc.ankr.com/gnosis',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  arbitrum: {
    url: 'https://rpc.ankr.com/arbitrum',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  harmony: {
    url: 'https://rpc.ankr.com/harmony',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  aurora: {
    url: 'https://mainnet.aurora.dev',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  zkSync: {
    url: 'https://zksync2-testnet.zksync.dev',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  moonriver: {
    url: 'https://moonriver.api.onfinality.io/public',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  moonbeam: {
    url: 'https://rpc.ankr.com/moonbeam',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
  tenderly: {
    url: 'https://rpc.tenderly.co/fork/fdc07e58-3d7e-4a61-b91f-0bf903e50439',
    accounts: [process.env.PRIVATE_KEY ?? ''],
  },
}

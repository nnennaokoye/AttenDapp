import { ethers } from 'ethers';
import { Chain } from 'wagmi';

// Contract deployment address (replace with actual deployment addresses)
export const CONTRACT_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

// Chain configuration
export const availableChains: Chain[] = [
  {
    id: 1,
    name: 'Ethereum',
    network: 'ethereum',
    nativeCurrency: {
      name: 'Ether',
      symbol: 'ETH',
      decimals: 18,
    },
    rpcUrls: {
      default: {
        http: ['https://eth.llamarpc.com'],
      },
      public: {
        http: ['https://eth.llamarpc.com'],
      },
    },
  },
  {
    id: 5,
    name: 'Goerli',
    network: 'goerli',
    nativeCurrency: {
      name: 'Goerli Ether',
      symbol: 'ETH',
      decimals: 18,
    },
    rpcUrls: {
      default: {
        http: ['https://rpc.ankr.com/eth_goerli'],
      },
      public: {
        http: ['https://rpc.ankr.com/eth_goerli'],
      },
    },
    testnet: true,
  },
  {
    id: 11155111,
    name: 'Sepolia',
    network: 'sepolia',
    nativeCurrency: {
      name: 'Sepolia Ether',
      symbol: 'ETH',
      decimals: 18,
    },
    rpcUrls: {
      default: {
        http: ['https://rpc.sepolia.org'],
      },
      public: {
        http: ['https://rpc.sepolia.org'],
      },
    },
    testnet: true,
  },
  {
    id: 80001,
    name: 'Mumbai',
    network: 'mumbai',
    nativeCurrency: {
      name: 'MATIC',
      symbol: 'MATIC',
      decimals: 18,
    },
    rpcUrls: {
      default: {
        http: ['https://rpc-mumbai.maticvigil.com'],
      },
      public: {
        http: ['https://rpc-mumbai.maticvigil.com'],
      },
    },
    testnet: true,
  }
];

// Get provider
export const getProvider = () => {
  if (typeof window !== 'undefined' && window.ethereum) {
    return new ethers.providers.Web3Provider(window.ethereum);
  }
  
  // Fallback to a public provider
  return new ethers.providers.JsonRpcProvider('https://eth.llamarpc.com');
};

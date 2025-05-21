import { BrowserProvider, Contract, JsonRpcSigner } from 'ethers'
import { ORG_FACTORY_PROXY_ADDRESS } from '../contracts/addresses'
import orgFactoryProxyABI from '../contracts/abis/orgFactoryProxy'

export const getProvider = () => {
  if (typeof window.ethereum === 'undefined') {
    throw new Error('MetaMask is not installed!')
  }
  return new BrowserProvider(window.ethereum)
}

export const getSigner = async () => {
  const provider = getProvider()
  return provider.getSigner()
}

export const getOrgFactoryContract = async () => {
  const signer = await getSigner()
  return new Contract(
    ORG_FACTORY_PROXY_ADDRESS,
    orgFactoryProxyABI,
    signer
  )
}

export const shortenAddress = (address: string) => {
  return `${address.slice(0, 6)}...${address.slice(-4)}`
}

export const handleTransactionError = (error: any) => {
  let message = 'Transaction failed'
  if (error.reason) {
    message = error.reason
  } else if (error.data?.message) {
    message = error.data.message
  }
  return message
}
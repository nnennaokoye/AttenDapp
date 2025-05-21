import { format } from 'date-fns'

export function formatDate(timestamp: bigint | number): string {
  // Convert to number if it's bigint
  const numericTimestamp = typeof timestamp === 'bigint' 
    ? Number(timestamp) 
    : timestamp;
  
  // If timestamp is in seconds (Ethereum timestamps), convert to milliseconds
  const date = new Date(numericTimestamp * 1000);
  
  return date.toLocaleDateString(undefined, {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  });
}

export const formatCount = (count: number) => {
  if (count >= 1000) {
    return `${(count / 1000).toFixed(1)}k`
  }
  return count.toString()
}

export const formatRole = (role: string) => {
  return role.charAt(0).toUpperCase() + role.slice(1).toLowerCase()
}

export const parseContractError = (error: any) => {
  if (error.message.includes('user rejected transaction')) {
    return 'Transaction was rejected'
  }
  if (error.message.includes('insufficient funds')) {
    return 'Insufficient funds for transaction'
  }
  return 'Transaction failed'
}

export const formatChainId = (chainId: number) => {
  const chains: Record<number, string> = {
    1: 'Ethereum',
    11155111: 'Sepolia'
  }
  return chains[chainId] || `Chain ${chainId}`
}
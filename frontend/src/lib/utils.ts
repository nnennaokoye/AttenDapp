/**
 * Truncates an Ethereum address to a readable format
 * @param address Full Ethereum address
 * @returns Truncated address (e.g., 0x1234...5678)
 */
export const truncateAddress = (address: string): string => {
  if (!address) return '';
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
};

/**
 * Format timestamp to readable date
 * @param timestamp Unix timestamp
 * @returns Formatted date string
 */
export const formatDate = (timestamp: number): string => {
  return new Date(timestamp * 1000).toLocaleString();
};

/**
 * Format Ethereum amount to readable format with ETH symbol
 * @param amount Amount in wei
 * @returns Formatted ETH amount
 */
export const formatEth = (amount: string): string => {
  const eth = parseFloat(amount) / 1e18;
  return `${eth.toFixed(4)} ETH`;
};

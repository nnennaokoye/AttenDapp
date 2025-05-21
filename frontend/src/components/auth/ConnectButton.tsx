import { useWeb3Modal } from '@web3modal/react'

export function ConnectButton() {
  const { open } = useWeb3Modal()
  
  return (
    <button
      onClick={() => open()}
      className="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors"
    >
      Connect Wallet
    </button>
  )
}
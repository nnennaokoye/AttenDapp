import { useState } from 'react'
import { useAccount } from 'wagmi'
import { ethers } from 'ethers'
import { orgAttendanceLiteABI } from '../../contracts/abis/orgAttendanceLiteABI'

export function SignAttendance({ 
  orgAddress, 
  sessionId,
  isClaimed
}: { 
  orgAddress: string; 
  sessionId: string;
  isClaimed: boolean;
}) {
  const { address } = useAccount()
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  const handleSign = async () => {
    try {
      setIsLoading(true)
      setError('')
      setSuccess('')

      const provider = new ethers.BrowserProvider(window.ethereum)
      const signer = await provider.getSigner()
      const contract = new ethers.Contract(orgAddress, orgAttendanceLiteABI, signer)

      const tx = await contract.claimNFT(sessionId)
      await tx.wait()

      setSuccess('Attendance signed successfully! NFT minted.')
    } catch (err: any) {
      console.error('Error signing attendance:', err)
      setError(err.reason || 'Failed to sign attendance. Are you a student in this organization?')
    } finally {
      setIsLoading(false)
    }
  }

  if (isClaimed) {
    return (
      <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
        Already Claimed
      </span>
    )
  }

  return (
    <div className="flex flex-col items-end">
      <button
        onClick={handleSign}
        disabled={isLoading}
        className="inline-flex items-center px-3 py-1 border border-transparent text-xs font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
      >
        {isLoading ? (
          <>
            <svg className="animate-spin -ml-1 mr-1 h-3 w-3 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
              <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            Signing...
          </>
        ) : 'Sign Attendance'}
      </button>
      {error && <p className="text-red-500 text-xs mt-1 max-w-[120px] text-right">{error}</p>}
      {success && <p className="text-green-500 text-xs mt-1 max-w-[120px] text-right">{success}</p>}
    </div>
  )
}
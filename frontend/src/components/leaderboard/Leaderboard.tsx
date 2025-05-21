import { useEffect, useState } from 'react'
import { ethers } from 'ethers'
import { orgAttendanceLiteABI } from '../../contracts/abis/orgAttendanceLiteABI'

export function Leaderboard({ orgAddress }: { orgAddress: string }) {
  const [leaderboard, setLeaderboard] = useState<{address: string, count: number}[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function fetchLeaderboard() {
      try {
        setLoading(true)
        const provider = new ethers.BrowserProvider(window.ethereum)
        const contract = new ethers.Contract(orgAddress, orgAttendanceLiteABI, provider)

        const [addresses, counts] = await contract.getLeaderboard()
        const leaderboardData = addresses.map((address: string, index: number) => ({
          address,
          count: Number(counts[index])
        }))

        setLeaderboard(leaderboardData)
      } catch (err) {
        console.error('Error fetching leaderboard:', err)
      } finally {
        setLoading(false)
      }
    }

    fetchLeaderboard()
  }, [orgAddress])

  if (loading) {
    return (
      <div className="flex justify-center py-8">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
      </div>
    )
  }

  return (
    <div className="bg-white shadow rounded-lg overflow-hidden">
      <div className="px-4 py-5 sm:px-6 border-b border-gray-200">
        <h3 className="text-lg font-medium leading-6 text-gray-900">Attendance Leaderboard</h3>
      </div>
      <div className="bg-white divide-y divide-gray-200">
        {leaderboard.length === 0 ? (
          <div className="p-4 text-center text-gray-500">No attendance data yet</div>
        ) : (
          leaderboard.map((item, index) => (
            <div key={item.address} className="px-4 py-4 sm:px-6">
              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <span className="text-gray-500 font-medium mr-4">#{index + 1}</span>
                  <span className="font-mono text-sm">
                    {item.address.slice(0, 6)}...{item.address.slice(-4)}
                  </span>
                </div>
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-indigo-100 text-indigo-800">
                  {item.count} sessions
                </span>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  )
}
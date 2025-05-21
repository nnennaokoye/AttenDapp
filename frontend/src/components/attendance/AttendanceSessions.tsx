import { useEffect, useState } from 'react'
import { ethers } from 'ethers'
import { orgAttendanceLiteABI } from '../../contracts/abis/orgAttendanceLiteABI'
import { SignAttendance } from './SignAttendance'

export function AttendanceSessions({ orgAddress }: { orgAddress: string }) {
  const [sessions, setSessions] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!orgAddress) {
      setLoading(false)
      return
    }
    
    async function fetchSessions() {
      try {
        setLoading(true)
        if (!window.ethereum) {
          setError('Ethereum provider not found')
          setLoading(false)
          return
        }
        
        const provider = new ethers.BrowserProvider(window.ethereum)
        const contract = new ethers.Contract(orgAddress, orgAttendanceLiteABI, provider)

        const sessionCount = await contract.getAttendanceCount()
        const sessionList = []

        for (let i = 0; i < sessionCount; i++) {
          const attendanceId = await contract.attendanceIds(i)
          const session = await contract.attendanceRecords(attendanceId)
          sessionList.push({
            id: attendanceId,
            title: session.sessionTitle,
            teacher: session.teacher,
            timestamp: Number(session.tokenId), // Using tokenId as timestamp for simplicity
            claimed: session.claimed
          })
        }

        setSessions(sessionList)
      } catch (err) {
        console.error('Error fetching sessions:', err)
      } finally {
        setLoading(false)
      }
    }

    fetchSessions()
  }, [orgAddress])

  if (loading) {
    return (
      <div className="flex justify-center py-8">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
      </div>
    )
  }
  
  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 text-red-600 p-4 rounded-md">
        <p>{error}</p>
      </div>
    )
  }

  return (
    <div>
      {sessions.length === 0 ? (
        <p className="text-gray-500">No attendance sessions created yet</p>
      ) : (
        <div className="space-y-4">
          {sessions.map((session) => (
            <div key={session.id} className="bg-gray-50 p-4 rounded-lg border border-gray-200">
              <div className="flex justify-between items-start">
                <div>
                  <h4 className="font-medium text-gray-800">{session.title}</h4>
                  <p className="text-sm text-gray-500 mt-1">
                    ID: {session.id} • {new Date(session.timestamp * 1000).toLocaleString()}
                  </p>
                  <p className="text-xs text-gray-400 mt-1">
                    Teacher: {session.teacher.slice(0, 6)}...{session.teacher.slice(-4)}
                  </p>
                </div>
                <SignAttendance 
                  orgAddress={orgAddress} 
                  sessionId={session.id} 
                  isClaimed={session.claimed}
                />
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
import { useState, useEffect } from 'react'
import { usePublicClient } from 'wagmi'
import { orgAttendanceLiteABI } from '../contracts/abis/orgAttendanceLiteABI'

interface Session {
  id: string;
  [key: string]: any;
}

export function useAttendance(orgAddress: string) {
  const publicClient = usePublicClient()
  const [sessions, setSessions] = useState<Session[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!publicClient || !orgAddress) {
      setLoading(false)
      return
    }
    
    const fetchSessions = async () => {
      try {
        const count = await publicClient.readContract({
          address: orgAddress as `0x${string}`,
          abi: orgAttendanceLiteABI,
          functionName: 'getAttendanceCount'
        })

        const sessionList: Session[] = []
        for (let i = 0; i < Number(count); i++) {
          const id = await publicClient.readContract({
            address: orgAddress as `0x${string}`,
            abi: orgAttendanceLiteABI,
            functionName: 'attendanceIds',
            args: [i]
          })
          const session = await publicClient.readContract({
            address: orgAddress as `0x${string}`,
            abi: orgAttendanceLiteABI,
            functionName: 'attendanceRecords',
            args: [id]
          }) as Record<string, any>
          
          sessionList.push({ id: String(id), ...session })
        }

        setSessions(sessionList)
      } finally {
        setLoading(false)
      }
    }

    fetchSessions()
  }, [orgAddress, publicClient])

  return { sessions, loading }
}
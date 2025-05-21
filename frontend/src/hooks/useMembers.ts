import { usePublicClient } from 'wagmi'
import { useState, useEffect } from 'react'
import { orgAttendanceLiteABI } from '../contracts/abis/orgAttendanceLiteABI'

export function useMembers(orgAddress: string) {
  const publicClient = usePublicClient()
  const [students, setStudents] = useState<string[]>([])
  const [teachers, setTeachers] = useState<string[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!publicClient || !orgAddress) {
      setLoading(false)
      return
    }
    
    const fetchMembers = async () => {
      try {
        // Fetch students
        try {
          const studentCount = await publicClient.readContract({
            address: orgAddress as `0x${string}`,
            abi: orgAttendanceLiteABI,
            functionName: 'getStudentCount'
          })

          const studentList: string[] = []
          for (let i = 0; i < Number(studentCount); i++) {
            const student = await publicClient.readContract({
              address: orgAddress as `0x${string}`,
              abi: orgAttendanceLiteABI,
              functionName: 'studentAddresses',
              args: [i]
            })
            studentList.push(student as string)
          }
          setStudents(studentList)
        } catch (error) {
          console.error('Error fetching students:', error)
          setStudents([])
        }

        // Fetch teachers - simulate for now since contract might not have this
        try {
          // If your contract has a getTeachers or similar function, use it here
          // For now, we'll leave as an empty array since the orgAttendanceLiteABI might not have this function
          setTeachers([])
        } catch (error) {
          console.error('Error fetching teachers:', error)
          setTeachers([])
        }
      } finally {
        setLoading(false)
      }
    }

    fetchMembers()
  }, [orgAddress, publicClient])

  return { students, teachers, loading }
}
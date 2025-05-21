import { useState } from 'react'
import { useAccount, useWalletClient, usePublicClient } from 'wagmi'
import { ORG_ATTENDANCE_LITE_ADDRESS } from '../../contracts/addresses'
import { orgAttendanceLiteABI } from '../../contracts/abis/orgAttendanceLiteABI'
import { useNotification } from '../../ui/Notification'

export function CreateAttendanceSession({ orgAddress }: { orgAddress: string }) {
  const { address } = useAccount()
  const { data: walletClient } = useWalletClient()
  const publicClient = usePublicClient()
  const [sessionTitle, setSessionTitle] = useState('')
  const [attendanceId, setAttendanceId] = useState('')
  const { showNotification } = useNotification()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!walletClient || !address) return

    try {
      const { request } = await publicClient.simulateContract({
        account: address,
        address: orgAddress as `0x${string}`,
        abi: orgAttendanceLiteABI,
        functionName: 'createAttendance',
        args: [attendanceId, sessionTitle]
      })

      const hash = await walletClient.writeContract(request)
      await publicClient.waitForTransactionReceipt({ hash })
      showNotification('success', 'Attendance session created!')
    } catch (error) {
      showNotification('error', 'Failed to create session')
      console.error(error)
    }
  }

  return (
    <div className="bg-gray-50 p-4 rounded-lg">
      <h3 className="text-lg font-medium mb-3">Create Attendance Session</h3>
      <form onSubmit={handleSubmit} className="space-y-3">
        <input
          type="text"
          placeholder="Session Title"
          value={sessionTitle}
          onChange={(e) => setSessionTitle(e.target.value)}
          className="w-full p-2 border rounded"
          required
        />
        <input
          type="text"
          placeholder="Attendance ID"
          value={attendanceId}
          onChange={(e) => setAttendanceId(e.target.value)}
          className="w-full p-2 border rounded"
          required
        />
        <button 
          type="submit"
          className="w-full bg-indigo-600 text-white py-2 rounded hover:bg-indigo-700"
        >
          Create Session
        </button>
      </form>
    </div>
  )
}
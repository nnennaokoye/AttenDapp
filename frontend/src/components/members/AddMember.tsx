import { useState } from 'react'
import { useAccount, useWalletClient } from 'wagmi'
import { useNotification } from '../../ui/Notification'

export function AddMember({ orgAddress }: { orgAddress: string }) {
  const [address, setAddress] = useState('')
  const [role, setRole] = useState<'STUDENT' | 'TEACHER'>('STUDENT')
  const { showNotification } = useNotification()

  const handleAddMember = async () => {
    if (!address) return

    try {
      // Implementation depends on your contract's addMember function
      showNotification('success', `${role} added successfully`)
      setAddress('')
    } catch (error) {
      showNotification('error', 'Failed to add member')
      console.error(error)
    }
  }

  return (
    <div className="bg-gray-50 p-4 rounded-lg">
      <h3 className="text-lg font-medium mb-3">Add Member</h3>
      <div className="space-y-3">
        <input
          type="text"
          placeholder="0x..."
          value={address}
          onChange={(e) => setAddress(e.target.value)}
          className="w-full p-2 border rounded"
        />
        <select
          value={role}
          onChange={(e) => setRole(e.target.value as any)}
          className="w-full p-2 border rounded"
        >
          <option value="STUDENT">Student</option>
          <option value="TEACHER">Teacher</option>
        </select>
        <button
          onClick={handleAddMember}
          className="w-full bg-indigo-600 text-white py-2 rounded hover:bg-indigo-700"
        >
          Add Member
        </button>
      </div>
    </div>
  )
}
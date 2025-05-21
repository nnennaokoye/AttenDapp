import { useState } from 'react'
import { Button } from '../../ui/Button'
import { useNotification } from '../../ui/Notification'

export function AddMember({ orgAddress }: { orgAddress: string }) {
  const { showNotification } = useNotification()
  const [memberAddress, setMemberAddress] = useState('')
  const [isLoading, setIsLoading] = useState(false)

  const handleAddMember = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!memberAddress.trim()) {
      showNotification('error', 'Please enter a member address')
      return
    }

    try {
      setIsLoading(true)
      // TODO: Add blockchain integration logic here
      console.log(`Adding member ${memberAddress} to organization ${orgAddress}`)
      
      // Simulating success for now
      setTimeout(() => {
        showNotification('success', `Member ${memberAddress.slice(0, 6)}...${memberAddress.slice(-4)} added successfully`)
        setMemberAddress('')
        setIsLoading(false)
      }, 1000)
    } catch (error) {
      console.error('Error adding member:', error)
      showNotification('error', 'Failed to add member. Please try again.')
      setIsLoading(false)
    }
  }

  return (
    <div className="border border-gray-200 rounded-lg p-4">
      <h3 className="text-lg font-semibold mb-4">Add New Member</h3>
      
      <form onSubmit={handleAddMember} className="space-y-4">
        <div>
          <label htmlFor="memberAddress" className="block text-sm font-medium text-gray-700 mb-1">
            Member Wallet Address
          </label>
          <input
            type="text"
            id="memberAddress"
            value={memberAddress}
            onChange={(e) => setMemberAddress(e.target.value)}
            placeholder="0x..."
            className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            required
          />
        </div>
        
        <Button 
          type="submit" 
          isLoading={isLoading} 
          className="w-full"
        >
          Add Member
        </Button>
      </form>
    </div>
  )
}

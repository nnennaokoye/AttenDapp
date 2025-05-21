import { useState } from 'react'
import type { FormEvent } from 'react'
import { useAccount, useWalletClient, usePublicClient } from 'wagmi'
import { ORG_FACTORY_PROXY_ADDRESS } from '../../contracts/addresses'
import { orgFactoryProxyABI } from '../../contracts/abis/orgFactoryProxyABI'

export function CreateOrganization() {
  const { address } = useAccount()
  const { data: walletClient } = useWalletClient()
  const publicClient = usePublicClient()
  const [name, setName] = useState('')
  const [description, setDescription] = useState('')
  const [badgeURI, setBadgeURI] = useState('')
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  const [isLoading, setIsLoading] = useState(false)

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    if (!walletClient || !address || !publicClient) {
      setError('Wallet or connection not available')
      return
    }
    
    if (!name.trim()) {
      setError('Organization name is required')
      return
    }

    try {
      setIsLoading(true)
      setError('')
      
      const { request } = await publicClient.simulateContract({
        account: address,
        address: ORG_FACTORY_PROXY_ADDRESS,
        abi: orgFactoryProxyABI,
        functionName: 'createOrganization',
        args: [name, description, badgeURI]
      })

      const hash = await walletClient.writeContract(request)
      await publicClient.waitForTransactionReceipt({ hash })
      setSuccess('Organization created successfully!')
      // Reset form
      setName('')
      setDescription('')
      setBadgeURI('')  
    } catch (err) {
      console.error(err)
      setError('Failed to create organization. Please try again.')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="bg-white rounded-xl shadow-md p-6 mb-8 border border-gray-200">
      <h2 className="text-xl font-semibold text-gray-800 mb-4">
        Create New Organization
      </h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label htmlFor="name" className="block text-sm font-medium text-gray-700">
            Organization Name
          </label>
          <input
            type="text"
            id="name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border"
          />
        </div>
        <div>
          <label htmlFor="description" className="block text-sm font-medium text-gray-700">
            Description
          </label>
          <textarea
            id="description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            rows={3}
            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border"
          />
        </div>
        <div>
          <label htmlFor="badgeURI" className="block text-sm font-medium text-gray-700">
            Badge Image URI
          </label>
          <input
            type="text"
            id="badgeURI"
            value={badgeURI}
            onChange={(e) => setBadgeURI(e.target.value)}
            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border"
            placeholder="https://example.com/badge.png"
          />
          {badgeURI && (
            <div className="mt-2">
              <p className="text-xs text-gray-500">Preview:</p>
              <img 
                src={badgeURI} 
                alt="Badge preview" 
                className="mt-1 h-16 w-16 object-cover rounded-md"
                onError={(e) => {
                  (e.target as HTMLImageElement).style.display = 'none'
                }}
              />
            </div>
          )}
        </div>
        {error && <p className="text-red-500 text-sm">{error}</p>}
        {success && <p className="text-green-500 text-sm">{success}</p>}
        <button
          type="submit"
          disabled={isLoading}
          className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          {isLoading ? (
            <>
              <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              Creating...
            </>
          ) : 'Create Organization'}
        </button>
      </form>
    </div>
  )
}
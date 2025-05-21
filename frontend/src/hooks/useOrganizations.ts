import { useState, useEffect } from 'react'
import { useAccount, usePublicClient } from 'wagmi'
import { ORG_REGISTRY_ADDRESS } from '../contracts/addresses'
import { orgRegistryABI } from '../contracts/abis/orgRegistryABI'

// Define Organization interface
interface Organization {
  name: string;
  description: string;
  badgeURI: string;
  orgAttendanceAddress: string;
  nftAddress: string;
  creationTime: bigint;
  creator: string;
}

export function useOrganizations() {
  const { address } = useAccount()
  const publicClient = usePublicClient()
  const [data, setData] = useState<Organization[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchOrgs = async () => {
      if (!address) return
      
      const orgAddresses = await publicClient.readContract({
        address: ORG_REGISTRY_ADDRESS,
        abi: orgRegistryABI,
        functionName: 'getOrganizationsByCreator',
        args: [address]
      }) as string[]

      const orgs = await Promise.all(
        orgAddresses.map(async (addr) => {
          return await publicClient.readContract({
            address: ORG_REGISTRY_ADDRESS,
            abi: orgRegistryABI,
            functionName: 'getOrganizationByAddress',
            args: [addr]
          }) as Organization
        })
      )

      setData(orgs)
      setLoading(false)
    }

    fetchOrgs()
  }, [address, publicClient])

  return { data, loading }
}
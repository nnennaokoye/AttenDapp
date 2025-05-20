import React, { useState, useEffect } from 'react';
import { useContract, useProvider, useAccount } from 'wagmi';
import Link from 'next/link';
import { ethers } from 'ethers';
import { orgFactoryAbi } from '@/lib/contracts/orgFactoryAbi';
import { CONTRACT_ADDRESS } from '@/lib/web3/config';
import { truncateAddress } from '@/lib/utils';

interface Organization {
  name: string;
  description: string;
  badgeURI: string;
  orgAttendanceAddress: string;
  nftAddress: string;
  creationTime: number;
  creator: string;
}

const OrganizationList: React.FC = () => {
  const provider = useProvider();
  const { address } = useAccount();
  
  const [organizations, setOrganizations] = useState<Organization[]>([]);
  const [myOrganizations, setMyOrganizations] = useState<Organization[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  // Initialize contract
  const contract = useContract({
    address: CONTRACT_ADDRESS,
    abi: orgFactoryAbi,
    signerOrProvider: provider,
  });

  // Load organizations
  useEffect(() => {
    if (!contract) return;
    
    const fetchOrganizations = async () => {
      try {
        setIsLoading(true);
        console.log('Fetching organizations from contract:', CONTRACT_ADDRESS);
        
        // Get total count of organizations
        const count = await contract.getOrganizationCount();
        console.log('Total organizations:', count.toString());
        const orgs: Organization[] = [];
        
        // Fetch each organization
        for (let i = 0; i < count.toNumber(); i++) {
          console.log(`Fetching organization at index ${i}`);
          try {
            const org = await contract.getOrganizationAtIndex(i);
            console.log(`Organization ${i} details:`, {
              name: org.name,
              address: org.orgAttendanceAddress,
              creator: org.creator
            });
            
            orgs.push({
              name: org.name,
              description: org.description,
              badgeURI: org.badgeURI,
              orgAttendanceAddress: org.orgAttendanceAddress,
              nftAddress: org.nftAddress,
              creationTime: org.creationTime.toNumber(),
              creator: org.creator
            });
          } catch (err) {
            console.error(`Error fetching organization at index ${i}:`, err);
          }
        }
        
        console.log('All organizations fetched:', orgs.length);
        setOrganizations(orgs);
        
        // If user is connected, filter for organizations they created
        if (address) {
          console.log('Filtering for user organizations, address:', address);
          const myOrgs = orgs.filter(org => 
            org.creator.toLowerCase() === address.toLowerCase()
          );
          console.log('User organizations found:', myOrgs.length);
          setMyOrganizations(myOrgs);
        }
      } catch (err: any) {
        console.error('Error fetching organizations:', err);
        setError(`Failed to load organizations: ${err.message || 'Unknown error'}`);
      } finally {
        setIsLoading(false);
      }
    };
    
    fetchOrganizations();
  }, [contract, address]);

  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <p>Loading organizations...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-6">
        <p>{error}</p>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* My Organizations Section */}
      {address && (
        <div>
          <h2 className="text-2xl font-bold mb-4">My Organizations</h2>
          
          {myOrganizations.length === 0 ? (
            <p className="text-gray-500">You haven't created any organizations yet.</p>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {myOrganizations.map((org, index) => (
                <OrganizationCard key={index} organization={org} isCreator={true} />
              ))}
            </div>
          )}
        </div>
      )}
      
      {/* All Organizations Section */}
      <div>
        <h2 className="text-2xl font-bold mb-4">All Organizations</h2>
        
        {organizations.length === 0 ? (
          <p className="text-gray-500">No organizations have been created yet.</p>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {organizations.map((org, index) => (
              <OrganizationCard 
                key={index} 
                organization={org} 
                isCreator={address ? org.creator.toLowerCase() === address.toLowerCase() : false} 
              />
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

const OrganizationCard: React.FC<{ organization: Organization; isCreator: boolean }> = ({ 
  organization, 
  isCreator 
}) => {
  return (
    <div className="bg-white shadow-md rounded-lg overflow-hidden">
      <div className="p-6">
        <h3 className="text-xl font-bold mb-2">{organization.name}</h3>
        <p className="text-gray-600 mb-4 line-clamp-2">{organization.description}</p>
        
        <div className="text-sm text-gray-500 mb-4">
          <p>Created by: {truncateAddress(organization.creator)}</p>
          <p>Created on: {new Date(organization.creationTime * 1000).toLocaleDateString()}</p>
        </div>
        
        <div className="flex space-x-2">
          <Link href={`/organizations/${organization.orgAttendanceAddress}`}>
            <span className="px-4 py-2 bg-blue-600 text-white font-semibold rounded-md hover:bg-blue-700 text-sm">
              View Details
            </span>
          </Link>
          
          {isCreator && (
            <Link href={`/organizations/${organization.orgAttendanceAddress}/manage`}>
              <span className="px-4 py-2 bg-green-600 text-white font-semibold rounded-md hover:bg-green-700 text-sm">
                Manage
              </span>
            </Link>
          )}
        </div>
      </div>
    </div>
  );
};

export default OrganizationList;

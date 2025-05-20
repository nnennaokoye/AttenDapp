"use client";

import React, { useState, useEffect } from 'react';
import { useContract, useSigner, useAccount } from 'wagmi';
import { ethers } from 'ethers';
import { useRouter } from 'next/navigation';
import { orgFactoryAbi } from '@/lib/contracts/orgFactoryAbi';
import { CONTRACT_ADDRESS } from '@/lib/web3/config';

const CreateOrganization: React.FC = () => {
  const router = useRouter();
  const { data: signer } = useSigner();
  const { address, isConnected } = useAccount();
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [badgeURI, setBadgeURI] = useState('');
  const [badgePreview, setBadgePreview] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [transactionHash, setTransactionHash] = useState('');
  
  // Initialize contract with ABI and address
  const contract = useContract({
    address: CONTRACT_ADDRESS,
    abi: orgFactoryAbi,
    signerOrProvider: signer,
  });
  
  // Effect to handle wallet connection check
  useEffect(() => {
    if (!isConnected) {
      setError('Please connect your wallet to create an organization');
    } else {
      setError('');
    }
  }, [isConnected]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!name || !description || !badgeURI) {
      setError('Please fill in all fields');
      return;
    }
    
    if (!signer) {
      setError('Please connect your wallet');
      return;
    }
    
    setIsSubmitting(true);
    setError('');
    setSuccess('');
    
    try {
      // Ensure contract is properly initialized with signer
      if (!contract) {
        throw new Error('Contract not initialized');
      }
      
      console.log('Creating organization...');
      
      // Call the contract's createOrganization function with a simple reference URI instead of full image data
      // This avoids the issue of sending too much data to the blockchain
      const simpleUri = `badge-${Date.now()}`;
      
      const tx = await contract.createOrganization(name, description, simpleUri);
      setTransactionHash(tx.hash);
      console.log('Transaction submitted:', tx.hash);
      
      // Wait for transaction to be mined
      const receipt = await tx.wait();
      console.log('Transaction mined:', receipt);
      
      // Check if transaction was successful
      if (receipt.status === 1) {
        setSuccess('Organization created successfully!');
        
        // Parse logs to get organization address
        const orgCreatedEvent = receipt.events?.find(e => e.event === 'OrganizationCreated');
        if (orgCreatedEvent && orgCreatedEvent.args) {
          const orgAddress = orgCreatedEvent.args.orgAttendanceAddress;
          console.log('Organization created at address:', orgAddress);
          
          // Reset form
          setName('');
          setDescription('');
          setBadgeURI('');
          setBadgePreview(null);
          
          // Redirect to the organization page after a short delay
          setTimeout(() => {
            router.push('/organizations');
          }, 3000);
        } else {
          // Even without the event, we'll consider it successful
          setTimeout(() => {
            router.push('/organizations');
          }, 3000);
        }
      } else {
        throw new Error('Transaction failed');
      }
    } catch (err: any) {
      console.error('Error creating organization:', err);
      setError(`Failed to create organization: ${err.message || 'Unknown error'}`);
    } finally {
      setIsSubmitting(false);
    }
  };
  
  // Function to handle file upload and convert to data URI
  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    
    try {
      // Set a loading state
      setBadgeURI('');
      setError('');
      
      // Validate file size (max 5MB)
      if (file.size > 5 * 1024 * 1024) {
        setError('File size too large. Please upload an image smaller than 5MB');
        return;
      }
      
      // Validate file type
      if (!file.type.startsWith('image/')) {
        setError('Please upload a valid image file');
        return;
      }
      
      // Read file as data URL
      const reader = new FileReader();
      reader.onload = (event) => {
        if (event.target && event.target.result) {
          const dataUrl = event.target.result as string;
          setBadgePreview(dataUrl);
          
          // Generate a unique identifier for the file
          const timestamp = Date.now();
          const fileName = file.name.replace(/[^a-zA-Z0-9]/g, '');
          const uniqueId = `${fileName}_${timestamp}`;
          
          // Create a badge URI that includes the data
          // For a production app, you'd upload to IPFS here
          setBadgeURI(`data:${file.type};name=${uniqueId};base64,${dataUrl.split(',')[1]}`);
        }
      };
      reader.onerror = () => {
        setError('Error reading file');
      };
      reader.readAsDataURL(file);
    } catch (err) {
      console.error('Error processing file:', err);
      setError('Failed to process image');
    }
  };

  return (
    <div className="bg-white shadow-md rounded-lg p-6 max-w-md mx-auto">
      <h2 className="text-2xl font-bold mb-6 text-center">Create New Organization</h2>
      
      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}
      
      {success && (
        <div className="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
          <p>{success}</p>
          {transactionHash && (
            <p className="text-xs mt-1">
              Transaction: {transactionHash.substring(0, 10)}...{transactionHash.substring(transactionHash.length - 8)}
            </p>
          )}
        </div>
      )}
      
      <form onSubmit={handleSubmit}>
        <div className="mb-4">
          <label htmlFor="name" className="block text-gray-700 font-medium mb-2">
            Organization Name
          </label>
          <input
            type="text"
            id="name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="e.g., University of Technology"
            required
          />
        </div>
        
        <div className="mb-4">
          <label htmlFor="description" className="block text-gray-700 font-medium mb-2">
            Description
          </label>
          <textarea
            id="description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Brief description of your organization"
            rows={4}
            required
          />
        </div>
        
        <div className="mb-6">
          <label htmlFor="badge" className="block text-gray-700 font-medium mb-2">
            Attendance Badge (NFT)
          </label>
          <input
            type="file"
            id="badge"
            accept="image/*"
            onChange={handleFileChange}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
          {badgePreview && (
            <div className="mt-2">
              <p className="text-sm text-gray-500 mb-2">Badge Preview:</p>
              <img 
                src={badgePreview} 
                alt="Badge Preview" 
                className="max-h-32 rounded-md border border-gray-300"
              />
            </div>
          )}
        </div>
        
        <button
          type="submit"
          disabled={isSubmitting || !name || !description || !badgeURI || !isConnected}
          className="w-full py-2 px-4 bg-blue-600 text-white font-semibold rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-400 disabled:cursor-not-allowed"
        >
          {isSubmitting ? 'Creating...' : 'Create Organization'}
        </button>

        {isSubmitting && (
          <div className="mt-4 p-3 bg-gray-100 rounded text-xs font-mono">
            <p className="font-bold mb-1">Creating organization...</p>
            <p>Please wait while your transaction is processed.</p>
          </div>
        )}
      </form>
    </div>
  );
};

export default CreateOrganization;

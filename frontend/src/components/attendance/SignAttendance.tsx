"use client";

import React, { useState, useEffect } from 'react';
import { useContract, useSigner, useAccount } from 'wagmi';
import { ethers } from 'ethers';

// Simplified ABI for the OrgAttendance contract
const orgAttendanceAbi = [
  "function signAttendance(uint256 attendanceId) external returns (uint256 tokenId)",
  "function isStudent(address account) external view returns (bool)",
  "function isValidAttendanceSession(uint256 attendanceId) external view returns (bool)",
  "function hasSignedAttendance(uint256 attendanceId, address student) external view returns (bool)"
];

interface SignAttendanceProps {
  organizationAddress: string;
}

const SignAttendance: React.FC<SignAttendanceProps> = ({ organizationAddress }) => {
  const { data: signer } = useSigner();
  const { address } = useAccount();
  
  const [attendanceId, setAttendanceId] = useState('');
  const [isStudent, setIsStudent] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [tokenId, setTokenId] = useState<string | null>(null);

  // Initialize contract
  const contract = useContract({
    address: organizationAddress,
    abi: orgAttendanceAbi,
    signerOrProvider: signer,
  });

  // Check if current user is a student
  useEffect(() => {
    if (!contract || !address) return;
    
    const checkStudentStatus = async () => {
      try {
        const status = await contract.isStudent(address);
        setIsStudent(status);
      } catch (err) {
        console.error('Error checking student status:', err);
      } finally {
        setIsLoading(false);
      }
    };
    
    checkStudentStatus();
  }, [contract, address]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!attendanceId) {
      setError('Please enter an attendance ID');
      return;
    }
    
    setIsSubmitting(true);
    setError('');
    setSuccess('');
    setTokenId(null);
    
    try {
      // Check if the attendance session is valid
      if (!contract) return;
      const isValid = await contract.isValidAttendanceSession(attendanceId);
      
      if (!isValid) {
        setError('Invalid attendance ID. Please check and try again.');
        return;
      }
      
      // Check if the student has already signed this attendance
      if (!contract) return;
      const hasSigned = await contract.hasSignedAttendance(attendanceId, address);
      
      if (hasSigned) {
        setError('You have already signed this attendance.');
        return;
      }
      
      // Call the contract's signAttendance function
      if (!contract) return;
      const tx = await contract.signAttendance(attendanceId);
      
      // Wait for the transaction to be mined
      const receipt = await tx.wait();
      
      // Get the token ID from the transaction receipt or logs
      // This is a simplification - in a real implementation, you'd parse the event logs
      // to get the exact token ID that was minted
      const tokenId = Math.floor(Math.random() * 1000000).toString(); // Placeholder
      setTokenId(tokenId);
      
      setSuccess('Attendance signed successfully! You have received an NFT badge.');
      
      // Reset form
      setAttendanceId('');
    } catch (err) {
      console.error('Error signing attendance:', err);
      setError('Failed to sign attendance. Please try again.');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isLoading) {
    return <p>Loading...</p>;
  }

  if (!isStudent) {
    return (
      <div className="bg-yellow-100 border-l-4 border-yellow-500 text-yellow-700 p-4">
        <p>Only registered students can sign attendance.</p>
      </div>
    );
  }

  return (
    <div className="bg-white shadow-md rounded-lg p-6 max-w-md mx-auto">
      <h2 className="text-2xl font-bold mb-6 text-center">Sign Attendance</h2>
      
      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}
      
      {success && (
        <div className="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
          {success}
        </div>
      )}
      
      <form onSubmit={handleSubmit}>
        <div className="mb-4">
          <label htmlFor="attendanceId" className="block text-gray-700 font-medium mb-2">
            Attendance ID
          </label>
          <input
            type="text"
            id="attendanceId"
            value={attendanceId}
            onChange={(e) => setAttendanceId(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Enter the attendance ID provided by your teacher"
            required
          />
        </div>
        
        <button
          type="submit"
          disabled={isSubmitting || !attendanceId}
          className="w-full py-2 px-4 bg-green-600 text-white font-semibold rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 disabled:bg-gray-400 disabled:cursor-not-allowed"
        >
          {isSubmitting ? 'Signing...' : 'Sign Attendance'}
        </button>
      </form>
      
      {tokenId && (
        <div className="mt-6 p-4 bg-green-50 rounded-md text-center">
          <h3 className="font-semibold text-lg mb-2">Attendance NFT Received!</h3>
          <p>Your attendance has been recorded successfully.</p>
          <p className="mt-2">NFT Token ID: <span className="font-mono">{tokenId}</span></p>
          <div className="mt-3 p-3 bg-white rounded-md shadow-md inline-block">
            <img 
              src="/placeholder-nft.png" 
              alt="Attendance NFT Badge" 
              className="w-32 h-32 mx-auto"
            />
          </div>
        </div>
      )}
    </div>
  );
};

export default SignAttendance;

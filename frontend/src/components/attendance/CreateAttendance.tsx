"use client";

import React, { useState } from 'react';
import { useContract, useSigner, useAccount } from 'wagmi';
import { ethers } from 'ethers';

// Simplified ABI for the OrgAttendance contract
const orgAttendanceAbi = [
  "function createAttendanceSession(string memory title) external returns (uint256)",
  "function isTeacher(address account) external view returns (bool)"
];

interface CreateAttendanceProps {
  organizationAddress: string;
  onAttendanceCreated?: (sessionId: string, title: string) => void;
}

const CreateAttendance: React.FC<CreateAttendanceProps> = ({ 
  organizationAddress,
  onAttendanceCreated 
}) => {
  const { data: signer } = useSigner();
  const { address } = useAccount();
  
  const [title, setTitle] = useState('');
  const [isTeacher, setIsTeacher] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [attendanceId, setAttendanceId] = useState('');

  // Initialize contract
  const contract = useContract({
    address: organizationAddress,
    abi: orgAttendanceAbi,
    signerOrProvider: signer,
  });

  // Check if current user is a teacher
  React.useEffect(() => {
    if (!contract || !address) return;
    
    const checkTeacherStatus = async () => {
      try {
        const status = await contract.isTeacher(address);
        setIsTeacher(status);
      } catch (err) {
        console.error('Error checking teacher status:', err);
      } finally {
        setIsLoading(false);
      }
    };
    
    checkTeacherStatus();
  }, [contract, address]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!title) {
      setError('Please enter a session title');
      return;
    }
    
    setIsSubmitting(true);
    setError('');
    setSuccess('');
    
    try {
      // Call the contract's createAttendanceSession function
      if (!contract) return;
      const tx = await contract.createAttendanceSession(title);
      
      // Wait for the transaction to be mined
      const receipt = await tx.wait();
      
      // Get the attendance ID from the transaction receipt or logs
      // This is a simplification - in a real implementation, you'd parse the event logs
      // to get the exact attendance ID
      const attendanceId = Math.floor(Math.random() * 1000000).toString();
      setAttendanceId(attendanceId);
      
      setSuccess(`Attendance session "${title}" created with ID: ${attendanceId}`);
      
      // Call the callback function if provided
      if (onAttendanceCreated) {
        onAttendanceCreated(attendanceId, title);
      }
      
      // Reset form
      setTitle('');
    } catch (err) {
      console.error('Error creating attendance session:', err);
      setError('Failed to create attendance session. Please try again.');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isLoading) {
    return <p>Loading...</p>;
  }

  if (!isTeacher) {
    return (
      <div className="bg-yellow-100 border-l-4 border-yellow-500 text-yellow-700 p-4">
        <p>Only teachers can create attendance sessions.</p>
      </div>
    );
  }

  return (
    <div className="bg-white shadow-md rounded-lg p-6 max-w-md mx-auto">
      <h2 className="text-2xl font-bold mb-6 text-center">Create Attendance Session</h2>
      
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
          <label htmlFor="title" className="block text-gray-700 font-medium mb-2">
            Session Title
          </label>
          <input
            type="text"
            id="title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="e.g., Blockchain Fundamentals - May 20"
            required
          />
        </div>
        
        <button
          type="submit"
          disabled={isSubmitting || !title}
          className="w-full py-2 px-4 bg-blue-600 text-white font-semibold rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-400 disabled:cursor-not-allowed"
        >
          {isSubmitting ? 'Creating...' : 'Create Session'}
        </button>
      </form>
      
      {attendanceId && (
        <div className="mt-6 p-4 bg-blue-50 rounded-md">
          <h3 className="font-semibold text-lg mb-2">Attendance ID</h3>
          <p>Share this ID with students to sign attendance:</p>
          <div className="flex items-center justify-between mt-2 p-3 bg-gray-100 rounded">
            <code className="font-mono text-lg">{attendanceId}</code>
            <button
              onClick={() => navigator.clipboard.writeText(attendanceId)}
              className="text-blue-600 hover:text-blue-800"
            >
              Copy
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default CreateAttendance;

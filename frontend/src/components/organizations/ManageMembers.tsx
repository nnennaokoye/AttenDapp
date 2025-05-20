"use client";

import React, { useState, useEffect } from 'react';
import { useContract, useSigner, useAccount } from 'wagmi';
import { ethers } from 'ethers';
import { truncateAddress } from '@/lib/utils';

// Note: This is a simplified ABI for the OrgAttendance contract
// You'll need to replace this with the actual ABI from your contract
const orgAttendanceAbi = [
  // Functions to add and remove teachers
  "function addTeacher(address teacher) external",
  "function removeTeacher(address teacher) external",
  "function isTeacher(address account) external view returns (bool)",
  "function getTeachers() external view returns (address[])",
  
  // Functions to add and remove students
  "function addStudent(address student) external",
  "function removeStudent(address student) external",
  "function isStudent(address account) external view returns (bool)",
  "function getStudents() external view returns (address[])",
  
  // Function to check if user is admin
  "function isAdmin(address account) external view returns (bool)"
];

interface ManageMembersProps {
  organizationAddress: string;
}

const ManageMembers: React.FC<ManageMembersProps> = ({ organizationAddress }) => {
  const { data: signer } = useSigner();
  const { address } = useAccount();
  
  const [teachers, setTeachers] = useState<string[]>([]);
  const [students, setStudents] = useState<string[]>([]);
  const [newAddress, setNewAddress] = useState('');
  const [isAdmin, setIsAdmin] = useState(false);
  const [isLoadingTeachers, setIsLoadingTeachers] = useState(false);
  const [isLoadingStudents, setIsLoadingStudents] = useState(false);
  const [error, setError] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  // Initialize contract
  const contract = useContract({
    address: organizationAddress,
    abi: orgAttendanceAbi,
    signerOrProvider: signer,
  });

  // Load data
  useEffect(() => {
    if (!contract || !address) return;
    
    const fetchData = async () => {
      try {
        // Check if current user is admin
        const adminStatus = await contract.isAdmin(address);
        setIsAdmin(adminStatus);
        
        // Load teachers
        setIsLoadingTeachers(true);
        const teacherList = await contract.getTeachers();
        setTeachers(teacherList);
        setIsLoadingTeachers(false);
        
        // Load students
        setIsLoadingStudents(true);
        const studentList = await contract.getStudents();
        setStudents(studentList);
        setIsLoadingStudents(false);
      } catch (err) {
        console.error('Error fetching data:', err);
        setError('Failed to load members. Please try again.');
        setIsLoadingTeachers(false);
        setIsLoadingStudents(false);
      }
    };
    
    fetchData();
  }, [contract, address]);

  // Function to add a teacher
  const addTeacher = async () => {
    if (!contract || !ethers.utils.isAddress(newAddress)) {
      setError('Please enter a valid Ethereum address');
      return;
    }
    
    try {
      setError('');
      setSuccessMessage('');
      
      if (!contract) return;
      const tx = await contract.addTeacher(newAddress);
      await tx.wait();
      
      // Refresh teacher list
      const teacherList = await contract.getTeachers();
      setTeachers(teacherList);
      
      setSuccessMessage('Teacher added successfully!');
      setNewAddress('');
    } catch (err) {
      console.error('Error adding teacher:', err);
      setError('Failed to add teacher. Please try again.');
    }
  };

  // Function to add a student
  const addStudent = async () => {
    if (!contract || !ethers.utils.isAddress(newAddress)) {
      setError('Please enter a valid Ethereum address');
      return;
    }
    
    try {
      setError('');
      setSuccessMessage('');
      
      if (!contract) return;
      const tx = await contract.addStudent(newAddress);
      await tx.wait();
      
      // Refresh student list
      const studentList = await contract.getStudents();
      setStudents(studentList);
      
      setSuccessMessage('Student added successfully!');
      setNewAddress('');
    } catch (err) {
      console.error('Error adding student:', err);
      setError('Failed to add student. Please try again.');
    }
  };

  // Function to remove a teacher
  const removeTeacher = async (teacherAddress: string) => {
    try {
      setError('');
      setSuccessMessage('');
      
      if (!contract) return;
      const tx = await contract.removeTeacher(teacherAddress);
      await tx.wait();
      
      // Refresh teacher list
      const teacherList = await contract.getTeachers();
      setTeachers(teacherList);
      
      setSuccessMessage('Teacher removed successfully!');
    } catch (err) {
      console.error('Error removing teacher:', err);
      setError('Failed to remove teacher. Please try again.');
    }
  };

  // Function to remove a student
  const removeStudent = async (studentAddress: string) => {
    try {
      setError('');
      setSuccessMessage('');
      
      if (!contract) return;
      const tx = await contract.removeStudent(studentAddress);
      await tx.wait();
      
      // Refresh student list
      const studentList = await contract.getStudents();
      setStudents(studentList);
      
      setSuccessMessage('Student removed successfully!');
    } catch (err) {
      console.error('Error removing student:', err);
      setError('Failed to remove student. Please try again.');
    }
  };

  if (!isAdmin) {
    return (
      <div className="bg-yellow-100 border-l-4 border-yellow-500 text-yellow-700 p-4">
        <p>You need admin permission to manage members.</p>
      </div>
    );
  }

  return (
    <div className="bg-white shadow-md rounded-lg p-6 max-w-4xl mx-auto">
      <h2 className="text-2xl font-bold mb-6 text-center">Manage Organization Members</h2>
      
      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}
      
      {successMessage && (
        <div className="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
          {successMessage}
        </div>
      )}
      
      <div className="flex flex-col md:flex-row gap-4 mb-6">
        <input
          type="text"
          value={newAddress}
          onChange={(e) => setNewAddress(e.target.value)}
          placeholder="Enter Ethereum address"
          className="flex-grow px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <div className="flex gap-2">
          <button
            onClick={addTeacher}
            className="px-4 py-2 bg-blue-600 text-white font-semibold rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            Add Teacher
          </button>
          <button
            onClick={addStudent}
            className="px-4 py-2 bg-green-600 text-white font-semibold rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500"
          >
            Add Student
          </button>
        </div>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Teachers List */}
        <div>
          <h3 className="text-xl font-semibold mb-4">Teachers</h3>
          {isLoadingTeachers ? (
            <p>Loading teachers...</p>
          ) : teachers.length === 0 ? (
            <p className="text-gray-500">No teachers added yet</p>
          ) : (
            <ul className="space-y-2">
              {teachers.map((teacher, index) => (
                <li key={index} className="flex justify-between items-center border-b pb-2">
                  <span>{truncateAddress(teacher)}</span>
                  <button
                    onClick={() => removeTeacher(teacher)}
                    className="text-red-600 hover:text-red-800"
                  >
                    Remove
                  </button>
                </li>
              ))}
            </ul>
          )}
        </div>
        
        {/* Students List */}
        <div>
          <h3 className="text-xl font-semibold mb-4">Students</h3>
          {isLoadingStudents ? (
            <p>Loading students...</p>
          ) : students.length === 0 ? (
            <p className="text-gray-500">No students added yet</p>
          ) : (
            <ul className="space-y-2">
              {students.map((student, index) => (
                <li key={index} className="flex justify-between items-center border-b pb-2">
                  <span>{truncateAddress(student)}</span>
                  <button
                    onClick={() => removeStudent(student)}
                    className="text-red-600 hover:text-red-800"
                  >
                    Remove
                  </button>
                </li>
              ))}
            </ul>
          )}
        </div>
      </div>
    </div>
  );
};

export default ManageMembers;

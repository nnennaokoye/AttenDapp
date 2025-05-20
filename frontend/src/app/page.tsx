"use client";

import Image from "next/image";
import Link from "next/link";
import { useAccount } from 'wagmi';

export default function Home() {
  const { isConnected } = useAccount();
  
  return (
    <div className="flex flex-col space-y-12">
      {/* Hero Section */}
      <section className="w-full py-12 md:py-24 bg-gradient-to-br from-blue-500 to-indigo-700 text-white">
        <div className="container mx-auto px-4 text-center">
          <h1 className="text-4xl md:text-5xl font-bold mb-6">
            Welcome to AttenDapp
          </h1>
          <p className="text-xl md:text-2xl mb-8 max-w-3xl mx-auto">
            A blockchain-based attendance system with NFT rewards
          </p>
        </div>
      </section>

      {/* Features Section */}
      <section className="w-full py-16 bg-white">
        <div className="container mx-auto px-4">
          <h2 className="text-3xl font-bold text-center mb-12">How It Works</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="bg-blue-50 rounded-lg p-6 flex flex-col items-center text-center">
              <div className="bg-blue-100 p-4 rounded-full mb-4">
                <svg className="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
                </svg>
              </div>
              <h3 className="text-xl font-semibold mb-2">Create Organization</h3>
              <p className="text-gray-600">Organizations deploy contracts with organization details and custom NFT badges</p>
            </div>
            
            <div className="bg-blue-50 rounded-lg p-6 flex flex-col items-center text-center">
              <div className="bg-blue-100 p-4 rounded-full mb-4">
                <svg className="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
                </svg>
              </div>
              <h3 className="text-xl font-semibold mb-2">Record Attendance</h3>
              <p className="text-gray-600">Teachers create attendance sessions with unique IDs for each class</p>
            </div>
            
            <div className="bg-blue-50 rounded-lg p-6 flex flex-col items-center text-center">
              <div className="bg-blue-100 p-4 rounded-full mb-4">
                <svg className="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v13m0-13V6a2 2 0 112 2h-2zm0 0V5.5A2.5 2.5 0 109.5 8H12zm-7 4h14M5 12a2 2 0 110-4h14a2 2 0 110 4M5 12v7a2 2 0 002 2h10a2 2 0 002-2v-7"></path>
                </svg>
              </div>
              <h3 className="text-xl font-semibold mb-2">Earn NFT Badges</h3>
              <p className="text-gray-600">Students sign attendance and receive NFT badges as proof of participation</p>
            </div>
          </div>
        </div>
      </section>

      {/* Call to Action */}
      <section className="w-full py-16 bg-gray-50">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-3xl font-bold mb-6">Ready to Get Started?</h2>
          <p className="text-xl text-gray-600 mb-8 max-w-3xl mx-auto">
            Join the future of attendance tracking with blockchain technology
          </p>
          <div className="flex flex-col md:flex-row justify-center gap-4">
            <Link href="/organizations">
              <span className="inline-block bg-blue-600 text-white font-bold py-3 px-8 rounded-md shadow hover:bg-blue-700 transition duration-300">
                Browse Organizations
              </span>
            </Link>
            <Link href="/organizations/create">
              <span className="inline-block bg-white text-blue-600 font-bold py-3 px-8 rounded-md shadow border border-blue-600 hover:bg-blue-50 transition duration-300">
                Create Organization
              </span>
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}

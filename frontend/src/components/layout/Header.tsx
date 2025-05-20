"use client";

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useAccount } from 'wagmi';
import ConnectWallet from '../web3/ConnectWallet';

const Header: React.FC = () => {
  const pathname = usePathname();
  const { isConnected } = useAccount();

  return (
    <header className="bg-gradient-to-r from-blue-700 to-indigo-800 text-white shadow-md">
      <div className="container mx-auto px-4 py-4">
        <div className="flex flex-col md:flex-row justify-between items-center">
          <div className="flex items-center mb-4 md:mb-0">
            <Link href="/">
              <span className="text-2xl font-bold tracking-tight cursor-pointer">
                AttenDapp
              </span>
            </Link>
            <span className="ml-2 bg-blue-600 text-xs px-2 py-1 rounded-full">beta</span>
          </div>

          <div className="flex items-center space-x-1 md:space-x-4">
            <nav className="flex space-x-1 md:space-x-8 mr-4 text-sm md:text-base">
              <Link href="/">
                <span className={`hover:text-blue-200 py-2 px-1 ${pathname === '/' ? 'border-b-2 border-white font-medium' : ''} cursor-pointer`}>
                  Dashboard
                </span>
              </Link>
              <Link href="/organizations">
                <span className={`hover:text-blue-200 py-2 px-1 ${pathname?.startsWith('/organizations') ? 'border-b-2 border-white font-medium' : ''} cursor-pointer`}>
                  Organizations
                </span>
              </Link>
              {isConnected && (
                <Link href="/profile">
                  <span className={`hover:text-blue-200 py-2 px-1 ${pathname === '/profile' ? 'border-b-2 border-white font-medium' : ''} cursor-pointer`}>
                    Profile
                  </span>
                </Link>
              )}
            </nav>
            <ConnectWallet />
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;

import React from 'react';
import Link from 'next/link';

const Footer: React.FC = () => {
  return (
    <footer className="bg-gray-800 text-white py-8">
      <div className="container mx-auto px-4">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div>
            <h3 className="text-xl font-semibold mb-4">AttenDapp</h3>
            <p className="text-gray-400">
              Blockchain-based attendance tracking system with NFT rewards for educational institutions and organizations.
            </p>
          </div>
          
          <div>
            <h3 className="text-lg font-semibold mb-4">Quick Links</h3>
            <ul className="space-y-2">
              <li>
                <Link href="/">
                  <span className="text-gray-400 hover:text-white cursor-pointer">Home</span>
                </Link>
              </li>
              <li>
                <Link href="/organizations">
                  <span className="text-gray-400 hover:text-white cursor-pointer">Organizations</span>
                </Link>
              </li>
              <li>
                <Link href="/profile">
                  <span className="text-gray-400 hover:text-white cursor-pointer">Profile</span>
                </Link>
              </li>
            </ul>
          </div>
          
          <div>
            <h3 className="text-lg font-semibold mb-4">Resources</h3>
            <ul className="space-y-2">
              <li>
                <a href="#" className="text-gray-400 hover:text-white">Documentation</a>
              </li>
              <li>
                <a href="https://github.com/big14way/AttenDapp" target="_blank" rel="noopener noreferrer" className="text-gray-400 hover:text-white">GitHub</a>
              </li>
              <li>
                <a href="#" className="text-gray-400 hover:text-white">Support</a>
              </li>
            </ul>
          </div>
        </div>
        
        <div className="border-t border-gray-700 mt-8 pt-6 text-center text-gray-400">
          <p>&copy; {new Date().getFullYear()} AttenDapp. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;

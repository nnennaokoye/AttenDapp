"use client";

import React, { ReactNode, useEffect, useState } from 'react';
import { createClient, configureChains, WagmiConfig } from 'wagmi';
import { publicProvider } from 'wagmi/providers/public';
import { MetaMaskConnector } from 'wagmi/connectors/metaMask';
import { CoinbaseWalletConnector } from 'wagmi/connectors/coinbaseWallet';
import { WalletConnectConnector } from 'wagmi/connectors/walletConnect';
import { availableChains } from '@/lib/web3/config';

interface Web3ProviderProps {
  children: ReactNode;
}

const Web3Provider: React.FC<Web3ProviderProps> = ({ children }) => {
  const [mounted, setMounted] = useState(false);

  // Configure chains & providers
  const { chains, provider, webSocketProvider } = configureChains(
    availableChains,
    [publicProvider()]
  );

  // Set up client
  const client = createClient({
    autoConnect: true,
    connectors: [
      new MetaMaskConnector({ chains }),
      new CoinbaseWalletConnector({
        chains,
        options: {
          appName: 'AttenDapp',
        },
      }),
      new WalletConnectConnector({
        chains,
        options: {
          projectId: 'YOUR_WALLET_CONNECT_PROJECT_ID', // Replace with actual project ID if using WalletConnect
        },
      }),
    ],
    provider,
    webSocketProvider,
  });

  // Handle hydration issue by mounting only after client-side rendering
  useEffect(() => {
    setMounted(true);
  }, []);

  return (
    <WagmiConfig client={client}>
      {mounted && children}
    </WagmiConfig>
  );
};

export default Web3Provider;

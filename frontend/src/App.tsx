import { useAccount } from 'wagmi'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { ConnectButton } from './components/auth/ConnectButton'
import { OrganizationList } from './components/organization/OrganizationList'
import { OrganizationDashboard } from './components/organization/OrganizationDashboard'
import { useOrganizations } from './hooks/useOrganizations'
import { NotificationProvider } from './ui/Notification'

function Home() {
  const { isConnected } = useAccount()
  const { data: organizations, loading } = useOrganizations()

  if (!isConnected) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="bg-white p-8 rounded-lg shadow-md max-w-md w-full">
          <h1 className="text-2xl font-bold mb-4">Attendance NFT System</h1>
          <ConnectButton />
        </div>
      </div>
    )
  }

  return (
    <div className="container mx-auto p-4">
      <header className="flex justify-between items-center mb-8">
        <h1 className="text-2xl font-bold">Your Organizations</h1>
      </header>
      
      <OrganizationList organizations={organizations} loading={loading} />
    </div>
  )
}

function Layout({ children }: { children: React.ReactNode }) {
  return (
    <NotificationProvider>
      <div className="min-h-screen bg-gray-50">
        {children}
      </div>
    </NotificationProvider>
  )
}

export default function App() {
  return (
    <BrowserRouter>
      <Layout>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/organization/:address" element={<OrganizationDashboard />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </Layout>
    </BrowserRouter>
  )
}
import { useAccount } from 'wagmi'
import { useState, useEffect } from 'react'
import { useParams } from 'react-router-dom'
import { AddMember } from './AddMember'
import { CreateAttendanceSession } from '../attendance/CreateAttendanceSession'
import { MemberList } from '../members/MemberList'
import { AttendanceSessions } from '../attendance/AttendanceSessions'
import { Leaderboard } from '../leaderboard/Leaderboard'
import { useOrganizations } from '../../hooks/useOrganizations'

type OrganizationDashboardProps = {
  org?: any
}

export function OrganizationDashboard({ org: propOrg }: OrganizationDashboardProps) {
  const { address } = useParams()
  const { address: userAddress } = useAccount()
  const { data: organizations } = useOrganizations()
  const [activeTab, setActiveTab] = useState('members')
  const [org, setOrg] = useState<any>(propOrg)

  // If org is not provided as prop, find it from the address parameter
  useEffect(() => {
    if (!propOrg && address && organizations) {
      const foundOrg = organizations.find(o => o.orgAttendanceAddress === address)
      if (foundOrg) {
        setOrg(foundOrg)
      }
    }
  }, [address, organizations, propOrg])

  if (!org) {
    return <div className="text-center py-8">Loading organization details...</div>
  }

  const isOwner = org.creator === userAddress

  return (
    <div className="bg-white rounded-xl shadow-md overflow-hidden border border-gray-200">
      <div className="p-6">
        <div className="flex justify-between items-start">
          <div>
            <h2 className="text-2xl font-bold text-gray-800">{org.name}</h2>
            <p className="text-gray-600 mt-2">{org.description}</p>
            <div className="mt-2 flex items-center">
              <span className="text-sm text-gray-500 mr-2">Badge:</span>
              <img 
                src={org.badgeURI} 
                alt="Organization badge" 
                className="h-8 w-8 rounded-full object-cover"
                onError={(e) => {
                  (e.target as HTMLImageElement).style.display = 'none'
                }}
              />
            </div>
          </div>
          {isOwner && (
            <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
              Owner
            </span>
          )}
        </div>

        <div className="mt-6 border-b border-gray-200">
          <nav className="-mb-px flex space-x-8 overflow-x-auto">
            <button
              onClick={() => setActiveTab('members')}
              className={`whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm ${activeTab === 'members' ? 'border-indigo-500 text-indigo-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'}`}
            >
              Members
            </button>
            <button
              onClick={() => setActiveTab('sessions')}
              className={`whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm ${activeTab === 'sessions' ? 'border-indigo-500 text-indigo-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'}`}
            >
              Sessions
            </button>
            <button
              onClick={() => setActiveTab('leaderboard')}
              className={`whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm ${activeTab === 'leaderboard' ? 'border-indigo-500 text-indigo-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'}`}
            >
              Leaderboard
            </button>
            {isOwner && (
              <button
                onClick={() => setActiveTab('manage')}
                className={`whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm ${activeTab === 'manage' ? 'border-indigo-500 text-indigo-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'}`}
              >
                Manage
              </button>
            )}
          </nav>
        </div>

        <div className="mt-6">
          {activeTab === 'members' && <MemberList orgAddress={org.orgAttendanceAddress} />}
          {activeTab === 'sessions' && <AttendanceSessions orgAddress={org.orgAttendanceAddress} />}
          {activeTab === 'leaderboard' && <Leaderboard orgAddress={org.orgAttendanceAddress} />}
          {activeTab === 'manage' && isOwner && (
            <div className="space-y-6">
              <AddMember orgAddress={org.orgAttendanceAddress} />
              <CreateAttendanceSession orgAddress={org.orgAttendanceAddress} />
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
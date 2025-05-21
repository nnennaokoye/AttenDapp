import { useNavigate } from 'react-router-dom'
import { formatDate } from '../../utils/format'
import { Badge } from '../../ui/Badge'
import { Button } from '../../ui/Button'

interface OrganizationCardProps {
  org: {
    name: string
    description: string
    badgeURI: string
    orgAttendanceAddress: string
    creationTime: bigint | number
    nftAddress: string
    creator?: string
  }
}

export function OrganizationCard({ org }: OrganizationCardProps) {
  const navigate = useNavigate()

  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden border border-gray-200 hover:shadow-lg transition-shadow">
      <div className="p-6">
        <div className="flex items-start justify-between">
          <div>
            <h3 className="text-lg font-semibold text-gray-800">{org.name}</h3>
            <p className="mt-2 text-gray-600 line-clamp-2">{org.description}</p>
          </div>
          {org.badgeURI && (
            <img 
              src={org.badgeURI} 
              alt={`${org.name} badge`}
              className="h-12 w-12 rounded-full object-cover border border-gray-200"
              onError={(e) => {
                (e.target as HTMLImageElement).style.display = 'none'
              }}
            />
          )}
        </div>

        <div className="mt-4 flex flex-wrap gap-2">
          <Badge variant="secondary">
            Created: {formatDate(org.creationTime)}
          </Badge>
          <Badge variant="outline">
            {org.orgAttendanceAddress.slice(0, 6)}...{org.orgAttendanceAddress.slice(-4)}
          </Badge>
        </div>

        <div className="mt-6 flex justify-between items-center">
          <Button 
            variant="outline"
            onClick={() => navigator.clipboard.writeText(org.orgAttendanceAddress)}
          >
            Copy Address
          </Button>
          <Button 
            onClick={() => navigate(`/organization/${org.orgAttendanceAddress}`)}
          >
            View Dashboard
          </Button>
        </div>
      </div>
    </div>
  )
}
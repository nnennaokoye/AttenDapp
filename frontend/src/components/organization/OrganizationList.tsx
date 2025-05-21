// In your organization list component
import { OrganizationCard } from './OrganizationCard'
import { CreateOrganization } from './CreateOrganization'

interface OrganizationListProps {
  organizations: any[]
  loading: boolean
}

export function OrganizationList({ organizations, loading }: OrganizationListProps) {
  if (loading) {
    return <div className="text-center py-8">Loading organizations...</div>
  }

  return (
    <div className="space-y-8">
      <CreateOrganization />
      
      {organizations.length === 0 ? (
        <div className="bg-gray-50 p-8 rounded-lg text-center">
          <h3 className="text-lg font-medium text-gray-600">No organizations found</h3>
          <p className="mt-2 text-gray-500">Create your first organization to get started</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {organizations.map((org) => (
            <OrganizationCard key={org.orgAttendanceAddress} org={org} />
          ))}
        </div>
      )}
    </div>
  )
}
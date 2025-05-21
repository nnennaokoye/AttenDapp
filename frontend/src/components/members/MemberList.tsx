import { useMembers } from '../../hooks/useMembers'

export function MemberList({ orgAddress }: { orgAddress: string }) {
  const { students, teachers, loading } = useMembers(orgAddress)

  if (loading) return <div className="text-center py-4">Loading members...</div>

  return (
    <div className="space-y-6">
      <div>
        <h4 className="font-medium mb-2">Teachers</h4>
        {teachers.length > 0 ? (
          <ul className="space-y-2">
            {teachers.map((teacher: string) => (
              <li key={teacher} className="bg-gray-50 p-2 rounded">
                {teacher}
              </li>
            ))}
          </ul>
        ) : (
          <p className="text-gray-500">No teachers added</p>
        )}
      </div>
      <div>
        <h4 className="font-medium mb-2">Students</h4>
        {students.length > 0 ? (
          <ul className="space-y-2">
            {students.map((student: string) => (
              <li key={student} className="bg-gray-50 p-2 rounded">
                {student}
              </li>
            ))}
          </ul>
        ) : (
          <p className="text-gray-500">No students added</p>
        )}
      </div>
    </div>
  )
}
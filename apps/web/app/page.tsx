import React from 'react'

type User = { id: string; name: string; email?: string }

async function getUsers(): Promise<User[]> {
  const apiUrl = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:3333/api'
  const res = await fetch(`${apiUrl}/users`, { cache: 'no-store' })
  if (!res.ok) return []
  return res.json()
}

export default async function Page() {
  const users = await getUsers()
  return (
    <div>
      <h1 className="text-2xl font-semibold mb-4">Users</h1>
      {users.length === 0 ? (
        <p>No users yet.</p>
      ) : (
        <ul className="space-y-2">
          {users.map((u) => (
            <li key={u.id} className="p-3 bg-white rounded shadow-sm">
              <div className="font-medium">{u.name}</div>
              <div className="text-sm text-slate-500">{u.email}</div>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}

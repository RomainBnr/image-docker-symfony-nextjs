import { NextRequest, NextResponse } from 'next/server'

// Données de test pour les utilisateurs
const mockUsers = [
  {
    id: 1,
    name: "Alice Martin",
    email: "alice.martin@example.com",
    role: "admin",
    created_at: "2024-01-15T10:30:00Z"
  },
  {
    id: 2,
    name: "Bob Dupont",
    email: "bob.dupont@example.com",
    role: "moderator",
    created_at: "2024-02-20T14:15:00Z"
  },
  {
    id: 3,
    name: "Claire Leroy",
    email: "claire.leroy@example.com",
    role: "user",
    created_at: "2024-03-10T09:45:00Z"
  },
  {
    id: 4,
    name: "David Bernard",
    email: "david.bernard@example.com",
    role: "user",
    created_at: "2024-03-25T16:20:00Z"
  },
  {
    id: 5,
    name: "Emma Rousseau",
    email: "emma.rousseau@example.com",
    role: "moderator",
    created_at: "2024-04-05T11:10:00Z"
  }
]

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '10')
    
    // Simulation d'un délai d'API
    await new Promise(resolve => setTimeout(resolve, 200))
    
    // Pagination
    const startIndex = (page - 1) * limit
    const endIndex = startIndex + limit
    const paginatedUsers = mockUsers.slice(startIndex, endIndex)
    
    return NextResponse.json({
      success: true,
      data: paginatedUsers,
      pagination: {
        page,
        limit,
        total: mockUsers.length,
        pages: Math.ceil(mockUsers.length / limit)
      }
    })
  } catch (error) {
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la récupération des utilisateurs',
        message: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}

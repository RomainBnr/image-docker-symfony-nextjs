import { NextRequest, NextResponse } from 'next/server'

// Données de test pour les articles
const mockPosts = [
  {
    id: 1,
    title: "Introduction à Next.js 14",
    content: "Next.js 14 apporte de nombreuses améliorations en termes de performances et de développement. Découvrez les nouvelles fonctionnalités comme App Router, Server Components et bien plus encore.",
    author: "Alice Martin",
    created_at: "2024-01-15T10:30:00Z"
  },
  {
    id: 2,
    title: "Symfony et l'architecture moderne",
    content: "Symfony continue d'évoluer pour s'adapter aux besoins modernes du développement web. Cette article explore les dernières bonnes pratiques et patterns architecturaux.",
    author: "Bob Dupont",
    created_at: "2024-02-20T14:15:00Z"
  },
  {
    id: 3,
    title: "Docker pour le développement",
    content: "L'utilisation de Docker en développement permet de créer des environnements reproductibles et isolés. Voici comment optimiser votre workflow avec Docker Compose.",
    author: "Claire Leroy",
    created_at: "2024-03-10T09:45:00Z"
  },
  {
    id: 4,
    title: "TypeScript et React",
    content: "TypeScript apporte une sécurité de type précieuse au développement React. Découvrez les meilleures pratiques pour une intégration réussie.",
    author: "David Bernard",
    created_at: "2024-03-25T16:20:00Z"
  },
  {
    id: 5,
    title: "Optimisation des performances web",
    content: "Les performances web sont cruciales pour l'expérience utilisateur. Explorez les techniques d'optimisation pour améliorer le temps de chargement et l'interactivité.",
    author: "Emma Rousseau",
    created_at: "2024-04-05T11:10:00Z"
  }
]

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '10')
    
    // Simulation d'un délai d'API
    await new Promise(resolve => setTimeout(resolve, 300))
    
    // Pagination
    const startIndex = (page - 1) * limit
    const endIndex = startIndex + limit
    const paginatedPosts = mockPosts.slice(startIndex, endIndex)
    
    return NextResponse.json({
      success: true,
      data: paginatedPosts,
      pagination: {
        page,
        limit,
        total: mockPosts.length,
        pages: Math.ceil(mockPosts.length / limit)
      }
    })
  } catch (error) {
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la récupération des articles',
        message: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}

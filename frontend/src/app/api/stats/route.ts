import { NextResponse } from 'next/server'

export async function GET() {
  try {
    // Simulation d'un délai d'API
    await new Promise(resolve => setTimeout(resolve, 100))
    
    return NextResponse.json({
      success: true,
      data: {
        users_count: 5,
        posts_count: 5,
        active_sessions: 12,
        last_updated: new Date().toISOString()
      }
    })
  } catch (error) {
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la récupération des statistiques',
        message: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}

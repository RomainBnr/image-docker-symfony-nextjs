'use client'

import { useState, useEffect, useCallback, useMemo } from 'react'
import Image from 'next/image'

interface User {
  id: number
  name: string
  email: string
  role?: string
  created_at?: string
}

interface Post {
  id: number
  title: string
  content: string
  author: string
  created_at: string
}

interface ApiResponse<T> {
  success: boolean
  data: T
  pagination?: {
    page: number
    limit: number
    total: number
    pages: number
  }
  error?: string
  message?: string
}

// Hook personnalisé pour les appels API avec cache
function useApiCall<T>(url: string, dependencies: unknown[] = []) {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchData = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)
      
      const response = await fetch(url, {
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        // Cache côté navigateur
        cache: 'force-cache',
      })
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const result: ApiResponse<T> = await response.json()
      
      if (result.success) {
        setData(result.data)
      } else {
        setError(result.error || 'Une erreur est survenue')
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur inconnue')
    } finally {
      setLoading(false)
    }
  }, [url])

  useEffect(() => {
    fetchData()
  }, [fetchData, ...dependencies])

  return { data, loading, error, refetch: fetchData }
}

// Composant optimisé pour afficher un utilisateur
const UserCard = ({ user }: { user: User }) => (
  <div className="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow duration-200">
    <div className="flex items-center space-x-4">
      <div className="w-12 h-12 bg-blue-500 rounded-full flex items-center justify-center text-white font-bold">
        {user.name.charAt(0)}
      </div>
      <div className="flex-1">
        <h3 className="text-lg font-semibold text-gray-900">{user.name}</h3>
        <p className="text-gray-600">{user.email}</p>
        {user.role && (
          <span className={`inline-block px-2 py-1 text-xs rounded-full mt-2 ${
            user.role === 'admin' ? 'bg-red-100 text-red-800' :
            user.role === 'moderator' ? 'bg-yellow-100 text-yellow-800' :
            'bg-green-100 text-green-800'
          }`}>
            {user.role}
          </span>
        )}
      </div>
    </div>
  </div>
)

// Composant optimisé pour afficher un post
const PostCard = ({ post }: { post: Post }) => (
  <article className="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow duration-200">
    <h2 className="text-xl font-bold text-gray-900 mb-3">{post.title}</h2>
    <p className="text-gray-700 mb-4 line-clamp-3">{post.content}</p>
    <div className="flex justify-between items-center text-sm text-gray-500">
      <span>Par {post.author}</span>
      <time dateTime={post.created_at}>
        {new Date(post.created_at).toLocaleDateString('fr-FR')}
      </time>
    </div>
  </article>
)

// Composant de pagination réutilisable
const Pagination = ({ 
  currentPage, 
  totalPages, 
  onPageChange 
}: { 
  currentPage: number
  totalPages: number
  onPageChange: (page: number) => void 
}) => (
  <div className="flex justify-center space-x-2 mt-8">
    <button
      onClick={() => onPageChange(Math.max(1, currentPage - 1))}
      disabled={currentPage <= 1}
      className="px-4 py-2 rounded-md bg-blue-500 text-white disabled:bg-gray-300 disabled:cursor-not-allowed hover:bg-blue-600 transition-colors"
    >
      Précédent
    </button>
    <span className="px-4 py-2 bg-gray-100 rounded-md">
      Page {currentPage} sur {totalPages}
    </span>
    <button
      onClick={() => onPageChange(Math.min(totalPages, currentPage + 1))}
      disabled={currentPage >= totalPages}
      className="px-4 py-2 rounded-md bg-blue-500 text-white disabled:bg-gray-300 disabled:cursor-not-allowed hover:bg-blue-600 transition-colors"
    >
      Suivant
    </button>
  </div>
)

export default function Home() {
  const [currentPage, setCurrentPage] = useState(1)
  const [postsPage, setPostsPage] = useState(1)
  const pageSize = 3

  // Appels API optimisés avec hooks personnalisés
  const { 
    data: usersResponse, 
    loading: usersLoading, 
    error: usersError 
  } = useApiCall<ApiResponse<User[]>>(`/api/users?page=${currentPage}&limit=${pageSize}`, [currentPage])
  
  const { 
    data: postsResponse, 
    loading: postsLoading, 
    error: postsError 
  } = useApiCall<ApiResponse<Post[]>>(`/api/posts?page=${postsPage}&limit=${pageSize}`, [postsPage])
  
  const { 
    data: statsResponse, 
    loading: statsLoading 
  } = useApiCall<ApiResponse<any>>('/api/stats')

  // Mémorisation des données pour éviter les re-renders inutiles
  const users = useMemo(() => usersResponse?.data || [], [usersResponse])
  const posts = useMemo(() => postsResponse?.data || [], [postsResponse])
  const stats = useMemo(() => statsResponse?.data || null, [statsResponse])
  
  // Pagination des données
  const usersPagination = useMemo(() => usersResponse?.pagination, [usersResponse])
  const postsPagination = useMemo(() => postsResponse?.pagination, [postsResponse])

  const isLoading = usersLoading || postsLoading
  const hasError = usersError || postsError

  if (hasError) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-red-600 mb-4">Erreur</h1>
          <p className="text-gray-700">{usersError || postsError}</p>
          <button 
            onClick={() => window.location.reload()}
            className="mt-4 px-6 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors"
          >
            Réessayer
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header optimisé */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center justify-between">
            <h1 className="text-3xl font-bold text-gray-900">
              Dashboard Symfony + Next.js
            </h1>
            {!statsLoading && stats && (
              <div className="text-sm text-gray-600">
                {stats.users_count} utilisateurs • {stats.posts_count} articles
              </div>
            )}
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {isLoading ? (
          <div className="flex justify-center items-center h-64">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            {/* Section Utilisateurs */}
            <section>
              <h2 className="text-2xl font-bold text-gray-900 mb-6">Utilisateurs</h2>
              <div className="space-y-4">
                {users.map((user) => (
                  <UserCard key={user.id} user={user} />
                ))}
              </div>
              <Pagination
                currentPage={currentPage}
                totalPages={usersPagination?.pages || 1}
                onPageChange={setCurrentPage}
              />
            </section>

            {/* Section Articles */}
            <section>
              <h2 className="text-2xl font-bold text-gray-900 mb-6">Articles</h2>
              <div className="space-y-4">
                {posts.map((post) => (
                  <PostCard key={post.id} post={post} />
                ))}
              </div>
              <Pagination
                currentPage={postsPage}
                totalPages={postsPagination?.pages || 1}
                onPageChange={setPostsPage}
              />
            </section>
          </div>
        )}
      </main>

      {/* Footer */}
      <footer className="bg-white border-t">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <p className="text-center text-gray-500 text-sm">
            Application Symfony + Next.js optimisée pour les performances
          </p>
        </div>
      </footer>
    </div>
  )
}

<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\HttpFoundation\Response;

#[Route('/api', name: 'api_')]
class ApiController extends AbstractController
{
    #[Route('/health', name: 'health', methods: ['GET'])]
    public function health(): JsonResponse
    {
        return $this->json([
            'status' => 'ok',
            'timestamp' => new \DateTimeImmutable(),
            'version' => '2.0.0',
            'environment' => $this->getParameter('kernel.environment')
        ]);
    }

    #[Route('/users', name: 'users_list', methods: ['GET'])]
    public function getUsers(Request $request): JsonResponse
    {
        // Pagination simple
        $page = max(1, $request->query->getInt('page', 1));
        $limit = min(100, max(1, $request->query->getInt('limit', 10)));
        
        $users = $this->getUsersData();
        
        // Pagination
        $offset = ($page - 1) * $limit;
        $paginatedUsers = array_slice($users, $offset, $limit);
        
        return $this->json([
            'success' => true,
            'data' => $paginatedUsers,
            'pagination' => [
                'page' => $page,
                'limit' => $limit,
                'total' => count($users),
                'pages' => ceil(count($users) / $limit)
            ]
        ]);
    }

    #[Route('/users/{id}', name: 'user_show', methods: ['GET'], requirements: ['id' => '\d+'])]
    public function getUserById(int $id): JsonResponse
    {
        $users = $this->getUsersData();
        $user = array_filter($users, fn($u) => $u['id'] === $id);
        
        if (empty($user)) {
            return $this->json([
                'success' => false,
                'error' => 'User not found',
                'message' => "User with ID {$id} does not exist"
            ], Response::HTTP_NOT_FOUND);
        }

        return $this->json([
            'success' => true,
            'data' => array_values($user)[0]
        ]);
    }

    #[Route('/posts', name: 'posts_list', methods: ['GET'])]
    public function getPosts(Request $request): JsonResponse
    {
        $page = max(1, $request->query->getInt('page', 1));
        $limit = min(50, max(1, $request->query->getInt('limit', 10)));
        
        $posts = $this->getPostsData();
        
        $offset = ($page - 1) * $limit;
        $paginatedPosts = array_slice($posts, $offset, $limit);
        
        return $this->json([
            'success' => true,
            'data' => $paginatedPosts,
            'pagination' => [
                'page' => $page,
                'limit' => $limit,
                'total' => count($posts),
                'pages' => ceil(count($posts) / $limit)
            ]
        ]);
    }

    #[Route('/stats', name: 'stats', methods: ['GET'])]
    public function getStats(): JsonResponse
    {
        $users = $this->getUsersData();
        $posts = $this->getPostsData();
        
        return $this->json([
            'success' => true,
            'data' => [
                'users_count' => count($users),
                'posts_count' => count($posts),
                'last_updated' => new \DateTimeImmutable(),
                'performance' => [
                    'memory_usage' => memory_get_usage(true),
                    'peak_memory' => memory_get_peak_usage(true),
                ]
            ]
        ]);
    }

    private function getUsersData(): array
    {
        return [
            ['id' => 1, 'name' => 'John Doe', 'email' => 'john@example.com', 'role' => 'admin', 'created_at' => '2024-01-01'],
            ['id' => 2, 'name' => 'Jane Smith', 'email' => 'jane@example.com', 'role' => 'user', 'created_at' => '2024-01-02'],
            ['id' => 3, 'name' => 'Bob Johnson', 'email' => 'bob@example.com', 'role' => 'user', 'created_at' => '2024-01-03'],
            ['id' => 4, 'name' => 'Alice Brown', 'email' => 'alice@example.com', 'role' => 'moderator', 'created_at' => '2024-01-04'],
            ['id' => 5, 'name' => 'Charlie Davis', 'email' => 'charlie@example.com', 'role' => 'user', 'created_at' => '2024-01-05'],
        ];
    }

    private function getPostsData(): array
    {
        return [
            ['id' => 1, 'title' => 'Introduction à Symfony', 'content' => 'Découvrez les bases de Symfony...', 'author' => 'John Doe', 'created_at' => '2024-01-01'],
            ['id' => 2, 'title' => 'Next.js et React', 'content' => 'Guide complet sur Next.js...', 'author' => 'Jane Smith', 'created_at' => '2024-01-02'],
            ['id' => 3, 'title' => 'Docker pour les développeurs', 'content' => 'Maîtrisez Docker...', 'author' => 'Bob Johnson', 'created_at' => '2024-01-03'],
            ['id' => 4, 'title' => 'TypeScript Best Practices', 'content' => 'Meilleures pratiques TypeScript...', 'author' => 'Alice Brown', 'created_at' => '2024-01-04'],
            ['id' => 5, 'title' => 'API REST avec Symfony', 'content' => 'Créer des APIs performantes...', 'author' => 'Charlie Davis', 'created_at' => '2024-01-05'],
        ];
    }
}

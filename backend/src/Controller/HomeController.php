<?php

namespace App\Controller;

use Doctrine\DBAL\Connection;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class HomeController extends AbstractController
{
    public function __construct(
        private Connection $connection
    ) {
    }
    #[Route('/', name: 'app_home')]
    public function index(): Response
    {
        return new Response('
            <html>
                <head>
                    <title>Symfony + Next.js App</title>
                    <style>
                        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
                        .container { max-width: 600px; margin: 0 auto; }
                        .success { color: #28a745; }
                        .info { color: #17a2b8; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <h1 class="success">🎉 Symfony est configuré !</h1>
                        <p class="info">Votre application Symfony fonctionne correctement.</p>
                        <p><strong>Version:</strong> ' . \Symfony\Component\HttpKernel\Kernel::VERSION . '</p>
                        <p><strong>Environnement:</strong> ' . $this->getParameter('kernel.environment') . '</p>
                        <hr>
                        <p>🚀 <a href="http://localhost:3000" target="_blank">Accéder à Next.js (Port 3000)</a></p>
                        <p>📊 <a href="/api/health" target="_blank">API Health Check</a></p>
                    </div>
                </body>
            </html>
        ');
    }

    #[Route('/api/health', name: 'api_health')]
    public function health(): JsonResponse
    {
        return $this->json([
            'status' => 'ok',
            'timestamp' => new \DateTime(),
            'symfony_version' => \Symfony\Component\HttpKernel\Kernel::VERSION,
            'php_version' => PHP_VERSION,
            'environment' => $this->getParameter('kernel.environment'),
            'database' => $this->checkDatabase()
        ]);
    }

    private function checkDatabase(): array
    {
        try {
            $this->connection->connect();
            return [
                'status' => 'connected',
                'driver' => $this->connection->getDriver()->getName()
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }
}

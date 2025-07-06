<?php

namespace App\EventListener;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Event\ResponseEvent;
use Symfony\Component\HttpKernel\Event\RequestEvent;

class CorsListener
{
    public function onKernelRequest(RequestEvent $event): void
    {
        // Don't do anything if it's not the main request.
        if (!$event->isMainRequest()) {
            return;
        }

        $request = $event->getRequest();
        $method = $request->getRealMethod();

        if ($method === 'OPTIONS') {
            $response = new Response();
            $event->setResponse($response);
        }
    }

    public function onKernelResponse(ResponseEvent $event): void
    {
        // Don't do anything if it's not the main request.
        if (!$event->isMainRequest()) {
            return;
        }

        $response = $event->getResponse();
        $request = $event->getRequest();

        // Add CORS headers
        $response->headers->set('Access-Control-Allow-Origin', '*');
        $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
        $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
        $response->headers->set('Access-Control-Max-Age', '86400');

        if ($request->getRealMethod() === 'OPTIONS') {
            $response->setStatusCode(200);
        }
    }
}

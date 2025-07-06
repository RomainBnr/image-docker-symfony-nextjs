/** @type {import('next').NextConfig} */
const nextConfig = {
  // Mode strict pour React
  reactStrictMode: true,
  
  // Désactiver la télémétrie
  telemetry: {
    disabled: true,
  },
  
  // Optimisation des images
  images: {
    formats: ['image/avif', 'image/webp'],
    dangerouslyAllowSVG: true,
    contentDispositionType: 'attachment',
    contentSecurityPolicy: "default-src 'self'; script-src 'none'; sandbox;",
  },
  
  // Configuration experimentale pour de meilleures performances
  experimental: {
    // Optimisation des bundles
    optimizeCss: true,
  },
  
  // Optimisation du build
  compiler: {
    // Supprime console.log en production
    removeConsole: process.env.NODE_ENV === 'production',
  },
  
  // Headers de sécurité
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'origin-when-cross-origin',
          },
          {
            key: 'Permissions-Policy',
            value: 'camera=(), microphone=(), geolocation=()',
          },
        ],
      },
    ];
  },
  
  // Configuration des rewrites pour l'API
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: process.env.NODE_ENV === 'production' 
          ? 'http://nginx/api/:path*'
          : 'http://localhost/api/:path*',
      },
    ];
  },
  
  // Cache des pages statiques
  async redirects() {
    return [];
  },
  
  // Configuration du bundling
  webpack: (config, { dev, isServer }) => {
    // Optimisations pour la production
    if (!dev && !isServer) {
      // Optimisation des chunks
      config.optimization = {
        ...config.optimization,
        splitChunks: {
          chunks: 'all',
          cacheGroups: {
            vendor: {
              test: /[\\/]node_modules[\\/]/,
              name: 'vendors',
              chunks: 'all',
            },
          },
        },
      };
    }
    
    return config;
  },
  
  // Output standalone pour Docker
  output: 'standalone',
  
  // Optimisation des polyfills
  env: {
    CUSTOM_KEY: process.env.CUSTOM_KEY || 'default-value',
  },
}

module.exports = nextConfig

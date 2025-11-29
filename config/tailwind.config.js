const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        'scrollbar-bg': '#f1f1f1',
        'scrollbar-thumb': '#888',
        'scrollbar-thumb-hover': '#555',
        // SSGrip Custom Dark Grey & Silver Theme
        'ssgrip': {
          'darkest': '#0a0a0b',      // Near black background
          'darker': '#121214',        // Dark grey background
          'dark': '#1a1a1d',          // Medium dark grey
          'base': '#2a2a2e',          // Base grey
          'light': '#3a3a3f',         // Light grey
          'lighter': '#4a4a50',       // Lighter grey
          'silver': {
            'dark': '#6b7280',        // Dark silver
            'DEFAULT': '#9ca3af',     // Silver accent
            'light': '#c0c5ce',       // Light silver
            'bright': '#e5e7eb',      // Bright silver
          },
          'accent': {
            'DEFAULT': '#a8b2d1',     // Muted blue-silver
            'bright': '#ccd6f6',      // Bright accent
          }
        },
      },
      animation: {
        'spin-slow': 'spin 20s linear infinite',
        'pulse-glow': 'pulse-glow 2s ease-in-out infinite',
        'progress-fill': 'progress-fill 1s ease-out forwards',
      },
      keyframes: {
        'pulse-glow': {
          '0%, 100%': { 
            opacity: '1',
            transform: 'scale(1)',
          },
          '50%': { 
            opacity: '0.5',
            transform: 'scale(1.05)',
          },
        },
        'progress-fill': {
          '0%': { 
            width: '0%',
          },
          '100%': { 
            width: 'var(--progress-width)',
          },
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
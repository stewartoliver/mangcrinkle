module.exports = {
    content: [
        './app/views/**/*.erb',
        './app/helpers/**/*.rb',
        './app/assets/stylesheets/**/*.css',
        './app/javascript/**/*.js'
    ],
    theme: {
        extend: {
            fontFamily: {
                'cooper': ['Cooper Black', 'serif'],
                'rubik': ['Rubik', 'sans-serif'],
                'sans': ['Rubik', 'sans-serif'],
            },
        },
    },
    plugins: [],
} 
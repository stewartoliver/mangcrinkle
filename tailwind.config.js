module.exports = {
    content: [
        './app/views/**/*.html.erb',
        './app/helpers/**/*.rb',
        './app/assets/stylesheets/**/*.css',
        './app/assets/tailwind/**/*.css',
        './app/javascript/**/*.js',
        './app/controllers/**/*.rb'
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
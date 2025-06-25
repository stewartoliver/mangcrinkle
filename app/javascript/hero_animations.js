// Hero Animations JavaScript - Clean Version
class HeroAnimations {
    constructor(containerSelector = '.hero-container') {
        this.containerSelector = containerSelector;
        this.heroContainer = null;
        this.observer = null;
        this.animationActive = false;
        this.crinkleInterval = null;
        this.maxCrinkles = 25;
        this.activeCrinklePositions = [];
        this.crinkleImage = null;

        this.init();
    }

    init() {
        // Preload crinkle SVG for better performance
        this.crinkleImage = new Image();
        this.crinkleImage.src = '/assets/crinkle.svg';

        // Initialize on current page
        this.setupHeroContainer();

        // Listen for navigation events
        ['turbo:load', 'turbo:render', 'DOMContentLoaded'].forEach(event => {
            document.addEventListener(event, () => this.setupHeroContainer());
        });
    }

    setupHeroContainer() {
        this.cleanup();

        this.heroContainer = document.querySelector(this.containerSelector);
        if (!this.heroContainer) return;

        this.setupIntersectionObserver();

        if (this.isInViewport()) {
            this.startCrinkleAnimation();
        }
    }

    setupIntersectionObserver() {
        if (this.observer) {
            this.observer.disconnect();
        }

        this.observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('in-viewport');
                    this.startCrinkleAnimation();
                } else {
                    entry.target.classList.remove('in-viewport');
                    this.pauseCrinkleAnimation();
                }
            });
        }, { threshold: 0.1 });

        this.observer.observe(this.heroContainer);
    }

    isInViewport() {
        if (!this.heroContainer) return false;
        const rect = this.heroContainer.getBoundingClientRect();
        return (
            rect.top >= 0 &&
            rect.left >= 0 &&
            rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
            rect.right <= (window.innerWidth || document.documentElement.clientWidth)
        );
    }

    findGoodPosition() {
        const minDistance = 12;
        let attempts = 0;
        let left;

        do {
            left = Math.random() * 90 + 5;
            attempts++;
        } while (
            this.activeCrinklePositions.some(pos => Math.abs(pos - left) < minDistance) &&
            attempts < 10
        );

        this.activeCrinklePositions.push(left);
        return left;
    }

    createFallingCrinkle() {
        if (!this.animationActive || !this.heroContainer) return;

        const existingCrinkles = this.heroContainer.querySelectorAll('.falling-crinkle.dynamic');
        if (existingCrinkles.length >= this.maxCrinkles) return;

        const crinkle = document.createElement('div');
        crinkle.className = 'falling-crinkle dynamic';

        const left = this.findGoodPosition();
        const speedVariants = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
        const duration = speedVariants[Math.floor(Math.random() * speedVariants.length)];
        const delay = Math.random() * 2;

        // Add floating animation for some crinkles
        if (Math.random() > 0.7) {
            crinkle.classList.add('float');
        }

        // Apply rotation and flipping variations
        const rotation = Math.random() * 360;
        const isFlipped = Math.random() > 0.5;
        const isFlippedVertically = Math.random() > 0.5;

        let transform = `rotate(${rotation}deg)`;
        if (isFlipped) transform += ' scaleX(-1)';
        if (isFlippedVertically) transform += ' scaleY(-1)';

        // Apply styles
        Object.assign(crinkle.style, {
            left: `${left}%`,
            top: '-60px',
            animationDuration: `${duration}s`,
            animationDelay: `${delay}s`,
            position: 'absolute',
            transform: transform
        });

        // Create and append image
        const img = document.createElement('img');
        img.src = this.crinkleImage.src;
        img.alt = 'Falling Crinkle';
        Object.assign(img.style, {
            width: '100%',
            height: '100%'
        });

        crinkle.appendChild(img);
        this.heroContainer.appendChild(crinkle);

        // Remove crinkle after animation completes
        setTimeout(() => {
            if (crinkle.parentNode) {
                crinkle.parentNode.removeChild(crinkle);
                const index = this.activeCrinklePositions.indexOf(left);
                if (index > -1) {
                    this.activeCrinklePositions.splice(index, 1);
                }
            }
        }, (duration + delay) * 1000);
    }

    startCrinkleAnimation() {
        if (this.animationActive) return;

        this.animationActive = true;

        // Create initial batch
        for (let i = 0; i < 3; i++) {
            setTimeout(() => this.createFallingCrinkle(), i * 1200);
        }

        // Continue creating crinkles
        this.crinkleInterval = setInterval(() => {
            this.createFallingCrinkle();
        }, 2000 + Math.random() * 1000);
    }

    pauseCrinkleAnimation() {
        this.animationActive = false;

        if (this.crinkleInterval) {
            clearInterval(this.crinkleInterval);
            this.crinkleInterval = null;
        }

        // Remove all crinkles
        if (this.heroContainer) {
            this.heroContainer.querySelectorAll('.falling-crinkle.dynamic').forEach(crinkle => {
                if (crinkle.parentNode) {
                    crinkle.parentNode.removeChild(crinkle);
                }
            });
        }

        this.activeCrinklePositions = [];
    }

    cleanup() {
        this.pauseCrinkleAnimation();

        if (this.observer) {
            this.observer.disconnect();
            this.observer = null;
        }

        this.heroContainer = null;
    }
}

// Initialize hero animations
let heroAnimations = null;

function initializeHeroAnimations(containerSelector = '.hero-container') {
    if (heroAnimations) {
        heroAnimations.cleanup();
    }

    // Check for reduced motion preference
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
        return;
    }

    heroAnimations = new HeroAnimations(containerSelector);
}

// Initialize on page load and navigation
['DOMContentLoaded', 'turbo:load'].forEach(event => {
    document.addEventListener(event, () => initializeHeroAnimations());
});

// Make it available globally for other pages
window.initializeHeroAnimations = initializeHeroAnimations; 
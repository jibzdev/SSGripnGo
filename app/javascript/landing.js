// RK Customs Website JavaScript

const hasGsap = typeof window !== 'undefined' && typeof window.gsap !== 'undefined';
const gsapInstance = hasGsap ? window.gsap : null;

if (hasGsap && window.ScrollTrigger && window.TextPlugin) {
    gsapInstance.registerPlugin(window.ScrollTrigger, window.TextPlugin);
}

let mobileNavInitAttempts = 0;
let mobileNavInitialized = false;

// Initialize mobile navigation as soon as possible
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initMobileNav);
} else {
    initMobileNav();
}

document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM loaded, starting initialization...');
    
    // Initialize mobile navigation IMMEDIATELY - no delays
    initMobileNav();
    
    // Initialize hero video
    initHeroVideo();
    
    // Initialize particles
    initHeroParticles();
    
    // Initialize text animations
    initHeroTextAnimation();
    
    // Initialize navbar scroll
    initNavbarScroll();
    
    // Initialize AOS animations
    initAOSAnimations();
});

// Ensure initialization on Turbo-driven navigations
document.addEventListener('turbo:load', function() {
    try { initMobileNav(); } catch (_) {}
    try { initNavbarScroll(); } catch (_) {}
});

// Hero Video Management - Use existing MP4 file
function initHeroVideo() {
    const heroVideo = document.getElementById('hero-video');
    if (!heroVideo) return;
    
    // Remove any existing static background
    const existingStaticBg = heroVideo.parentElement.querySelector('.static-background');
    if (existingStaticBg) {
        existingStaticBg.remove();
    }
    
    // Show the video element
    heroVideo.style.display = 'block';
    
    // Set a global flag to prevent multiple initializations
    if (window.heroVideoInitialized) {
        console.log('Video already initialized');
        return;
    }
    window.heroVideoInitialized = true;
    
    // Remove any existing source elements
    const existingSources = heroVideo.querySelectorAll('source');
    existingSources.forEach(source => source.remove());
    
    // Use an existing MP4 file that should work better
    const source = document.createElement('source');
    source.src = '/assets/videos/1080p.mp4'; // Use existing MP4 file
    source.type = 'video/mp4';
    heroVideo.appendChild(source);
    
    // Set properties programmatically
    heroVideo.muted = true;
    heroVideo.loop = true;
    heroVideo.playsInline = true;
    heroVideo.preload = 'metadata';
    
    let videoLoaded = false;
    let videoStarted = false;
    
    // Event listeners
    heroVideo.addEventListener('loadstart', () => {
        console.log('1080p.mp4 loading started');
    });
    
    heroVideo.addEventListener('loadedmetadata', () => {
        console.log('1080p.mp4 metadata loaded');
    });
    
    heroVideo.addEventListener('canplay', () => {
        if (videoLoaded) return;
        videoLoaded = true;
        console.log('1080p.mp4 can play');
        
        // Only start playing if video is visible
        if (isElementVisible(heroVideo)) {
            startVideo();
        }
    });
    
    heroVideo.addEventListener('error', (e) => {
        console.error('1080p.mp4 error:', e);
        console.log('Video failed, using static background');
        heroVideo.style.display = 'none';
        const videoContainer = heroVideo.parentElement;
        if (videoContainer) {
            const staticBackground = document.createElement('div');
            staticBackground.className = 'static-background';
            staticBackground.style.cssText = `
                position: absolute;
                inset: 0;
                width: 100%;
                height: 100%;
                background-image: url('/assets/images/showcase1.jpg');
                background-size: cover;
                background-position: center;
                background-repeat: no-repeat;
                z-index: 0;
            `;
            videoContainer.appendChild(staticBackground);
        }
    });
    
    // Function to check if element is visible
    function isElementVisible(element) {
        const rect = element.getBoundingClientRect();
        return rect.top < window.innerHeight && rect.bottom > 0;
    }
    
    // Function to start video
    function startVideo() {
        if (videoStarted) return;
        videoStarted = true;
        
        heroVideo.play().catch(error => {
            console.warn('Auto-play prevented:', error);
        });
    }
    
    // Intersection observer for performance - only load video when visible
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                if (videoLoaded && !videoStarted) {
                    startVideo();
                } else if (videoLoaded && heroVideo.paused) {
                    heroVideo.play().catch(() => {});
                }
            } else {
                if (!heroVideo.paused) {
                    heroVideo.pause();
                }
            }
        });
    }, { threshold: 0.1 });
    
    observer.observe(heroVideo);
    
    // Load only metadata initially
    heroVideo.load();
    
    // Prevent any external reloads by overriding the load method
    const originalLoad = heroVideo.load.bind(heroVideo);
    heroVideo.load = function() {
        if (videoLoaded) {
            console.log('Preventing video reload - already loaded');
            return;
        }
        originalLoad();
    };
}

// Hero Section Particles Animation
function initHeroParticles() {
    const heroCanvas = document.getElementById('hero-particles');
    if (!heroCanvas) return;
    
    const heroCtx = heroCanvas.getContext('2d');
    
    function resizeCanvas() {
        heroCanvas.width = window.innerWidth;
        heroCanvas.height = window.innerHeight;
    }
    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);
    
    const heroParticles = [];
    const shapes = ['circle', 'square', 'triangle'];
    
    // Create particles
    for(let i = 0; i < 8; i++) {
        heroParticles.push({
            x: Math.random() * heroCanvas.width,
            y: Math.random() * heroCanvas.height,
            size: Math.random() * 30 + 20,
            shape: shapes[Math.floor(Math.random() * shapes.length)],
            speedX: (Math.random() - 0.5) * 0.3,
            speedY: (Math.random() - 0.5) * 0.3,
            rotation: Math.random() * 360,
            rotationSpeed: (Math.random() - 0.5) * 0.3
        });
    }

    // Particle animation
    function drawShape(x, y, size, shape, rotation) {
        heroCtx.save();
        heroCtx.translate(x, y);
        heroCtx.rotate(rotation * Math.PI / 180);
        heroCtx.fillStyle = 'rgba(250, 204, 21, 0.1)';
        
        switch(shape) {
            case 'circle':
                heroCtx.beginPath();
                heroCtx.arc(0, 0, size/2, 0, Math.PI * 2);
                heroCtx.fill();
                break;
            case 'square':
                heroCtx.fillRect(-size/2, -size/2, size, size);
                break;
            case 'triangle':
                heroCtx.beginPath();
                heroCtx.moveTo(0, -size/2);
                heroCtx.lineTo(size/2, size/2);
                heroCtx.lineTo(-size/2, size/2);
                heroCtx.closePath();
                heroCtx.fill();
                break;
        }
        heroCtx.restore();
    }
    
    function animateHeroParticles() {
        heroCtx.clearRect(0, 0, heroCanvas.width, heroCanvas.height);
        
        heroParticles.forEach(particle => {
            particle.x += particle.speedX;
            particle.y += particle.speedY;
            particle.rotation += particle.rotationSpeed;
            
            if(particle.x < 0 || particle.x > heroCanvas.width) particle.speedX *= -1;
            if(particle.y < 0 || particle.y > heroCanvas.height) particle.speedY *= -1;
            
            drawShape(particle.x, particle.y, particle.size, particle.shape, particle.rotation);
        });
        
        requestAnimationFrame(animateHeroParticles);
    }
    
    animateHeroParticles();
}

// Hero Section Text Animation
function initHeroTextAnimation() {
    if (!hasGsap) return;
    const textItems = document.querySelectorAll('.hero-text-item');
    if (textItems.length === 0) return;
    
    let currentTextIndex = 0;
    let usedIndices = new Set();
    
    function getNextTextIndex() {
        if (usedIndices.size === textItems.length) {
            usedIndices.clear();
        }
        let nextIndex;
        do {
            nextIndex = Math.floor(Math.random() * textItems.length);
        } while (usedIndices.has(nextIndex));
        usedIndices.add(nextIndex);
        return nextIndex;
    }
    
    function animateHeroText() {
        gsapInstance.to(textItems[currentTextIndex], {
            opacity: 0,
            y: 10,
            duration: 0.3,
            onComplete: () => {
                currentTextIndex = getNextTextIndex();
                gsapInstance.to(textItems[currentTextIndex], {
                    opacity: 1,
                    y: 0,
                    duration: 0.3
                });
            }
        });
    }

    // Initial text setup
    gsapInstance.set(textItems[0], { opacity: 1, y: 0 });
    usedIndices.add(0);
    setInterval(animateHeroText, 2000);
}

// Navbar scroll behavior
function initNavbarScroll() {
    const navbar = document.getElementById('navbar');
    if (!navbar) return;

    if (!hasGsap) {
        window.addEventListener('scroll', () => {
            if (window.pageYOffset > 10) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        });
        return;
    }

    let lastScroll = 0;
    let ticking = false;
    let isAnimating = false;

    navbar.style.background = 'transparent';
    navbar.style.backdropFilter = 'none';

    window.addEventListener('scroll', () => {
        if (ticking) return;

        window.requestAnimationFrame(() => {
            const currentScroll = window.pageYOffset;

            if (currentScroll <= 0) {
                if (!isAnimating) {
                    isAnimating = true;
                    gsapInstance.to(navbar, {
                        y: 0,
                        background: 'transparent',
                        backdropFilter: 'none',
                        duration: 0.15,
                        ease: 'power2.out',
                        onComplete: () => {
                            navbar.classList.remove('scrolled', 'nav-hidden');
                            isAnimating = false;
                        }
                    });
                }
            } else if (currentScroll > lastScroll && currentScroll > 30) {
                if (!isAnimating && !navbar.classList.contains('nav-hidden')) {
                    isAnimating = true;
                    gsapInstance.to(navbar, {
                        y: -100,
                        background: 'rgba(0, 0, 0, 0.8)',
                        backdropFilter: 'blur(20px)',
                        duration: 0.05,
                        ease: 'power2.in',
                        onComplete: () => {
                            navbar.classList.add('nav-hidden', 'scrolled');
                            isAnimating = false;
                        }
                    });
                }
            } else if (currentScroll < lastScroll) {
                if (!isAnimating && navbar.classList.contains('nav-hidden')) {
                    isAnimating = true;
                    gsapInstance.to(navbar, {
                        y: 0,
                        background: 'rgba(0, 0, 0, 0.8)',
                        backdropFilter: 'blur(20px)',
                        duration: 0.05,
                        ease: 'power2.out',
                        onComplete: () => {
                            navbar.classList.remove('nav-hidden');
                            navbar.classList.add('scrolled');
                            isAnimating = false;
                        }
                    });
                }
            }

            lastScroll = currentScroll;
            ticking = false;
        });

        ticking = true;
    });
}

// Mobile Navigation
function initMobileNav() {
    if (mobileNavInitialized) return;

    const mobileMenuBtn = document.getElementById('mobile-menu-btn');
    const mobileSidebar = document.getElementById('mobile-sidebar');
    const sidebarOverlay = document.getElementById('sidebar-overlay');
    const closeSidebarBtn = document.getElementById('close-sidebar');
    let isOpen = false;

    if (!mobileMenuBtn || !mobileSidebar || !sidebarOverlay || !closeSidebarBtn) {
        if (mobileNavInitAttempts < 5) {
            mobileNavInitAttempts += 1;
            setTimeout(initMobileNav, 150);
        }
        return;
    }
    mobileNavInitAttempts = 0;
    mobileNavInitialized = true;

    function openSidebar() {
        isOpen = true;
        
        // Store scroll position before opening
        const scrollY = window.pageYOffset || document.documentElement.scrollTop;
        
        sidebarOverlay.style.pointerEvents = 'auto';
        sidebarOverlay.style.opacity = '1';

        if (hasGsap) {
            gsapInstance.to(mobileSidebar, {
                x: 0,
                duration: 0.3,
                ease: 'power2.out',
                onComplete: () => {
                    const menuItems = mobileSidebar.querySelectorAll('nav a');
                    gsapInstance.fromTo(menuItems, 
                        { opacity: 0, x: 20 },
                        { 
                            opacity: 1, 
                            x: 0, 
                            duration: 0.3, 
                            stagger: 0.05, 
                            ease: 'power2.out' 
                        }
                    );
                }
            });
        } else {
            mobileSidebar.style.transform = 'translateX(0)';
        }

        const lines = mobileMenuBtn.querySelectorAll('span');
        lines.forEach(line => line.style.backgroundColor = '#fbbf24');
        
        // Prevent scroll jump - alternative approach
        document.body.style.overflow = 'hidden';
        document.body.style.position = 'fixed';
        document.body.style.top = `-${scrollY}px`;
        document.body.style.left = '0';
        document.body.style.right = '0';
        document.body.style.width = '100%';
        document.body.classList.add('sidebar-open');
        
        // Store scroll position for restoration
        document.body.dataset.scrollY = scrollY.toString();
    }

    function closeSidebar() {
        isOpen = false;
        
        if (hasGsap) {
            gsapInstance.to(sidebarOverlay, {
                opacity: 0,
                duration: 0.2,
                ease: 'power2.in',
                onComplete: () => {
                    sidebarOverlay.style.pointerEvents = 'none';
                }
            });
    
            gsapInstance.to(mobileSidebar, {
                x: '100%',
                duration: 0.3,
                ease: 'power2.in'
            });
        } else {
            sidebarOverlay.style.opacity = '0';
            sidebarOverlay.style.pointerEvents = 'none';
            mobileSidebar.style.transform = 'translateX(100%)';
        }

        const lines = mobileMenuBtn.querySelectorAll('span');
        lines.forEach(line => line.style.backgroundColor = '#ffffff');
        
        // Restore scroll position - alternative approach
        const scrollY = parseInt(document.body.dataset.scrollY || '0');
        document.body.style.position = '';
        document.body.style.top = '';
        document.body.style.left = '';
        document.body.style.right = '';
        document.body.style.width = '';
        document.body.style.overflow = '';
        document.body.classList.remove('sidebar-open');
        delete document.body.dataset.scrollY;
        
        // Restore scroll position with requestAnimationFrame for better timing
        requestAnimationFrame(() => {
            window.scrollTo(0, scrollY);
        });
    }

    function toggleSidebar() {
        if (isOpen) {
            closeSidebar();
        } else {
            openSidebar();
        }
    }

    // Event listeners
    mobileMenuBtn.addEventListener('click', toggleSidebar);
    closeSidebarBtn.addEventListener('click', closeSidebar);
    sidebarOverlay.addEventListener('click', closeSidebar);

    const menuItems = mobileSidebar.querySelectorAll('a');
    menuItems.forEach(item => {
        item.addEventListener('click', () => {
            if (isOpen) {
                closeSidebar();
            }
        });
    });

    window.addEventListener('resize', () => {
        if (window.innerWidth > 1024 && isOpen) {
            closeSidebar();
        }
    });

    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && isOpen) {
            closeSidebar();
        }
    });

    // Touch gesture support
    let touchStartX = 0;
    let touchEndX = 0;

    mobileSidebar.addEventListener('touchstart', (e) => {
        touchStartX = e.changedTouches[0].screenX;
    });

    mobileSidebar.addEventListener('touchend', (e) => {
        touchEndX = e.changedTouches[0].screenX;
        handleSwipe();
    });

    function handleSwipe() {
        const swipeThreshold = 30; // Reduced threshold for faster response
        const swipeDistance = touchEndX - touchStartX;
        
        if (swipeDistance > swipeThreshold && isOpen) {
            closeSidebar();
        }
    }
}

// AOS-like animations for service section
function initAOSAnimations() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('aos-animate');
            }
        });
    }, observerOptions);
    
    const aosElements = document.querySelectorAll('[data-aos]');
    aosElements.forEach(element => {
        observer.observe(element);
    });
}

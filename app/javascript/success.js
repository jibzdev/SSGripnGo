// RK Customs Success Page JavaScript

// Register GSAP plugins
if (typeof gsap !== 'undefined') {
    gsap.registerPlugin(ScrollTrigger, TextPlugin);
}

// Initialize mobile navigation as soon as possible
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initMobileNav);
} else {
    // DOM is already loaded
    initMobileNav();
}

document.addEventListener('DOMContentLoaded', function() {
    // Initialize mobile navigation IMMEDIATELY - no delays
    initMobileNav();
    
    // Initialize navbar scroll
    initNavbarScroll();
});

// Mobile Navigation
function initMobileNav() {
    const mobileMenuBtn = document.getElementById('mobile-menu-btn');
    const mobileSidebar = document.getElementById('mobile-sidebar');
    const sidebarOverlay = document.getElementById('sidebar-overlay');
    const closeSidebarBtn = document.getElementById('close-sidebar');
    let isOpen = false;

    if (!mobileMenuBtn || !mobileSidebar || !sidebarOverlay) {
        console.log('Mobile nav elements not found, retrying...');
        // Retry after a short delay if elements aren't ready
        setTimeout(initMobileNav, 100);
        return;
    }

    function openSidebar() {
        isOpen = true;
        
        // Store scroll position before opening
        const scrollY = window.pageYOffset || document.documentElement.scrollTop;
        
        // Instant overlay - no delay
        sidebarOverlay.style.pointerEvents = 'auto';
        sidebarOverlay.style.opacity = '1';
        
        // Smooth sidebar slide
        if (typeof gsap !== 'undefined') {
            gsap.to(mobileSidebar, {
                x: 0,
                duration: 0.3,
                ease: 'power2.out',
                onComplete: () => {
                    // Animate menu items after sidebar opens
                    const menuItems = mobileSidebar.querySelectorAll('nav a');
                    gsap.fromTo(menuItems, 
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
            
            // Smooth hamburger color change
            const lines = mobileMenuBtn.querySelectorAll('span');
            gsap.to(lines, {
                backgroundColor: '#fbbf24',
                duration: 0.2,
                ease: 'power2.out'
            });
        } else {
            // Fallback without GSAP
            mobileSidebar.classList.remove('translate-x-full');
        }
        
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
        
        if (typeof gsap !== 'undefined') {
            // Smooth overlay hide
            gsap.to(sidebarOverlay, {
                opacity: 0,
                duration: 0.2,
                ease: 'power2.in',
                onComplete: () => {
                    sidebarOverlay.style.pointerEvents = 'none';
                }
            });
            
            // Smooth sidebar slide back
            gsap.to(mobileSidebar, {
                x: '100%',
                duration: 0.3,
                ease: 'power2.in'
            });
            
            // Smooth hamburger color reset
            const lines = mobileMenuBtn.querySelectorAll('span');
            gsap.to(lines, {
                backgroundColor: '#ffffff',
                duration: 0.2,
                ease: 'power2.out'
            });
        } else {
            // Fallback without GSAP
            sidebarOverlay.style.opacity = '0';
            sidebarOverlay.style.pointerEvents = 'none';
            mobileSidebar.classList.add('translate-x-full');
        }
        
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
        const swipeThreshold = 50;
        const swipeDistance = touchEndX - touchStartX;
        
        if (swipeDistance > swipeThreshold && isOpen) {
            closeSidebar();
        }
    }
}

// Navbar Scroll Effect
function initNavbarScroll() {
    const navbar = document.getElementById('navbar');
    if (!navbar) return;

    let lastScrollY = window.scrollY;
    let ticking = false;

    function updateNavbar() {
        const scrollY = window.scrollY;
        
        if (scrollY > 100) {
            navbar.style.backgroundColor = 'rgba(0, 0, 0, 0.95)';
            navbar.style.backdropFilter = 'blur(20px)';
        } else {
            navbar.style.backgroundColor = 'transparent';
            navbar.style.backdropFilter = 'blur(10px)';
        }
        
        lastScrollY = scrollY;
        ticking = false;
    }

    function requestTick() {
        if (!ticking) {
            requestAnimationFrame(updateNavbar);
            ticking = true;
        }
    }

    window.addEventListener('scroll', requestTick);
}

// Success page specific animations
document.addEventListener('DOMContentLoaded', function() {
    // Animate success icon
    const successIcon = document.querySelector('.w-20.h-20');
    if (successIcon && typeof gsap !== 'undefined') {
        gsap.fromTo(successIcon, 
            { scale: 0, rotation: -180 },
            { 
                scale: 1, 
                rotation: 0, 
                duration: 0.8, 
                ease: 'back.out(1.7)' 
            }
        );
    }

    // Animate booking details cards
    const bookingCards = document.querySelectorAll('.bg-zinc-800\\/40');
    if (bookingCards.length > 0 && typeof gsap !== 'undefined') {
        gsap.fromTo(bookingCards, 
            { opacity: 0, y: 30 },
            { 
                opacity: 1, 
                y: 0, 
                duration: 0.6, 
                stagger: 0.1, 
                ease: 'power2.out',
                delay: 0.3
            }
        );
    }

    // Animate action buttons
    const actionButtons = document.querySelectorAll('.group.bg-gradient-to-br');
    if (actionButtons.length > 0 && typeof gsap !== 'undefined') {
        gsap.fromTo(actionButtons, 
            { opacity: 0, scale: 0.9 },
            { 
                opacity: 1, 
                scale: 1, 
                duration: 0.5, 
                stagger: 0.1, 
                ease: 'power2.out',
                delay: 0.6
            }
        );
    }
});


// Dashboard-specific interactions (mobile sidebar + theme toggle)
(function() {
  function initSidebar() {
    const sidebar = document.getElementById('sidebar');
    const menuToggle = document.getElementById('menuToggle');
    const backdrop = document.getElementById('sidebarBackdrop');
    if (!(sidebar && menuToggle && backdrop)) return;

    if (!menuToggle.dataset.sidebarInit) {
      menuToggle.dataset.sidebarInit = 'true';
      menuToggle.addEventListener('click', function() {
        sidebar.classList.toggle('-translate-x-full');
        backdrop.classList.toggle('opacity-0');
        backdrop.classList.toggle('hidden');
      });

      backdrop.addEventListener('click', function() {
        sidebar.classList.add('-translate-x-full');
        backdrop.classList.add('opacity-0', 'hidden');
      });

      document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape' && !sidebar.classList.contains('-translate-x-full')) {
          sidebar.classList.add('-translate-x-full');
          backdrop.classList.add('opacity-0', 'hidden');
        }
      });

      document.addEventListener('click', function(event) {
        if (window.innerWidth >= 1024) return;
        if (sidebar.classList.contains('-translate-x-full')) return;
        if (
          sidebar.contains(event.target) ||
          menuToggle.contains(event.target) ||
          backdrop.contains(event.target)
        ) {
          return;
        }
        sidebar.classList.add('-translate-x-full');
        backdrop.classList.add('opacity-0', 'hidden');
      });
    }
  }

  function initThemeToggle() {
    const themeToggle = document.getElementById('themeToggle');
    if (!themeToggle || themeToggle.dataset.themeInit) return;

    themeToggle.dataset.themeInit = 'true';
    themeToggle.addEventListener('click', function() {
      const html = document.documentElement;
      const isDark = html.classList.contains('dark');
      if (isDark) {
        html.classList.remove('dark');
        localStorage.setItem('darkMode', 'false');
      } else {
        html.classList.add('dark');
        localStorage.setItem('darkMode', 'true');
      }
    });
  }

  function initDashboardChrome() {
    initSidebar();
    initThemeToggle();
  }

  document.addEventListener('DOMContentLoaded', initDashboardChrome);
  document.addEventListener('turbo:load', initDashboardChrome);
})();

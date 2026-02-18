(function () {
  'use strict';

  const SUPPORTED_LOCALES = {
    en: { label: 'العربية', switchTo: 'ar' },
    ar: { label: 'English', switchTo: 'en' }
  };

  const STORAGE_KEY = 'qawam_lang';
  const DEFAULT_LOCALE = 'en';

  // --- Utility Helpers ---

  function qs(selector, parent = document) {
    return parent.querySelector(selector);
  }

  function qsa(selector, parent = document) {
    return parent.querySelectorAll(selector);
  }

  function createEl(tag, attrs = {}, html = '') {
    const el = document.createElement(tag);
    Object.entries(attrs).forEach(([key, value]) => {
      if (key === 'className') el.className = value;
      else if (key === 'ariaLabel') el.setAttribute('aria-label', value);
      else el.setAttribute(key, value);
    });
    if (html) el.innerHTML = html;
    return el;
  }

  function clearChildren(el) {
    while (el.firstChild) el.removeChild(el.firstChild);
  }

  function getSavedLocale() {
    try {
      const saved = localStorage.getItem(STORAGE_KEY);
      if (saved && SUPPORTED_LOCALES[saved]) return saved;
    } catch (_) { /* localStorage unavailable */ }
    return null;
  }

  function saveLocale(locale) {
    try { localStorage.setItem(STORAGE_KEY, locale); } catch (_) { /* noop */ }
  }

  function detectLocale() {
    const saved = getSavedLocale();
    if (saved) return saved;

    const urlParams = new URLSearchParams(window.location.search);
    const urlLang = urlParams.get('lang');
    if (urlLang && SUPPORTED_LOCALES[urlLang]) return urlLang;

    const browserLang = (navigator.language || '').split('-')[0];
    if (SUPPORTED_LOCALES[browserLang]) return browserLang;

    return DEFAULT_LOCALE;
  }

  // --- SVG Icons ---

  const STORE_ICONS = {
    'google-play': `<svg viewBox="0 0 24 24" width="28" height="28" fill="none">
      <path d="M3.61 1.814L13.793 12 3.61 22.186a1.005 1.005 0 01-.61-.92V2.734c0-.385.222-.72.61-.92z" fill="#4285F4"/>
      <path d="M17.219 8.382L5.05.866C4.553.582 4.003.553 3.61 1.814L13.793 12l3.426-3.618z" fill="#EA4335"/>
      <path d="M3.61 22.186c.393 1.261.943 1.232 1.44.948l12.169-7.516L13.793 12 3.61 22.186z" fill="#34A853"/>
      <path d="M20.997 10.652l-3.778-2.27L13.793 12l3.426 3.618 3.778-2.27c.706-.437.706-2.259 0-2.696z" fill="#FBBC05"/>
    </svg>`,
    'app-store': `<svg viewBox="0 0 24 24" width="28" height="28" fill="currentColor">
      <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
    </svg>`
  };

  const SOCIAL_ICONS = {
    twitter: `<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>`,
    instagram: `<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zM12 0C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 23.986 8.741 24 12 24c3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 100 12.324 6.162 6.162 0 000-12.324zM12 16a4 4 0 110-8 4 4 0 010 8zm6.406-11.845a1.44 1.44 0 100 2.881 1.44 1.44 0 000-2.881z"/></svg>`,
    github: `<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M12 0C5.374 0 0 5.373 0 12c0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23A11.509 11.509 0 0112 5.803c1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576C20.566 21.797 24 17.3 24 12c0-6.627-5.373-12-12-12z"/></svg>`
  };

  // --- Data Loading ---

  async function loadLocale(locale) {
    try {
      const response = await fetch(`locales/${locale}.json`);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return await response.json();
    } catch (err) {
      console.error(`Failed to load locale "${locale}":`, err);
      if (locale !== DEFAULT_LOCALE) {
        console.warn(`Falling back to "${DEFAULT_LOCALE}"`);
        return loadLocale(DEFAULT_LOCALE);
      }
      document.body.innerHTML = '<p style="text-align:center;padding:4rem;color:#666;">Failed to load page content. Please refresh.</p>';
      return null;
    }
  }

  // --- Renderers ---

  function applyDirection(meta) {
    const html = document.documentElement;
    html.setAttribute('lang', meta.language);
    html.setAttribute('dir', meta.dir);
  }

  function renderMeta(meta) {
    document.title = meta.title;
    qs('meta[name="description"]').setAttribute('content', meta.description);
    qs('meta[name="keywords"]').setAttribute('content', meta.keywords);
    qs('meta[property="og:title"]').setAttribute('content', meta.title);
    qs('meta[property="og:description"]').setAttribute('content', meta.description);
    qs('meta[property="og:image"]').setAttribute('content', meta.ogImage);
  }

  function renderBrandName(name) {
    const navBrand = qs('#nav-brand-name');
    const footerBrand = qs('#footer-brand-name');
    if (navBrand) navBrand.textContent = name;
    if (footerBrand) footerBrand.textContent = name;
  }

  function renderNav(nav) {
    const logo = qs('#nav-logo');
    logo.src = nav.logo.src;
    logo.alt = nav.logo.alt;

    const navLinks = qs('#nav-links');
    const mobileLinks = qs('#mobile-nav-links');
    clearChildren(navLinks);
    clearChildren(mobileLinks);

    nav.links.forEach(link => {
      navLinks.appendChild(createEl('li', {}, `<a href="${link.href}">${link.label}</a>`));
      mobileLinks.appendChild(createEl('li', {}, `<a href="${link.href}">${link.label}</a>`));
    });

    const mobileCta = createEl('li', {},
      `<a href="${nav.cta.href}" class="btn btn--primary btn--sm">${nav.cta.label}</a>`
    );
    mobileLinks.appendChild(mobileCta);

    qs('#nav-cta').textContent = nav.cta.label;
    qs('#nav-cta').href = nav.cta.href;
  }

  function renderLangSwitcher(currentLocale) {
    const config = SUPPORTED_LOCALES[currentLocale];
    const label = qs('#lang-label');
    if (label) label.textContent = config.label;
  }

  function renderHero(hero) {
    qs('#hero-badge').textContent = hero.badge;
    qs('#hero-title').innerHTML = hero.title;
    qs('#hero-subtitle').textContent = hero.subtitle;

    const heroLogo = qs('#hero-logo');
    heroLogo.src = hero.logo.src;
    heroLogo.alt = hero.logo.alt;

    const actions = qs('#hero-actions');
    clearChildren(actions);
    actions.appendChild(
      createEl('a', {
        href: hero.cta_primary.href,
        className: 'btn btn--primary'
      }, hero.cta_primary.label)
    );
    actions.appendChild(
      createEl('a', {
        href: hero.cta_secondary.href,
        className: 'btn btn--secondary'
      }, hero.cta_secondary.label)
    );

    const stats = qs('#hero-stats');
    clearChildren(stats);
    hero.stats.forEach(stat => {
      stats.appendChild(createEl('div', { className: 'hero__stat' },
        `<div class="hero__stat-value">${stat.value}</div>
         <div class="hero__stat-label">${stat.label}</div>`
      ));
    });
  }

  function renderFeatures(features) {
    qs('#features-badge').textContent = features.badge;
    qs('#features-title').innerHTML = features.title;
    qs('#features-subtitle').textContent = features.subtitle;

    const grid = qs('#features-grid');
    clearChildren(grid);
    features.items.forEach((item, i) => {
      grid.appendChild(createEl('div', {
        className: `feature-card reveal reveal--delay-${Math.min(i % 3 + 1, 3)}`
      }, `
        <div class="feature-card__icon">${item.icon}</div>
        <h3 class="feature-card__title">${item.title}</h3>
        <p class="feature-card__desc">${item.description}</p>
      `));
    });
  }

  function renderHowItWorks(hiw) {
    qs('#hiw-badge').textContent = hiw.badge;
    qs('#hiw-title').innerHTML = hiw.title;
    qs('#hiw-subtitle').textContent = hiw.subtitle;

    const stepsContainer = qs('#hiw-steps');
    clearChildren(stepsContainer);
    hiw.steps.forEach((step, i) => {
      stepsContainer.appendChild(createEl('div', {
        className: `step-card reveal reveal--delay-${i + 1}`
      }, `
        <div class="step-card__number">${step.number}</div>
        <div class="step-card__icon">${step.icon}</div>
        <h3 class="step-card__title">${step.title}</h3>
        <p class="step-card__desc">${step.description}</p>
      `));
    });
  }

  function renderPreview(preview) {
    qs('#preview-badge').textContent = preview.badge;
    qs('#preview-title').innerHTML = preview.title;
    qs('#preview-subtitle').textContent = preview.subtitle;

    const grid = qs('#preview-grid');
    clearChildren(grid);
    preview.screens.forEach((screen, i) => {
      grid.appendChild(createEl('div', {
        className: `preview-card reveal reveal--delay-${Math.min(i + 1, 4)}`
      }, `
        <div class="preview-card__icon">${screen.icon}</div>
        <h3 class="preview-card__title">${screen.title}</h3>
        <p class="preview-card__desc">${screen.description}</p>
      `));
    });
  }

  function renderDownload(download) {
    qs('#download-badge').textContent = download.badge;
    qs('#download-title').innerHTML = download.title;
    qs('#download-subtitle').textContent = download.subtitle;

    const storesContainer = qs('#download-stores');
    clearChildren(storesContainer);
    download.stores.forEach(store => {
      storesContainer.appendChild(createEl('a', {
        href: store.href,
        className: 'btn btn--store',
        target: '_blank',
        rel: 'noopener noreferrer',
        ariaLabel: `${download.storePrefix || 'Get it on'} ${store.name}`
      }, `
        <span class="store-icon">${STORE_ICONS[store.icon] || ''}</span>
        <span class="store-label">
          <small>${download.storePrefix || 'Get it on'}</small>
          <strong>${store.name}</strong>
        </span>
      `));
    });

    const featuresList = qs('#download-features');
    clearChildren(featuresList);
    download.features_list.forEach(feature => {
      featuresList.appendChild(createEl('li', {}, feature));
    });

    const downloadLogo = qs('#download-logo');
    if (downloadLogo && download.logo) {
      downloadLogo.src = download.logo.src;
      downloadLogo.alt = download.logo.alt;
    }
  }

  function renderFooter(footer) {
    const logo = qs('#footer-logo');
    logo.src = footer.logo.src;
    logo.alt = footer.logo.alt;

    qs('#footer-desc').textContent = footer.description;
    qs('#footer-copyright').textContent = footer.copyright;

    const socialContainer = qs('#footer-social');
    clearChildren(socialContainer);
    footer.social.forEach(s => {
      socialContainer.appendChild(createEl('a', {
        href: s.href,
        className: 'footer__social-link',
        target: '_blank',
        rel: 'noopener noreferrer',
        ariaLabel: s.label,
        title: s.label
      }, SOCIAL_ICONS[s.platform] || s.label.charAt(0).toUpperCase()));
    });

    const columnsContainer = qs('#footer-columns');
    clearChildren(columnsContainer);
    footer.columns.forEach(col => {
      const column = createEl('div', { className: 'footer__col' });
      column.appendChild(createEl('h4', { className: 'footer__col-title' }, col.title));

      const links = createEl('div', { className: 'footer__col-links' });
      col.links.forEach(link => {
        const attrs = { href: link.href };
        if (link.href.startsWith('http') || link.href.startsWith('mailto:')) {
          attrs.target = '_blank';
          attrs.rel = 'noopener noreferrer';
        }
        links.appendChild(createEl('a', attrs, link.label));
      });
      column.appendChild(links);
      columnsContainer.appendChild(column);
    });
  }

  // --- Full Page Render ---

  function renderPage(data, locale) {
    applyDirection(data.meta);
    renderMeta(data.meta);
    renderBrandName(data.brandName);
    renderNav(data.nav);
    renderLangSwitcher(locale);
    renderHero(data.hero);
    renderFeatures(data.features);
    renderHowItWorks(data.howItWorks);
    renderPreview(data.preview);
    renderDownload(data.download);
    renderFooter(data.footer);

    requestAnimationFrame(() => {
      initScrollReveal();
      initSmoothScroll();
    });
  }

  // --- Interactive Features ---

  function initStickyNav() {
    const navbar = qs('#navbar');
    let ticking = false;

    window.addEventListener('scroll', () => {
      if (!ticking) {
        window.requestAnimationFrame(() => {
          navbar.classList.toggle('navbar--scrolled', window.scrollY > 50);
          ticking = false;
        });
        ticking = true;
      }
    }, { passive: true });
  }

  function initHamburgerMenu() {
    const hamburger = qs('#hamburger');
    const mobileMenu = qs('#mobile-menu');
    let isOpen = false;

    function toggleMenu() {
      isOpen = !isOpen;
      hamburger.classList.toggle('navbar__hamburger--active', isOpen);
      mobileMenu.classList.toggle('mobile-menu--open', isOpen);
      hamburger.setAttribute('aria-expanded', isOpen);
      mobileMenu.setAttribute('aria-hidden', !isOpen);
      document.body.style.overflow = isOpen ? 'hidden' : '';
    }

    hamburger.addEventListener('click', toggleMenu);

    mobileMenu.addEventListener('click', (e) => {
      if (e.target.closest('a') && isOpen) toggleMenu();
    });

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && isOpen) toggleMenu();
    });
  }

  function initScrollReveal() {
    const reveals = qsa('.reveal:not(.reveal--visible)');
    if (!reveals.length) return;

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('reveal--visible');
          observer.unobserve(entry.target);
        }
      });
    }, {
      threshold: 0.1,
      rootMargin: '0px 0px -40px 0px'
    });

    reveals.forEach(el => observer.observe(el));
  }

  function initSmoothScroll() {
    document.addEventListener('click', (e) => {
      const anchor = e.target.closest('a[href^="#"]');
      if (!anchor) return;

      const href = anchor.getAttribute('href');
      if (href === '#') return;

      const target = qs(href);
      if (target) {
        e.preventDefault();
        const navHeight = qs('#navbar').offsetHeight;
        const top = target.getBoundingClientRect().top + window.scrollY - navHeight - 16;
        window.scrollTo({ top, behavior: 'smooth' });
      }
    });
  }

  function initLangSwitcher(onSwitch) {
    qs('#lang-switcher').addEventListener('click', () => {
      onSwitch();
    });
  }

  // --- Boot ---

  let currentLocale = detectLocale();

  async function switchLocale() {
    const newLocale = SUPPORTED_LOCALES[currentLocale].switchTo;
    const data = await loadLocale(newLocale);
    if (!data) return;

    currentLocale = newLocale;
    saveLocale(newLocale);
    renderPage(data, newLocale);
  }

  async function init() {
    const data = await loadLocale(currentLocale);
    if (!data) return;

    saveLocale(currentLocale);
    renderPage(data, currentLocale);

    initStickyNav();
    initHamburgerMenu();
    initLangSwitcher(switchLocale);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
